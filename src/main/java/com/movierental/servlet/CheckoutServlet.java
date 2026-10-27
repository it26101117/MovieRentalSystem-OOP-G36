
package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.service.MovieService;
import com.movierental.service.RentalService;
import com.movierental.service.PaymentService;
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
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Locale;

@WebServlet(
        name = "CheckoutServlet",
        urlPatterns = {"/checkout"}
)
public class CheckoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // JSP VIEW

    private static final String CHECKOUT_VIEW = "/WEB-INF/views/checkout.jsp";

    // CSRF TOKEN

    public static final String CSRF_SESSION_KEY = "checkoutCsrfToken";
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    // SERVICES

    private MovieService movieService;
    private RentalService rentalService;

    // INITIALIZE SERVICES

    @Override
    public void init() throws ServletException {
        try {
            String movieFilePath = DataPathUtil.getFilePath("movies.txt");
            String rentalFilePath = DataPathUtil.getFilePath("rentals.txt");
            movieService = new MovieService(movieFilePath);
            rentalService = new RentalService(rentalFilePath);

        } catch (Exception e) {
            throw new ServletException("Failed to initialize CheckoutServlet.", e);
        }
    }

    // GET - DISPLAY CHECKOUT PAGE

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        // checkout information.
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setHeader("Pragma", "no-cache");

        // 1. VERIFY CUSTOMER LOGIN
        HttpSession session = request.getSession(false);

        if (session == null) {
            redirectToLogin(request, response);
            return;
        }

        Object userIdObject = session.getAttribute("userId");
        Object roleObject = session.getAttribute("role");

        if (userIdObject == null || roleObject == null) {
            redirectToLogin(request, response);
            return;
        }

        String userId = userIdObject.toString().trim();

        String role = roleObject.toString().trim();

        if (userId.isEmpty()) {
            redirectToLogin(request, response);
            return;
        }

        // 2. CUSTOMER ROLE VALIDATION

        if (!"CUSTOMER".equalsIgnoreCase(role)) {
            if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin");

            } else {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Customer access is required.");
            }
            return;
        }

        // 3. GET MOVIE ID

        String movieId = request.getParameter("movieId");
        if (movieId == null) {
            redirectToCatalog(request, response, "notfound");
            return;
        }
        movieId = movieId.trim();

        // Only accept standard movie IDs.
        if (!movieId.matches("[A-Za-z0-9_-]{1,64}")) {
            redirectToCatalog(request, response, "notfound");
            return;
        }

        try {

            // 4. FIND SELECTED MOVIE

            Movie movie = movieService.getMovieById(movieId);
            if (movie == null) {
                redirectToCatalog(request, response, "notfound");
                return;
            }

            // 5. CHECK MOVIE AVAILABILITY

            if (movie.getAvailableCopies() <= 0) {
                redirectToCatalog(request, response, "unavailable");
                return;
            }

            // 6. CHECK EXISTING ACTIVE RENTAL

            boolean alreadyRented = rentalService.hasActiveRental(userId, movie.getMovieId());
            if (alreadyRented) {
                redirectToCatalog(request, response, "alreadyrented");
                return;
            }

            // VALIDATE RENTAL PRICE

            double moviePrice = movie.getRentalPrice();
            if (!Double.isFinite(moviePrice) || moviePrice <= 0) {
                response.sendError(HttpServletResponse.SC_CONFLICT, "This movie does not have a valid rental price.");
                return;
            }

            // CALCULATE CHECKOUT AMOUNT

            BigDecimal rentalPrice = BigDecimal.valueOf(moviePrice).setScale(2, RoundingMode.HALF_UP);

            // 9. CUSTOMER DETAILS

            Object userNameObject = session.getAttribute("userName");
            String userName = userNameObject == null ? "Customer" : userNameObject.toString();

            // 10. GENERATE CSRF TOKEN

            String csrfToken = getOrCreateCsrfToken(session);

            // 11. SET CHECKOUT ATTRIBUTES


            request.setAttribute("movie", movie);
            request.setAttribute("movieId", movie.getMovieId());
            request.setAttribute("userId", userId);
            request.setAttribute("userName", userName);
            request.setAttribute("rentalPrice", rentalPrice);
            request.setAttribute("formattedRentalPrice", String.format(Locale.US, "LKR %,.2f", rentalPrice));
            request.setAttribute("currency", "LKR");
            request.setAttribute("demoCardMethod", PaymentService.DEMO_CARD);
            request.setAttribute("bankTransferMethod", PaymentService.BANK_TRANSFER);
            request.setAttribute("csrfToken", csrfToken);


            // 12. DISPLAY CHECKOUT JSP

            request.getRequestDispatcher(CHECKOUT_VIEW).forward(request, response);
        } catch (IOException e) {
            getServletContext().log("Unable to read movie or rental data.", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Unable to load checkout information.");

        } catch (RuntimeException e) {
            getServletContext().log("Unexpected checkout error.", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Checkout is temporarily unavailable.");
        }
    }

    // GENERATE / REUSE CSRF TOKEN

    private String getOrCreateCsrfToken(HttpSession session) {
        synchronized (session) {
            Object existingToken = session.getAttribute(CSRF_SESSION_KEY);
            if (existingToken instanceof String && !((String) existingToken).isBlank()) {
                return (String) existingToken;
            }
            byte[] randomBytes = new byte[32];
            SECURE_RANDOM.nextBytes(randomBytes);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
            session.setAttribute(CSRF_SESSION_KEY, token);
            return token;
        }
    }

    // REDIRECT TO LOGIN

    private void redirectToLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login");
    }

    // REDIRECT TO MOVIE CATALOG

    private void redirectToCatalog(HttpServletRequest request, HttpServletResponse response, String errorCode) throws IOException {
        response.sendRedirect(request.getContextPath() + "/catalog?error=" + errorCode);
    }
}
