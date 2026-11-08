package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Rental;
import com.movierental.model.Payment;
import com.movierental.service.PaymentService;
import com.movierental.service.MovieService;
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
import java.time.LocalDate;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.List;

@WebServlet("/rentals")
public class RentalServlet extends HttpServlet {

    private static final Object RENTAL_ACTIVATION_LOCK = new Object();
    private PaymentService paymentService;
    private RentalService rentalService;
    private MovieService movieService;
    private WatchHistoryService watchHistoryService;

    // INITIALIZATION

    @Override
    public void init() throws ServletException {

        try {

            String rentalFilePath = DataPathUtil.getFilePath("rentals.txt");

            String movieFilePath = DataPathUtil.getFilePath("movies.txt");

            String watchHistoryFilePath = DataPathUtil.getFilePath("watch_history.txt");


            rentalService = new RentalService(rentalFilePath);
            paymentService = new PaymentService(DataPathUtil.getFilePath("payments.txt"));

            movieService = new MovieService(movieFilePath);

            watchHistoryService = new WatchHistoryService(watchHistoryFilePath, movieService);


            System.out.println("RentalServlet rentals file: " + rentalFilePath);

            System.out.println("RentalServlet movies file: " + movieFilePath);

            System.out.println("RentalServlet watch history file: " + watchHistoryFilePath);

        } catch (Exception e) {
            throw new ServletException("Failed to initialize RentalServlet", e);
        }
    }

    // GET - SHOW CUSTOMER RENTALS

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(false);


        // LOGIN CHECK

        if (session == null || session.getAttribute("loggedUser") == null) {

            response.sendRedirect(request.getContextPath() + "/login");

            return;
        }


        // CUSTOMER ACCESS ONLY

        String role = (String) session.getAttribute("role");

        if (!"CUSTOMER".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }


        // GET CUSTOMER RENTALS

        List<Rental> rentals = rentalService.getRentalsByUser(userId);

        request.setAttribute("rentals", rentals);

        request.setAttribute("movieService", movieService);

        request.getRequestDispatcher("/WEB-INF/views/my-rentals.jsp").forward(request, response);
    }


    // POST - RENT OR RETURN

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);


        // LOGIN CHECK

        if (session == null || session.getAttribute("loggedUser") == null) {

            response.sendRedirect(request.getContextPath() + "/login");

            return;
        }


        // CUSTOMER ACCESS ONLY

        String role = (String) session.getAttribute("role");

        if (!"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendRedirect(request.getContextPath() + "/admin");

            return;
        }

        String userId = (String) session.getAttribute("userId");

        if (userId == null) {response.sendRedirect(request.getContextPath() + "/login");

            return;
        }

        String action = request.getParameter("action");


        // RENT

        if ("rent".equalsIgnoreCase(action)) {rentMovie(request, response, userId);

        }

        // RETURN

        else if ("return".equalsIgnoreCase(action)) {

            returnMovie(request, response, userId);

        }

        // INVALID ACTION

        else {
            response.sendRedirect(request.getContextPath()+ "/rentals");
        }
    }


    // RENT MOVIE

    private void rentMovie(HttpServletRequest request, HttpServletResponse response, String userId)
            throws IOException {
        HttpSession session = request.getSession(false);
        String token = request.getParameter("rentalCsrfToken");
        Object stored = session == null ? null : session.getAttribute("rentalCsrfToken");
        if (!(stored instanceof String) || token == null || !MessageDigest.isEqual(
                ((String) stored).getBytes(StandardCharsets.UTF_8),
                token.getBytes(StandardCharsets.UTF_8))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Rental activation requires a valid confirmation token.");
            return;
        }

        String paymentId = request.getParameter("paymentId");
        String movieId = request.getParameter("movieId");
        if (paymentId == null || movieId == null || paymentId.isBlank() || movieId.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Payment and movie required.");
            return;
        }

        synchronized (RENTAL_ACTIVATION_LOCK) {
            Payment payment = paymentService.getPaymentById(paymentId);
            if (payment == null || !userId.equals(payment.getUserId())
                    || !movieId.equals(payment.getMovieId()) || !payment.isPaid()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "A confirmed payment belonging to this customer is required.");
                return;
            }
            if (payment.hasRental()) {
                response.sendRedirect(request.getContextPath() + "/rentals");
                return;
            }
            Movie movie = movieService.getMovieById(movieId);
            if (movie == null || movie.getAvailableCopies() <= 0) {
                response.sendRedirect(request.getContextPath() + "/catalog?error=unavailable");
                return;
            }
            if (rentalService.hasActiveRental(userId, movieId)) {
                response.sendRedirect(request.getContextPath() + "/rentals?error=alreadyactive");
                return;
            }

            String rentalId = rentalService.generateNextRentalId();
            Rental rental = new Rental(rentalId, userId, movieId,
                    LocalDate.now().toString(), "", "RENTED");
            int oldCopies = movie.getAvailableCopies();
            boolean rentalAdded = false;
            boolean copiesChanged = false;
            try {
                rentalService.addRental(rental);
                rentalAdded = true;
                movie.setAvailableCopies(oldCopies - 1);
                if (!movieService.updateMovie(movie))
                    throw new IOException("Could not update movie inventory");
                copiesChanged = true;
                paymentService.attachRentalId(paymentId, rentalId);
            } catch (Exception failure) {
                // Best-effort compensation only. For real-money production use DB transactions.
                if (rentalAdded) {
                    try {
                        rental.setStatus("RETURNED");
                        rental.setReturnDate(LocalDate.now().toString());
                        rentalService.updateRental(rental);
                    } catch (Exception rollback) {
                        getServletContext().log("URGENT: rental rollback failed: " + rentalId, rollback);
                    }
                }
                if (copiesChanged) {
                    try {
                        movie.setAvailableCopies(oldCopies);
                        movieService.updateMovie(movie);
                    } catch (Exception rollback) {
                        getServletContext().log("URGENT: inventory rollback failed: " + movieId, rollback);
                    }
                }
                getServletContext().log("Rental activation failed for payment " + paymentId, failure);
                response.sendError(500, "Rental activation failed. Contact support with your payment ID.");
                return;
            }
            session.removeAttribute("rentalCsrfToken");
            response.sendRedirect(request.getContextPath() + "/rentals");
        }
    }

    // RETURN MOVIE

    private void returnMovie(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {

        String rentalId = request.getParameter("rentalId");


        // Rental ID missing
        if (rentalId == null || rentalId.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/rentals");

            return;
        }

        Rental rental = rentalService.getRentalById(rentalId);

        // RENTAL NOT FOUND

        if (rental == null) {

            response.sendRedirect(request.getContextPath() + "/rentals");

            return;
        }

        // VERIFY RENTAL OWNER

        if (!userId.equals(rental.getUserId())) {

            response.sendRedirect(request.getContextPath() + "/rentals");

            return;
        }

        // PREVENT DOUBLE RETURN

        if (!"RENTED".equalsIgnoreCase(rental.getStatus())) {

            response.sendRedirect(request.getContextPath() + "/rentals");

            return;
        }

        // UPDATE RENTAL STATUS

        rental.setStatus("RETURNED");

        rental.setReturnDate(LocalDate.now().toString());

        rentalService.updateRental(rental);


        // INCREASE AVAILABLE MOVIE COPIES

        Movie movie = movieService.getMovieById(rental.getMovieId());


        if (movie != null) {

            movie.setAvailableCopies(movie.getAvailableCopies() + 1);


            movieService.updateMovie(movie);
        }


        // RECORD RECENTLY WATCHED

        watchHistoryService.recordWatchedMovie(userId, rental.getMovieId());


        // REDIRECT
        response.sendRedirect(request.getContextPath() + "/rentals");
    }
}