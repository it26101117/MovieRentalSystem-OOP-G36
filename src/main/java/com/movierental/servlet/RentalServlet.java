package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Rental;
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
import java.util.List;

@WebServlet("/rentals")
public class RentalServlet extends HttpServlet {

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

    private void rentMovie(HttpServletRequest request, HttpServletResponse response, String userId) throws IOException {

        String movieId = request.getParameter("movieId");


        // Movie ID missing
        if (movieId == null || movieId.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/catalog?error=notfound");

            return;
        }


        Movie movie = movieService.getMovieById(movieId);


        // Movie doesn't exist
        if (movie == null) {
            response.sendRedirect(request.getContextPath() + "/catalog?error=notfound");

            return;
        }


        // CHECK AVAILABLE COPIES

        if (movie.getAvailableCopies() <= 0) {

            response.sendRedirect(request.getContextPath() + "/catalog?error=unavailable");

            return;
        }


        // PREVENT DUPLICATE ACTIVE RENTAL

        boolean alreadyRented = rentalService.hasActiveRental(userId, movieId);

        if (alreadyRented) {

            response.sendRedirect(request.getContextPath() + "/catalog?error=alreadyrented");

            return;
        }



        // GENERATE RENTAL ID

        String rentalId = rentalService.generateNextRentalId();


        // CREATE RENTAL OBJECT

        Rental rental = new Rental(rentalId, userId, movieId, LocalDate.now().toString(), "", "RENTED");


        // SAVE RENTAL

        rentalService.addRental(rental);


        // REDUCE MOVIE COPIES

        movie.setAvailableCopies(movie.getAvailableCopies() - 1);


        movieService.updateMovie(movie);



        // REDIRECT TO MY RENTALS

        response.sendRedirect(request.getContextPath() + "/rentals");
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