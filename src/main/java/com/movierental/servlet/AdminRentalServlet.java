package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Rental;
import com.movierental.model.User;

import com.movierental.service.MovieService;
import com.movierental.service.RentalService;
import com.movierental.service.UserService;

import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/rentals")
public class AdminRentalServlet extends HttpServlet {

    private RentalService rentalService;
    private MovieService movieService;
    private UserService userService;

    // INITIALIZATION

    @Override
    public void init() throws ServletException {

        try {
            String rentalFilePath = DataPathUtil.getFilePath("rentals.txt");
            String movieFilePath =DataPathUtil.getFilePath("movies.txt" );
            String userFilePath =DataPathUtil.getFilePath("users.txt");

            rentalService =new RentalService(rentalFilePath );

            movieService =new MovieService(movieFilePath);

            userService =new UserService( userFilePath );

            System.out.println("AdminRentalServlet rentals file: " + rentalFilePath);

            System.out.println("AdminRentalServlet movies file: "  + movieFilePath );

            System.out.println("AdminRentalServlet users file: " + userFilePath);


        } catch (Exception e) {
            throw new ServletException("Failed to initialize AdminRentalServlet", e);
        }
    }


    // GET

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session =request.getSession(false);


        if (session == null||session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath()+ "/login");
            return;
        }

        // ADMIN ACCESS CHECK

        String role = (String)session.getAttribute("role");
        if ( role == null||!"ADMIN".equalsIgnoreCase(role)) {

            response.sendRedirect(request.getContextPath()+ "/catalog" );
            return;
        }

        List<Rental> allRentals =rentalService.getAllRentals();

        List<User> allUsers = userService .getAllUsers();

        List<Movie> allMovies = movieService.getAllMovies();


        // CREATE USER LOOKUP MAP
        Map<String, User> userMap =new HashMap<>();
        for (User user : allUsers) {

            userMap.put( user.getUserId(),user);

        }

        // CREATE MOVIE LOOKUP MAP


        Map<String, Movie> movieMap =new HashMap<>();

        for (Movie movie : allMovies) {
            movieMap.put(movie.getMovieId(), movie);
        }


        int activeRentalCount =0;

        int returnedRentalCount =0;

        for (Rental rental : allRentals) {

            if ("RENTED".equalsIgnoreCase(rental.getStatus())) {
                activeRentalCount++;

            } else if ("RETURNED".equalsIgnoreCase( rental.getStatus())) {
                returnedRentalCount++;
            }
        }

        String selectedStatus = request.getParameter("status" );

        if (selectedStatus == null|| selectedStatus.trim().isEmpty()) {
            selectedStatus ="all";

        }

        String search =request.getParameter("search");

        if (search == null) {

            search = "";

        }
        String searchText = search.trim().toLowerCase();

        // FILTER RENTALS
        List<Rental> filteredRentals =new ArrayList<>();

        for (Rental rental : allRentals) {

            // STATUS FILTER

            boolean statusMatches;
            if ("all".equalsIgnoreCase( selectedStatus)) {
                statusMatches = true;

            } else {
                statusMatches =rental.getStatus() != null &&rental.getStatus().equalsIgnoreCase( selectedStatus);
            }


            if (!statusMatches) {
                continue;
            }


            User user =userMap.get( rental.getUserId() );

            Movie movie =movieMap.get( rental.getMovieId());

            // SEARCH MATCH
            boolean searchMatches =searchText.isEmpty();

            if (!searchText.isEmpty()) {

                if (rental.getRentalId() != null && rental.getRentalId().toLowerCase().contains(searchText)) {

                    searchMatches =true;

                }

                if (rental.getUserId() != null && rental.getUserId().toLowerCase().contains(searchText)) {

                    searchMatches = true;
                }
                //get movie ID
                if (rental.getMovieId() != null && rental.getMovieId().toLowerCase().contains(searchText)) {

                    searchMatches =true;

                }


                // CUSTOMER NAME / EMAIL
                if (user != null) {
                    if (user.getName() != null && user.getName().toLowerCase().contains(searchText)) {
                        searchMatches =true;

                    }

                    if (user.getEmail() != null && user.getEmail().toLowerCase().contains(searchText)) {

                        searchMatches =true;

                    }
                }

                // MOVIE TITLE
                if (movie != null) {
                    if (movie.getTitle() != null && movie.getTitle().toLowerCase().contains(searchText)) {

                        searchMatches =true;

                    }
                }
            }

            // ADD MATCHING RENTAL
            if (searchMatches) {git
                filteredRentals.add(rental);
            }
        }

        request.setAttribute("rentals",filteredRentals);
        request.setAttribute("userMap", userMap);
        request.setAttribute("movieMap",movieMap );
        request.setAttribute("selectedStatus",selectedStatus);
        request.setAttribute("search",search);
        request.setAttribute("totalRentalCount", allRentals.size());
        request.setAttribute("activeRentalCount", activeRentalCount);
        request.setAttribute("returnedRentalCount", returnedRentalCount);
        request.setAttribute("filteredCount", filteredRentals.size());
        request.getRequestDispatcher("/WEB-INF/views/admin-rentals.jsp"  )

        .forward(request,response);

    }
}