
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

/**
 * CineRent Customer Payment Servlet
 *
 * GET /payments
 *     Displays the customer's payment history.
 *
 * GET /payments?paymentId=P0001
 *     Displays details of one payment.
 *
 * POST /payments
 *     Processes a checkout request.
 *
 * DEMO_CARD:
 *     Simulated payment, marked PAID.
 *
 * BANK_TRANSFER:
 *     Remains PENDING until administrator approval.
 *
 * Rental activation must be integrated separately
 * with the project's actual RentalService API.
 */
@WebServlet(name = "PaymentServlet", urlPatterns = "/payments")
public class PaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Object PAYMENT_LOCK = new Object();

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

        } catch (Exception ex) {

            throw new ServletException("Could not initialize payment services", ex);
        }
    }


    // GET: PAYMENT HISTORY AND PAYMENT DETAILS


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        String ctx = request.getContextPath();


        // 1. SESSION CHECK

        if (session == null) {

            response.sendRedirect(ctx + "/login");
            return;
        }

        String role = asString(session.getAttribute("role"));


        // 2. ADMINISTRATOR REDIRECT


        if ("ADMIN".equalsIgnoreCase(role)) {

            response.sendRedirect(ctx + "/admin/payments");

            return;
        }

        String userId = asString(session.getAttribute("userId"));

        if (userId.isEmpty()) {

            response.sendRedirect(ctx + "/login");
            return;
        }


        // 3. CUSTOMER ACCESS CHECK

        if (!"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Customer access required.");
            return;
        }

        try {


            // 4. LOAD CUSTOMER PAYMENT HISTORY


            List<Payment> payments = paymentService.getPaymentsByUser(userId);

            request.setAttribute("payments", payments);

            request.setAttribute("userName", session.getAttribute("userName"));

            String paymentId = trim(request.getParameter("paymentId"));

            // 5. PAYMENT HISTORY PAGE

            // /payments

            // This fixes the HTTP 400 error.


            if (paymentId.isEmpty()) {

                request.getRequestDispatcher("/WEB-INF/views/my-payment.jsp").forward(request, response);

                return;
            }


            // 6. LOAD SELECTED PAYMENT

            // /payments?paymentId=P0001


            Payment payment = paymentService.getPaymentById(paymentId);


            // 7. VERIFY PAYMENT OWNERSHIP


            if (payment == null || !userId.equals(payment.getUserId())) {

                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Payment not found.");

                return;
            }

            // 8. LOAD RELATED MOVIE

            Movie movie = movieService.getMovieById(payment.getMovieId());


            // 9. SET JSP ATTRIBUTES

            request.setAttribute("payment", payment);

            request.setAttribute("movie", movie);

            request.setAttribute("paymentId", payment.getPaymentId());

            request.setAttribute("paymentStatus", payment.getPaymentStatus());

            request.setAttribute("paymentMethod", payment.getPaymentMethod());

            request.setAttribute("isPaid", payment.isPaid());

            request.setAttribute("isPending", payment.isPending());

            request.setAttribute("rentalReady", payment.isPaid() && payment.hasRental());

            request.setAttribute("paymentMessage", messageFor(payment));

            // 10. FORWARD BASED ON PAYMENT STATUS

            if (payment.isPaid()) {

                request.getRequestDispatcher("/WEB-INF/views/payment-success.jsp").forward(request, response);

            } else {

                request.getRequestDispatcher("/WEB-INF/views/my-payment.jsp").forward(request, response);
            }

        } catch (ServletException | IOException ex) {

            throw ex;

        } catch (Exception ex) {

            getServletContext().log("Unable to display customer payments", ex);

            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Payment records could not be loaded.");
        }
    }

    // POST: PROCESS CHECKOUT PAYMENT


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        String ctx = request.getContextPath();


        // 1. LOGIN CHECK


        if (session == null || session.getAttribute("userId") == null) {

            response.sendRedirect(ctx + "/login");
            return;
        }


        // 2. CUSTOMER ROLE CHECK


        String role = asString(session.getAttribute("role"));

        if (!"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Customer access required.");

            return;
        }

        String userId = asString(session.getAttribute("userId"));

        String movieId = trim(request.getParameter("movieId"));

        String method = trim(request.getParameter("paymentMethod"));


        // 3. CSRF VALIDATION


        String expectedToken = asString(session.getAttribute("checkoutCsrfToken"));

        String submittedToken = trim(request.getParameter("csrfToken"));

        if (expectedToken.isEmpty() || submittedToken.isEmpty() || !MessageDigest.isEqual(expectedToken.getBytes(StandardCharsets.UTF_8), submittedToken.getBytes(StandardCharsets.UTF_8))) {

            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid or expired checkout token. Reload checkout.");

            return;
        }


        // 4. MOVIE VALIDATION


        if (movieId.isEmpty()) {

            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "A movie must be selected.");

            return;
        }

        // 5. PAYMENT METHOD VALIDATION


        if (!PaymentService.DEMO_CARD.equals(method) && !PaymentService.BANK_TRANSFER.equals(method)) {

            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unsupported payment method.");

            return;
        }

        try {

            Payment payment;


            // 6. PREVENT DUPLICATE SUBMISSIONS

            synchronized (PAYMENT_LOCK) {

                Movie movie = movieService.getMovieById(movieId);

                if (movie == null) {

                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found.");

                    return;
                }


                // 7. CHECK EXISTING ACTIVE RENTAL


                if (rentalService.hasActiveRental(
                        userId,
                        movieId
                )) {

                    response.sendRedirect(ctx + "/rentals?error=alreadyactive");

                    return;
                }


                // 8. REUSE OUTSTANDING PAYMENT


                payment = findOutstandingPayment(userId, movieId);

                if (payment == null) {


                    // 9. CHECK AVAILABLE COPIES


                    if (movie.getAvailableCopies() <= 0) {

                        response.sendRedirect(ctx + "/catalog?error=unavailable");

                        return;
                    }


                    // 10. VALIDATE RENTAL PRICE


                    double price = movie.getRentalPrice();

                    if (!Double.isFinite(price) || price <= 0) {

                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "This movie does not have a valid rental price.");

                        return;
                    }

                    BigDecimal amount = BigDecimal.valueOf(price);


                    // 11. CREATE PAYMENT

                    payment =
                            paymentService.createPendingPayment(userId, movieId, amount, method);


                    // 12. DEMO CARD PAYMENT


                    if (PaymentService.DEMO_CARD.equals(method)) {

                        payment = paymentService.markPaymentPaid(payment.getPaymentId());
                    }

                    // BANK_TRANSFER remains PENDING.
                    // Admin approval is handled separately.
                }
            }

            if (payment == null) {

                throw new IllegalStateException("Payment was not created");
            }

            // 13. REMOVE USED CHECKOUT TOKEN


            session.removeAttribute("checkoutCsrfToken");


            // 14. REDIRECT TO PAYMENT DETAILS


            String encodedId = URLEncoder.encode(payment.getPaymentId(), StandardCharsets.UTF_8);

            response.sendRedirect(ctx + "/payments?paymentId=" + encodedId);

        } catch (Exception ex) {

            getServletContext().log("Unable to process customer payment", ex);

            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Payment could not be processed. Please try again.");
        }
    }


    // FIND EXISTING PENDING OR PAID-UNLINKED PAYMENT


    private Payment findOutstandingPayment(String userId, String movieId) {

        List<Payment> payments =
                paymentService.getPaymentsByUser(userId);

        if (payments == null) {
            return null;
        }

        Payment pending = null;

        for (Payment payment : payments) {

            if (payment == null
                    || !movieId.equals(payment.getMovieId())) {
                continue;
            }

            // Prefer a paid record awaiting rental linking.
            if (payment.isPaid() && !payment.hasRental()) {
                return payment;
            }

            if (payment.isPending() && pending == null) {
                pending = payment;
            }
        }

        return pending;
    }


    // PAYMENT STATUS MESSAGE


    private static String messageFor(Payment payment) {

        if (payment.isPaid()) {

            if (payment.hasRental()) {

                return "Payment confirmed and rental linked successfully.";
            }

            return "Payment recorded. Rental activation is awaiting backend processing.";
        }

        if (payment.isPending()) {

            return "Bank transfer pending. An administrator must verify payment before rental activation.";
        }

        if (payment.isRejected()) {

            return "This payment was rejected. Please contact the administrator.";
        }

        if (payment.isFailed()) {

            return "This payment failed. Please return to the catalogue and try again.";
        }

        return "Payment status: "
                + payment.getPaymentStatus();
    }


    // HELPER METHODS


    private static String asString(Object value) {

        return value == null ? "" : String.valueOf(value).trim();
    }

    private static String trim(String value) {

        return value == null ? "" : value.trim();
    }
}
