package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Rental;
import com.movierental.model.Review;
import com.movierental.model.User;

import com.movierental.service.MovieService;
import com.movierental.service.RentalService;
import com.movierental.service.ReviewService;
import com.movierental.service.UserService;

import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {
    private MovieService movieService;
    private UserService userService;
    private RentalService rentalService;
    private ReviewService reviewService;

    @Override
    public void init() throws ServletException {
        try {
            String movieFilePath =DataPathUtil.getFilePath("movies.txt");
            String userFilePath = DataPathUtil.getFilePath("users.txt");
            String rentalFilePath = DataPathUtil.getFilePath( "rentals.txt");
            String reviewFilePath =DataPathUtil.getFilePath("reviews.txt");

            movieService =new MovieService( movieFilePath );
            userService =  new UserService( userFilePath );
            rentalService =  new RentalService(rentalFilePath);
            reviewService = new ReviewService(reviewFilePath);

            System.out.println("AdminDashboardServlet movies file: " + movieFilePath);
            System.out.println("AdminDashboardServlet users file: "+ userFilePath );
            System.out.println("AdminDashboardServlet rentals file: " + rentalFilePath );
            System.out.println("AdminDashboardServlet reviews file: "+ reviewFilePath );



        } catch (Exception e) {
            throw new ServletException("Failed to initialize AdminDashboardServlet", e);

        }
    }
    //Getters
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)


     throws ServletException, IOException {
        HttpSession session =request.getSession(false);


        //Login check
        if ( session == null|| session.getAttribute("loggedUser" ) == null) {
            response.sendRedirect(request.getContextPath() + "/login" );
            return;
        }

        //Check Admin Access
        String role = (String)session.getAttribute("role" );

        if (role == null|| !"ADMIN".equalsIgnoreCase(role)){
            response.sendRedirect(request.getContextPath() + "/catalog");
            return;
        }

        List<Movie> movies =movieService.getAllMovies();

        List<User> users = userService .getAllUsers();

        List<Rental> rentals =rentalService.getAllRentals();

        List<Review> reviews =reviewService.getAllReviews();


        //Movie Count
        int movieCount = movies.size();

        //Customer Count
        int customerCount = 0;

        for (User user : users) {

            if ("CUSTOMER" .equalsIgnoreCase( user.getRole() )) {
                customerCount++;
            }
        }


       //Rental Count
        int activeRentalCount =0;
        int returnedRentalCount =  0;

        for (Rental rental : rentals) {

            if ("RENTED".equalsIgnoreCase(rental.getStatus() )) {
                activeRentalCount++;

            } else if ("RETURNED" .equalsIgnoreCase( rental.getStatus())) {
                returnedRentalCount++;
            }
        }

        int totalRentalCount =rentals.size();
        int reviewCount = reviews.size();
        int availableCopies = 0;

        for (Movie movie : movies) {
            availableCopies +=movie.getAvailableCopies();
        }
        request.setAttribute("movieCount", movieCount );
        request.setAttribute("customerCount",customerCount);
        request.setAttribute("activeRentalCount",activeRentalCount );
        request.setAttribute("returnedRentalCount",returnedRentalCount);
        request.setAttribute("totalRentalCount",totalRentalCount );
        request.setAttribute("reviewCount",reviewCount);
        request.setAttribute("availableCopies",availableCopies);
        request.getRequestDispatcher("/WEB-INF/views/admin-dashboard.jsp")
        .forward(request,response);

    }
}