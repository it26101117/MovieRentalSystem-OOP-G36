package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Payment;
import com.movierental.model.Rental;
import com.movierental.service.MovieService;
import com.movierental.service.PaidRentalActivationService;
import com.movierental.service.PaymentService;
import com.movierental.service.RentalService;
import com.movierental.service.WatchHistoryService;
import com.movierental.util.DataPathUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDate;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(name = "RentalServlet", urlPatterns = "/rentals")
public class RentalServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Object RENTAL_LOCK = new Object();
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final String TOKEN_KEY = "rentalCsrfToken";

    private PaymentService paymentService;
    private RentalService rentalService;
    private MovieService movieService;
    private WatchHistoryService watchHistoryService;

    @Override
    public void init() throws ServletException {
        try {
            String rentals = DataPathUtil.getFilePath("rentals.txt");
            String movies = DataPathUtil.getFilePath("movies.txt");
            String payments = DataPathUtil.getFilePath("payments.txt");
            String history = DataPathUtil.getFilePath("watch_history.txt");
            rentalService = new RentalService(rentals);
            movieService = new MovieService(movies);
            paymentService = new PaymentService(payments);
            watchHistoryService = new WatchHistoryService(history, movieService);
            getServletContext().log("Rental storage: " + rentals);
            getServletContext().log("Payment storage: " + payments);
        } catch (Exception ex) {
            throw new ServletException("Cannot initialize rental services", ex);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setHeader("Cache-Control", "no-store");
        HttpSession session = request.getSession(false);
        String userId = requireCustomer(request, response, session);
        if (userId == null) return;

        try {
            List<Rental> rentals = rentalService.getRentalsByUser(userId);
            List<Movie> movies = movieService.getAllMovies();
            List<Payment> payments = paymentService.getPaymentsByUser(userId);

            Map<String, Movie> moviesById = new HashMap<>();
            for (Movie movie : movies) {
                moviesById.put(movie.getMovieId(), movie);
            }

            request.setAttribute("rentals", rentals);
            request.setAttribute("movies", movies);
            request.setAttribute("moviesById", moviesById);
            request.setAttribute("payments", payments);
            request.setAttribute("movieService", movieService);
            request.setAttribute(TOKEN_KEY, getOrCreateToken(session));
            request.getRequestDispatcher("/WEB-INF/views/my-rentals.jsp")
                    .forward(request, response);
        } catch (IOException ex) {
            getServletContext().log("Cannot load rentals for " + userId, ex);
            response.sendError(500, "Unable to load rentals. Check server logs.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        String userId = requireCustomer(request, response, session);
        if (userId == null) return;

        String action = request.getParameter("action");
        if ("rent".equalsIgnoreCase(action)) {
            if (!validToken(session, request.getParameter("rentalCsrfToken"))) {
                response.sendError(403, "Invalid rental activation token.");
                return;
            }
            activatePaidRental(request, response, session, userId);
        } else if ("return".equalsIgnoreCase(action)) {
            if (!validToken(session, request.getParameter("csrfToken"))) {
                response.sendError(403, "Invalid rental return token.");
                return;
            }
            returnMovie(request, response, userId);
        } else {
            response.sendError(400, "Unsupported rental action.");
        }
    }

    private void activatePaidRental(HttpServletRequest request,
                                    HttpServletResponse response,
                                    HttpSession session, String userId) throws IOException {
        String paymentId = trim(request.getParameter("paymentId"));
        String movieId = trim(request.getParameter("movieId"));
        if (paymentId.isEmpty() || !movieId.matches("[A-Za-z0-9_-]{1,64}")) {
            response.sendError(400, "Valid payment and movie IDs are required.");
            return;
        }

        try {
            Payment payment = paymentService.getPaymentById(paymentId);
            if (payment == null || !userId.equals(payment.getUserId()) ||
                    !movieId.equals(payment.getMovieId()) || !payment.isPaid()) {
                response.sendError(403, "A confirmed payment owned by this customer is required.");
                return;
            }
            new PaidRentalActivationService().activate(paymentId);
            response.sendRedirect(request.getContextPath() + "/rentals");
        } catch (IllegalStateException ex) {
            getServletContext().log("Cannot activate paid rental " + paymentId, ex);
            response.sendRedirect(request.getContextPath() + "/rentals?error=activation");
        } catch (Exception ex) {
            getServletContext().log("Failed to activate paid rental " + paymentId, ex);
            response.sendError(500, "Unable to activate rental; check application logs.");
        }
    }

    private void returnMovie(HttpServletRequest request,
                             HttpServletResponse response, String userId) throws IOException {
        String rentalId = trim(request.getParameter("rentalId"));
        if (rentalId.isEmpty()) {
            response.sendError(400, "Rental ID is required.");
            return;
        }

        synchronized (RENTAL_LOCK) {
            try {
                Rental rental = rentalService.getRentalById(rentalId);
                if (rental == null || !userId.equals(rental.getUserId())) {
                    response.sendError(404, "Rental not found.");
                    return;
                }
                if (!"RENTED".equalsIgnoreCase(rental.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/rentals");
                    return;
                }

                Movie movie = movieService.getMovieById(rental.getMovieId());
                String oldDate = rental.getReturnDate();
                String oldStatus = rental.getStatus();
                rental.setStatus("RETURNED");
                rental.setReturnDate(LocalDate.now().toString());
                if (!rentalService.updateRental(rental)) {
                    response.sendError(500, "Unable to update rental.");
                    return;
                }

                if (movie != null) {
                    int previousCopies = movie.getAvailableCopies();
                    movie.setAvailableCopies(previousCopies + 1);
                    if (!movieService.updateMovie(movie)) {
                        rental.setStatus(oldStatus);
                        rental.setReturnDate(oldDate);
                        rentalService.updateRental(rental);
                        response.sendError(500, "Unable to update movie inventory.");
                        return;
                    }
                }
                try {
                    watchHistoryService.recordWatchedMovie(userId, rental.getMovieId());
                } catch (Exception ex) {
                    getServletContext().log("Watch history could not be updated: " + rentalId, ex);
                }
                response.sendRedirect(request.getContextPath() + "/rentals");
            } catch (Exception ex) {
                getServletContext().log("Movie return failed: " + rentalId, ex);
                if (!response.isCommitted()) response.sendError(500, "Unable to return movie.");
            }
        }
    }

    private String requireCustomer(HttpServletRequest request,
                                   HttpServletResponse response,
                                   HttpSession session) throws IOException {
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        Object role = session.getAttribute("role");
        if (role == null || !"CUSTOMER".equalsIgnoreCase(role.toString())) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return null;
        }
        Object id = session.getAttribute("userId");
        if (id == null || id.toString().isBlank()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return id.toString().trim();
    }

    private String getOrCreateToken(HttpSession session) {
        synchronized (session) {
            Object stored = session.getAttribute(TOKEN_KEY);
            if (stored instanceof String && !((String) stored).isBlank()) {
                return (String) stored;
            }
            byte[] bytes = new byte[32];
            RANDOM.nextBytes(bytes);
            String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(TOKEN_KEY, token);
            return token;
        }
    }

    private boolean validToken(HttpSession session, String submitted) {
        if (session == null || submitted == null) return false;
        Object stored = session.getAttribute(TOKEN_KEY);
        return stored instanceof String && MessageDigest.isEqual(
                ((String) stored).getBytes(StandardCharsets.UTF_8),
                submitted.getBytes(StandardCharsets.UTF_8));
    }

    private static String trim(String text) {
        return text == null ? "" : text.trim();
    }
}
