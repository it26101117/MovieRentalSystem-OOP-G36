
package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Payment;
import com.movierental.service.MovieService;
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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;
import java.util.Collections;

/**
 * CineRent customer payments.
 *
 * GET  /payments                 - Customer payment history
 * GET  /payments?paymentId=P0001 - Payment details / receipt
 * POST /payments                 - Create a checkout payment
 *
 * Temporary local debugging:
 * GET /payments?debug=1 - Test servlet and customer session
 * GET /payments?debug=2 - Test PaymentService and JSP paths
 * GET /payments?debug=3 - Test JSP without PaymentService
 *
 * Requires @ServletComponentScan in MovieRentalApplication.
 * DEMO_CARD is a simulation; BANK_TRANSFER needs admin approval.
 * Payment confirmation alone does not create or activate a rental.
 */
@WebServlet(name = "PaymentServlet", urlPatterns = "/payments", loadOnStartup = 1)

public class PaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Object PAYMENT_LOCK = new Object();

    private static final String HISTORY_JSP = "/WEB-INF/views/my-payments.jsp";

    private static final String SUCCESS_JSP = "/WEB-INF/views/payment-success.jsp";

    private PaymentService paymentService;
    private MovieService movieService;
    private RentalService rentalService;


    // INITIALIZE SERVICES

    @Override
    public void init() throws ServletException {

        try {
            paymentService = new PaymentService(DataPathUtil.getFilePath("payments.txt"));

            movieService = new MovieService(DataPathUtil.getFilePath("movies.txt"));

            rentalService = new RentalService(DataPathUtil.getFilePath("rentals.txt"));

            logInfo("PaymentServlet initialized; mapping: /payments");

        } catch (Exception ex) {

            getServletContext().log("[CineRent] PaymentServlet initialization failed", ex);

            throw new ServletException("Could not initialize CineRent payment services", ex);
        }
    }

    // GET: PAYMENT HISTORY / DETAILS / DEBUGGING


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        logInfo("GET reached: " + request.getRequestURI());

        HttpSession session = request.getSession(false);

        String ctx = request.getContextPath();


        // SESSION VALIDATION

        if (session == null) {

            response.sendRedirect(ctx + "/login");
            return;
        }

        String role = asString(session.getAttribute("role"));

        String userId = asString(session.getAttribute("userId"));

        if ("ADMIN".equalsIgnoreCase(role)) {

            response.sendRedirect(ctx + "/admin/payments");

            return;
        }

        if (userId.isEmpty()) {

            response.sendRedirect(ctx + "/login");
            return;
        }

        if (!"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only customers can view customer payments.");

            return;
        }

        // DEBUG MODE
        // Temporary: localhost + authenticated customer only


        String debug = trim(request.getParameter("debug"));

        boolean localDebug = isLocalRequest(request) && !debug.isEmpty();


        // DEBUG 1: CHECK SERVLET AND SESSION


        if (localDebug && "1".equals(debug)) {

            response.setContentType("text/plain;charset=UTF-8");

            response.getWriter().println("SUCCESS: PaymentServlet GET is working.");

            response.getWriter().println("Stage: session and customer role verified.");

            return;
        }

        // DEBUG 3: TEST JSP WITHOUT PAYMENT SERVICE

        if (localDebug && "3".equals(debug)) {

            request.setAttribute("payments", Collections.<Payment>emptyList());

            request.setAttribute("userName", session.getAttribute("userName"));

            logInfo("DEBUG 3: forwarding to payment JSP with empty records");

            forwardToJsp(request, response, HISTORY_JSP);

            return;
        }


        // LOAD PAYMENT HISTORY

        try {

            logInfo("GET stage: loading payments for authenticated customer");

            List<Payment> payments = paymentService.getPaymentsByUser(userId);

            logInfo("GET stage: payment records loaded");


            // DEBUG 2: CHECK PAYMENT SERVICE AND JSP FILES


            if (localDebug && "2".equals(debug)) {

                response.setContentType("text/plain;charset=UTF-8");

                response.getWriter().println("SUCCESS: PaymentService loaded payment records.");

                response.getWriter().println("Records: " + (payments == null ? 0 : payments.size()));

                response.getWriter().println("Payment JSP exists: " + (getServletContext().getResource(HISTORY_JSP) != null));

                response.getWriter().println("Success JSP exists: " + (getServletContext().getResource(SUCCESS_JSP) != null));

                return;
            }


            // SET PAYMENT HISTORY ATTRIBUTES

            request.setAttribute("payments", payments);

            request.setAttribute("userName", session.getAttribute("userName"));

            String paymentId = trim(request.getParameter("paymentId"));


            // PAYMENT HISTORY PAGE

            if (paymentId.isEmpty()) {

                logInfo("GET stage: opening payment history");

                forwardToJsp(request, response, HISTORY_JSP);

                return;
            }


            // LOAD SELECTED PAYMENT


            logInfo("GET stage: loading selected payment");

            Payment payment = paymentService.getPaymentById(paymentId);

            if (payment == null || !userId.equals(payment.getUserId())) {

                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found or does not belong to this customer.");

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

            request.setAttribute("paymentMessage", messageFor(payment));


            // REDIRECT TO CORRECT JSP


            if (payment.isPaid()) {

                logInfo("GET stage: opening payment success JSP");

                forwardToJsp(request, response, SUCCESS_JSP);

            } else {

                logInfo("GET stage: opening pending payment JSP");

                forwardToJsp(request, response, HISTORY_JSP);
            }

        } catch (ServletException | IOException ex) {

            getServletContext().log("[CineRent] JSP forwarding or rendering failed", ex);

            throw ex;

        } catch (Exception ex) {

            getServletContext().log("[CineRent] Could not load customer payment page", ex);

            if (!response.isCommitted()) {

                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load payment records. Check the server console.");
            }
        }
    }


    // POST: PROCESS PAYMENT


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        logInfo("POST reached: " + request.getRequestURI());

        HttpSession session = request.getSession(false);

        String ctx = request.getContextPath();


        // VALIDATE CUSTOMER SESSION


        if (session == null) {

            response.sendRedirect(ctx + "/login");
            return;
        }

        String userId = asString(session.getAttribute("userId"));

        String role = asString(session.getAttribute("role"));

        if (userId.isEmpty()) {

            response.sendRedirect(ctx + "/login");
            return;
        }

        if (!"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only customers can make checkout payments.");
            return;
        }

        String movieId = trim(request.getParameter("movieId"));

        String paymentMethod = trim(request.getParameter("paymentMethod"));


        // VALIDATE CSRF TOKEN

        String expectedToken = asString(session.getAttribute("checkoutCsrfToken"));

        String submittedToken = trim(request.getParameter("csrfToken"));

        if (expectedToken.isEmpty() || submittedToken.isEmpty() || !MessageDigest.isEqual(
                        expectedToken.getBytes(StandardCharsets.UTF_8),
                        submittedToken.getBytes(StandardCharsets.UTF_8))) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid checkout token. Return to checkout and try again.");

            return;
        }

        // VALIDATE MOVIE

        if (movieId.isEmpty()) {

            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Please select a movie.");

            return;
        }

        // VALIDATE PAYMENT METHOD

        if (!PaymentService.DEMO_CARD.equals(paymentMethod)
                        && !PaymentService.BANK_TRANSFER.equals(paymentMethod)) {

            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported payment method.");

            return;
        }


        // CREATE PAYMENT


        try {

            Payment payment;

            synchronized (PAYMENT_LOCK) {

                logInfo("POST stage: loading selected movie");

                Movie movie = movieService.getMovieById(movieId);

                if (movie == null) {

                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found.");

                    return;
                }

                // CHECK EXISTING RENTAL

                if (rentalService.hasActiveRental(userId, movieId)) {

                    response.sendRedirect(ctx + "/rentals?error=alreadyactive");

                    return;
                }

                // CHECK EXISTING PAYMENT

                logInfo("POST stage: checking outstanding payments");

                payment = findOutstandingPayment(userId, movieId);

                if (payment == null) {


                    // CHECK AVAILABLE COPIES


                    if (movie.getAvailableCopies() <= 0) {

                        response.sendRedirect(ctx + "/catalog?error=unavailable");

                        return;
                    }

                    double rentalPrice = movie.getRentalPrice();

                    if (!Double.isFinite(rentalPrice) || rentalPrice <= 0) {

                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "The selected movie has an invalid rental price.");

                        return;
                    }

                    // CREATE PENDING PAYMENT

                    logInfo("POST stage: creating pending payment");

                    payment = paymentService.createPendingPayment(
                                    userId,
                                    movieId,
                                    BigDecimal.valueOf(rentalPrice),
                                    paymentMethod);
                }

                // SIMULATE DEMO CARD PAYMENT

                if (PaymentService.DEMO_CARD.equals(payment.getPaymentMethod()) && payment.isPending()) {

                    logInfo("POST stage: confirming demo payment");

                    payment = paymentService.markPaymentPaid(payment.getPaymentId());
                }
            }

            if (payment == null) {

                throw new IllegalStateException("Payment could not be created.");
            }

            session.removeAttribute("checkoutCsrfToken");

            String encodedPaymentId = URLEncoder.encode(payment.getPaymentId(), StandardCharsets.UTF_8);

            logInfo("POST stage: redirecting to payment details");

            response.sendRedirect(ctx + "/payments?paymentId=" + encodedPaymentId);

        } catch (Exception ex) {

            getServletContext().log("[CineRent] Could not process customer payment", ex);

            if (!response.isCommitted()) {

                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Payment processing failed. Check the server console.");
            }
        }
    }


    // JSP FORWARDING


    private void forwardToJsp(HttpServletRequest request, HttpServletResponse response, String jspPath) throws ServletException, IOException {

        logInfo("Checking JSP: " + jspPath);

        if (getServletContext().getResource(jspPath) == null) {

            getServletContext().log("[CineRent] MISSING JSP FILE: " + jspPath);

            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Missing JSP: " + jspPath + ". Create the file under src/main/webapp.");

            return;
        }

        logInfo("Forwarding to JSP: " + jspPath);

        request.getRequestDispatcher(jspPath).forward(request, response);
    }


    // FIND OUTSTANDING PAYMENT

    private Payment findOutstandingPayment(String userId, String movieId) {

        List<Payment> payments = paymentService.getPaymentsByUser(userId);

        if (payments == null) {
            return null;
        }

        Payment pending = null;

        for (Payment payment : payments) {

            if (payment == null || !movieId.equals(payment.getMovieId())) {
                continue;
            }

            if (payment.isPaid() && !payment.hasRental()) {
                return payment;
            }

            if (
                    payment.isPending() && pending == null) {
                pending = payment;
            }
        }

        return pending;
    }


    // PAYMENT STATUS MESSAGE

    private static String messageFor(Payment payment) {

        if (payment.isPaid()) {

            return payment.hasRental() ? "Payment confirmed and rental linked successfully." : "Payment confirmed. Rental activation is awaiting backend processing.";
        }

        if (payment.isPending()) {

            return "Bank transfer is pending administrator verification.";
        }

        if (payment.isRejected()) {

            return "Payment rejected. Please contact the administrator.";
        }

        if (payment.isFailed()) {

            return "Payment failed. Return to the catalogue and try again.";
        }

        return "Payment status: " + payment.getPaymentStatus();
    }


    // LOGGING

    private void logInfo(String message) {

        String line = "[CineRent] " + message;

        System.out.println(line);

        getServletContext().log(line);
    }

    // LOCAL DEBUGGING SECURITY CHECK


    private static boolean isLocalRequest(HttpServletRequest request) {

        String address = request.getRemoteAddr();

        return "127.0.0.1".equals(address) || "::1".equals(address) || "0:0:0:0:0:0:0:1".equals(address);
    }


    // STRING HELPERS

    private static String asString(Object value) {

        return value == null ? "" : String.valueOf(value).trim();
    }

    private static String trim(String value) {

        return value == null ? "" : value.trim();
    }
}
