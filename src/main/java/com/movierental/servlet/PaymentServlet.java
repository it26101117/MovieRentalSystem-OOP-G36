package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Payment;
import com.movierental.model.User;
import com.movierental.service.MovieService;
import com.movierental.service.PayHereGateway;
import com.movierental.service.PaymentService;
import com.movierental.service.RentalService;
import com.movierental.util.DataPathUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * CineRent customer payment history and checkout.
 * GET /payments                  - payment history
 * GET /payments?paymentId=P0001  - individual payment
 * POST /payments                 - start a payment
 *
 * PayHere payment confirmation is performed ONLY by PayHereNotifyServlet,
 * never by this servlet or the browser return URL.
 */
@WebServlet(name = "PaymentServlet", urlPatterns = "/payments")
public class PaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Object CHECKOUT_LOCK = new Object();
    private static final SecureRandom RANDOM = new SecureRandom();

    // These names must match the actual files in WEB-INF/views.
    private static final String HISTORY_VIEW = "/WEB-INF/views/my-payments.jsp";
    private static final String SUCCESS_VIEW = "/WEB-INF/views/payment-success.jsp";
    private static final String PAYHERE_VIEW = "/WEB-INF/views/payhere-redirect.jsp";

    private PaymentService paymentService;
    private MovieService movieService;
    private RentalService rentalService;

    @Override
    public void init() throws ServletException {
        try {
            paymentService = new PaymentService(
                    DataPathUtil.getFilePath("payments.txt"));
            movieService = new MovieService(
                    DataPathUtil.getFilePath("movies.txt"));
            rentalService = new RentalService(
                    DataPathUtil.getFilePath("rentals.txt"));
        } catch (Exception ex) {
            throw new ServletException("Unable to initialize payment services", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession(false);
        String userId = authenticatedCustomer(request, response, session);
        if (userId == null) return;

        try {
            List<Payment> payments = paymentService.getPaymentsByUser(userId);
            request.setAttribute("payments", payments);
            request.setAttribute("userName", session.getAttribute("userName"));

            String paymentId = trim(request.getParameter("paymentId"));
            if (paymentId.isEmpty()) {
                forward(request, response, HISTORY_VIEW);
                return;
            }

            Payment payment = paymentService.getPaymentById(paymentId);
            if (payment == null || !userId.equals(payment.getUserId())) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found");
                return;
            }

            Movie movie = movieService.getMovieById(payment.getMovieId());
            request.setAttribute("payment", payment);
            request.setAttribute("movie", movie);
            request.setAttribute("paymentId", payment.getPaymentId());
            request.setAttribute("paymentStatus", payment.getPaymentStatus());
            request.setAttribute("paymentMethod", payment.getPaymentMethod());
            request.setAttribute("isPaid", payment.isPaid());
            request.setAttribute("isPending", payment.isPending());
            request.setAttribute("rentalReady", payment.isPaid() && payment.hasRental());
            request.setAttribute("paymentMessage", statusMessage(payment));

            if (payment.isPaid()) {
                if (!payment.hasRental()) {
                    request.setAttribute("rentalCsrfToken", rentalToken(session));
                }
                forward(request, response, SUCCESS_VIEW);
            } else {
                forward(request, response, HISTORY_VIEW);
            }

        } catch (ServletException | IOException ex) {
            getServletContext().log("Payment page rendering failed", ex);
            throw ex;
        } catch (RuntimeException ex) {
            getServletContext().log("Unable to load customer payments", ex);
            if (!response.isCommitted()) {
                response.sendError(500, "Unable to load payments; check server logs");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession(false);
        String userId = authenticatedCustomer(request, response, session);
        if (userId == null) return;

        // Check the CSRF token generated by CheckoutServlet.
        String expected = trim((String) session.getAttribute("checkoutCsrfToken"));
        String supplied = trim(request.getParameter("csrfToken"));
        if (expected.isEmpty() || supplied.isEmpty() || !MessageDigest.isEqual(
                expected.getBytes(StandardCharsets.UTF_8),
                supplied.getBytes(StandardCharsets.UTF_8))) {
            response.sendError(403, "Invalid checkout token. Reload checkout and retry.");
            return;
        }

        String movieId = trim(request.getParameter("movieId"));
        if (!movieId.matches("[A-Za-z0-9_-]{1,64}")) {
            response.sendError(400, "Invalid movie ID");
            return;
        }

        String method = trim(request.getParameter("paymentMethod"))
                .toUpperCase(Locale.ROOT);
        if (!PaymentService.PAYHERE.equals(method)
                && !PaymentService.BANK_TRANSFER.equals(method)
                && !PaymentService.DEMO_CARD.equals(method)) {
            response.sendError(400, "Unsupported payment method: " + method);
            return;
        }

        if (PaymentService.DEMO_CARD.equals(method)
                && !Boolean.parseBoolean(System.getenv().getOrDefault(
                "CINERENT_DEMO_PAYMENTS_ENABLED", "false"))) {
            response.sendError(403, "Demo payments are disabled");
            return;
        }

        // Check PayHere configuration and billing fields before creating an order.
        PayHereGateway gateway = null;
        String name = "", email = "", phone = "", address = "", city = "";
        if (PaymentService.PAYHERE.equals(method)) {
            try {
                gateway = new PayHereGateway();
            } catch (RuntimeException ex) {
                getServletContext().log("PayHere configuration is missing/invalid", ex);
                response.sendError(503, "PayHere is not configured on this server");
                return;
            }

            Object loggedUser = session.getAttribute("loggedUser");
            if (!(loggedUser instanceof User)) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
            User customer = (User) loggedUser;
            if (!userId.equals(customer.getUserId())) {
                response.sendError(403, "Account session mismatch");
                return;
            }

            name = trim(customer.getName());
            email = trim(customer.getEmail());
            phone = trim(request.getParameter("phone"));
            address = trim(request.getParameter("address"));
            city = trim(request.getParameter("city"));
            if (name.isEmpty()
                    || !email.matches("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$")
                    || !phone.matches("[+0-9 ()-]{7,24}")
                    || address.isEmpty() || address.length() > 200
                    || city.isEmpty() || city.length() > 80) {
                response.sendError(400,
                        "PayHere requires valid account email, phone, address and city");
                return;
            }
        }

        try {
            Payment payment;
            Movie movie;

            synchronized (CHECKOUT_LOCK) {
                movie = movieService.getMovieById(movieId);
                if (movie == null) {
                    response.sendError(404, "Movie not found");
                    return;
                }
                if (rentalService.hasActiveRental(userId, movieId)) {
                    response.sendRedirect(request.getContextPath()
                            + "/rentals?error=alreadyactive");
                    return;
                }

                // Reuse a PAID but unlinked order, or a pending order
                // with the same method, instead of duplicating charges.
                payment = findOutstandingPayment(userId, movieId, method);
                if (payment == null) {
                    if (movie.getAvailableCopies() <= 0) {
                        response.sendRedirect(request.getContextPath()
                                + "/catalog?error=unavailable");
                        return;
                    }
                    double price = movie.getRentalPrice();
                    if (!Double.isFinite(price) || price <= 0) {
                        response.sendError(400, "Movie rental price is invalid");
                        return;
                    }
                    BigDecimal amount = BigDecimal.valueOf(price)
                            .setScale(2, RoundingMode.HALF_UP);
                    payment = paymentService.createPendingPayment(
                            userId, movieId, amount, method);
                }

                if (PaymentService.DEMO_CARD.equals(payment.getPaymentMethod())
                        && payment.isPending()) {
                    payment = paymentService.markPaymentPaid(payment.getPaymentId());
                }
            }

            // PayHere is NEVER marked paid here. The verified IPN callback
            // is the only path to a successful PayHere payment.
            if (PaymentService.PAYHERE.equals(payment.getPaymentMethod())
                    && payment.isPending()) {
                Map<String, String> fields = gateway.checkoutFields(
                        payment, movie.getTitle(), name, email, phone, address, city);
                request.setAttribute("payhereFields", fields);
                request.setAttribute("payhereCheckoutUrl", gateway.getCheckoutUrl());
                session.removeAttribute("checkoutCsrfToken");
                forward(request, response, PAYHERE_VIEW);
                return;
            }

            session.removeAttribute("checkoutCsrfToken");
            response.sendRedirect(request.getContextPath()
                    + "/payments?paymentId="
                    + URLEncoder.encode(payment.getPaymentId(), StandardCharsets.UTF_8));

        } catch (ServletException | IOException ex) {
            getServletContext().log("Payment checkout forwarding failed", ex);
            throw ex;
        } catch (RuntimeException ex) {
            getServletContext().log("Payment checkout failed", ex);
            if (!response.isCommitted()) {
                response.sendError(500, "Payment processing failed; check server logs");
            }
        }
    }

    /** Require a logged-in customer; redirect admins to their own payments page. */
    private String authenticatedCustomer(HttpServletRequest request,
                                         HttpServletResponse response,
                                         HttpSession session) throws IOException {
        String context = request.getContextPath();
        if (session == null || trim((String) session.getAttribute("userId")).isEmpty()) {
            response.sendRedirect(context + "/login");
            return null;
        }
        String role = trim((String) session.getAttribute("role"));
        if ("ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(context + "/admin/payments");
            return null;
        }
        if (!"CUSTOMER".equalsIgnoreCase(role)) {
            response.sendError(403, "Customer access required");
            return null;
        }
        return trim((String) session.getAttribute("userId"));
    }

    /** Keep the exact filename in sync with src/main/webapp/WEB-INF/views. */
    private void forward(HttpServletRequest request, HttpServletResponse response,
                         String view) throws ServletException, IOException {
        if (getServletContext().getResource(view) == null) {
            getServletContext().log("Missing payment JSP: " + view);
            response.sendError(500, "Missing JSP: " + view);
            return;
        }
        request.getRequestDispatcher(view).forward(request, response);
    }

    private Payment findOutstandingPayment(String userId, String movieId,
                                           String requestedMethod) {
        List<Payment> payments = paymentService.getPaymentsByUser(userId);
        Payment pending = null;
        for (Payment payment : payments) {
            if (payment == null || !movieId.equals(payment.getMovieId())) continue;
            if (payment.isPaid() && !payment.hasRental()) return payment;
            if (payment.isPending()
                    && requestedMethod.equals(payment.getPaymentMethod())
                    && pending == null) pending = payment;
        }
        return pending;
    }

    private static String statusMessage(Payment payment) {
        if (payment == null) {
            return "Payment information is unavailable.";
        }

        String status = payment.getPaymentStatus();
        String method = payment.getPaymentMethod();

        if ("PAID".equalsIgnoreCase(status)) {
            if (payment.hasRental()) {
                return "Payment confirmed and rental linked.";
            }
            return "Payment confirmed. Activate your rental to begin watching.";
        }

        if ("PENDING".equalsIgnoreCase(status)) {
            if ("PAYHERE".equalsIgnoreCase(method)) {
                return "Waiting for PayHere confirmation. Refresh after checkout.";
            }
            if ("BANK_TRANSFER".equalsIgnoreCase(method)) {
                return "Bank transfer pending administrator verification.";
            }
            return "Payment is pending confirmation.";
        }

        if ("CHARGEBACK".equalsIgnoreCase(status)) {
            return "Payment charged back. Rental access may be revoked.";
        }
        if ("REJECTED".equalsIgnoreCase(status)) {
            return "Payment rejected. Contact support.";
        }
        if ("FAILED".equalsIgnoreCase(status)) {
            return "Payment failed. Please try again.";
        }
        return "Payment status: " + status;
    }

    private static String rentalToken(HttpSession session) {
        synchronized (session) {
            Object existing = session.getAttribute("rentalCsrfToken");

            if (existing instanceof String && !((String) existing).isBlank())

                return (String) existing;
            byte[] random = new byte[32];
            RANDOM.nextBytes(random);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(random);
            session.setAttribute("rentalCsrfToken", token);
            return token;
        }
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }
}