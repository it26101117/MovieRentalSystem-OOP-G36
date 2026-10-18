package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Review;

import com.movierental.service.MovieService;
import com.movierental.service.RentalService;
import com.movierental.service.ReviewService;

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


@WebServlet("/reviews")
public class ReviewServlet extends HttpServlet {

    private ReviewService reviewService;
    private MovieService movieService;
    private RentalService rentalService;


    // =========================================================
    // INITIALIZE
    // =========================================================

    @Override
    public void init() throws ServletException {

        try {

            String reviewFilePath =
                    DataPathUtil.getFilePath(
                            "reviews.txt"
                    );


            String movieFilePath =
                    DataPathUtil.getFilePath(
                            "movies.txt"
                    );


            String rentalFilePath =
                    DataPathUtil.getFilePath(
                            "rentals.txt"
                    );


            reviewService =
                    new ReviewService(
                            reviewFilePath
                    );


            movieService =
                    new MovieService(
                            movieFilePath
                    );


            rentalService =
                    new RentalService(
                            rentalFilePath
                    );


            System.out.println(
                    "ReviewServlet reviews file: "
                            + reviewFilePath
            );


            System.out.println(
                    "ReviewServlet movies file: "
                            + movieFilePath
            );


            System.out.println(
                    "ReviewServlet rentals file: "
                            + rentalFilePath
            );


        } catch (Exception e) {

            throw new ServletException(
                    "Failed to initialize ReviewServlet",
                    e
            );
        }
    }


    // =========================================================
    // GET
    // =========================================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {


        HttpSession session =
                request.getSession(false);


        // =====================================================
        // CUSTOMER ACCESS CHECK
        // =====================================================

        if (
                !checkCustomerAccess(
                        session,
                        request,
                        response
                )
        ) {

            return;
        }


        // =====================================================
        // MOVIE ID
        // =====================================================

        String movieId =
                request.getParameter(
                        "movieId"
                );


        if (
                movieId == null
                        ||
                        movieId.trim()
                                .isEmpty()
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog"
            );

            return;
        }


        // =====================================================
        // FIND MOVIE
        // =====================================================

        Movie movie =
                movieService
                        .getMovieById(
                                movieId
                        );


        if (movie == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog?error=notfound"
            );

            return;
        }


        // =====================================================
        // CURRENT USER
        // =====================================================

        String userId =
                (String)
                        session.getAttribute(
                                "userId"
                        );


        // =====================================================
        // REVIEW ELIGIBILITY
        // =====================================================

        boolean canReview =
                rentalService
                        .hasReturnedRental(
                                userId,
                                movieId
                        );


        // =====================================================
        // CURRENT USER REVIEW
        // =====================================================

        Review userReview =
                reviewService
                        .getUserReviewForMovie(
                                userId,
                                movieId
                        );


        // =====================================================
        // ALL REVIEWS FOR MOVIE
        // =====================================================

        List<Review> reviews =
                reviewService
                        .getReviewsByMovie(
                                movieId
                        );


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
                "movie",
                movie
        );


        request.setAttribute(
                "reviews",
                reviews
        );


        request.setAttribute(
                "userReview",
                userReview
        );


        request.setAttribute(
                "canReview",
                canReview
        );


        request.getRequestDispatcher(
                "/WEB-INF/views/reviews.jsp"
        ).forward(
                request,
                response
        );
    }


    // =========================================================
    // POST
    // =========================================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {


        request.setCharacterEncoding(
                "UTF-8"
        );


        HttpSession session =
                request.getSession(false);


        if (
                !checkCustomerAccess(
                        session,
                        request,
                        response
                )
        ) {

            return;
        }


        String action =
                request.getParameter(
                        "action"
                );


        // =====================================================
        // SAVE / UPDATE
        // =====================================================

        if (
                "save".equalsIgnoreCase(
                        action
                )
        ) {

            saveReview(
                    request,
                    response,
                    session
            );

            return;
        }


        // =====================================================
        // DELETE
        // =====================================================

        if (
                "delete".equalsIgnoreCase(
                        action
                )
        ) {

            deleteReview(
                    request,
                    response,
                    session
            );

            return;
        }


        response.sendRedirect(
                request.getContextPath()
                        + "/catalog"
        );
    }


    // =========================================================
    // SAVE / UPDATE REVIEW
    // =========================================================

    private void saveReview(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session
    ) throws IOException {


        String userId =
                (String)
                        session.getAttribute(
                                "userId"
                        );


        String movieId =
                request.getParameter(
                        "movieId"
                );


        // =====================================================
        // MOVIE ID VALIDATION
        // =====================================================

        if (
                movieId == null
                        ||
                        movieId.trim()
                                .isEmpty()
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog"
            );

            return;
        }


        // =====================================================
        // CHECK MOVIE
        // =====================================================

        Movie movie =
                movieService
                        .getMovieById(
                                movieId
                        );


        if (movie == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog?error=notfound"
            );

            return;
        }


        // =====================================================
        // CUSTOMER MUST HAVE RETURNED MOVIE
        // =====================================================

        boolean canReview =
                rentalService
                        .hasReturnedRental(
                                userId,
                                movieId
                        );


        if (!canReview) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/reviews?movieId="
                            + movieId
                            + "&error=noteligible"
            );

            return;
        }


        // =====================================================
        // RATING
        // =====================================================

        int rating;


        try {

            rating =
                    Integer.parseInt(
                            request.getParameter(
                                    "rating"
                            )
                    );


        } catch (
                NumberFormatException e
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/reviews?movieId="
                            + movieId
                            + "&error=rating"
            );

            return;
        }


        if (
                rating < 1
                        ||
                        rating > 5
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/reviews?movieId="
                            + movieId
                            + "&error=rating"
            );

            return;
        }


        // =====================================================
        // COMMENT
        // =====================================================

        String comment =
                request.getParameter(
                        "comment"
                );


        if (comment == null) {

            comment = "";
        }


        comment =
                comment.trim();


        if (comment.isEmpty()) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/reviews?movieId="
                            + movieId
                            + "&error=comment"
            );

            return;
        }


        if (
                comment.length()
                        > 500
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/reviews?movieId="
                            + movieId
                            + "&error=commentlength"
            );

            return;
        }


        /*
         * Text files use |
         * as the field separator.
         */
        comment =
                comment.replace(
                        "|",
                        " "
                );


        // =====================================================
        // EXISTING REVIEW
        // =====================================================

        Review existingReview =
                reviewService
                        .getUserReviewForMovie(
                                userId,
                                movieId
                        );


        // =====================================================
        // CREATE NEW REVIEW
        // =====================================================

        if (existingReview == null) {


            Review review =
                    new Review(
                            reviewService
                                    .generateNextReviewId(),

                            userId,

                            movieId,

                            rating,

                            comment,

                            LocalDate.now()
                                    .toString()
                    );


            reviewService
                    .addReview(
                            review
                    );


        } else {


            // =================================================
            // UPDATE EXISTING REVIEW
            // =================================================

            existingReview
                    .setRating(
                            rating
                    );


            existingReview
                    .setComment(
                            comment
                    );


            existingReview
                    .setReviewDate(
                            LocalDate.now()
                                    .toString()
                    );


            reviewService
                    .updateReview(
                            existingReview
                    );
        }


        // =====================================================
        // RECALCULATE MOVIE RATING
        // =====================================================

        updateMovieAverageRating(
                movieId
        );


        response.sendRedirect(
                request.getContextPath()
                        + "/reviews?movieId="
                        + movieId
                        + "&success=saved"
        );
    }


    // =========================================================
    // DELETE CUSTOMER REVIEW
    // =========================================================

    private void deleteReview(
            HttpServletRequest request,
            HttpServletResponse response,
            HttpSession session
    ) throws IOException {


        String userId =
                (String)
                        session.getAttribute(
                                "userId"
                        );


        String movieId =
                request.getParameter(
                        "movieId"
                );


        if (
                movieId == null
                        ||
                        movieId.trim()
                                .isEmpty()
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog"
            );

            return;
        }


        // =====================================================
        // FIND CURRENT USER'S REVIEW
        // =====================================================

        Review review =
                reviewService
                        .getUserReviewForMovie(
                                userId,
                                movieId
                        );


        if (review != null) {


            reviewService
                    .deleteReview(
                            review.getReviewId()
                    );


            updateMovieAverageRating(
                    movieId
            );
        }


        response.sendRedirect(
                request.getContextPath()
                        + "/reviews?movieId="
                        + movieId
                        + "&success=deleted"
        );
    }


    // =========================================================
    // UPDATE MOVIE AVERAGE RATING
    // =========================================================

    private void updateMovieAverageRating(
            String movieId
    ) throws IOException {


        Movie movie =
                movieService
                        .getMovieById(
                                movieId
                        );


        if (movie == null) {

            return;
        }


        double average =
                reviewService
                        .calculateAverageRating(
                                movieId
                        );


        movie.setRating(
                average
        );


        movieService
                .updateMovie(
                        movie
                );
    }


    // =========================================================
    // CUSTOMER SECURITY
    // =========================================================

    private boolean checkCustomerAccess(
            HttpSession session,
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {


        // =====================================================
        // NOT LOGGED IN
        // =====================================================

        if (
                session == null
                        ||
                        session.getAttribute(
                                "loggedUser"
                        ) == null
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return false;
        }


        // =====================================================
        // ROLE CHECK
        // =====================================================

        String role =
                (String)
                        session.getAttribute(
                                "role"
                        );


        if (
                role == null
                        ||
                        !"CUSTOMER".equalsIgnoreCase(
                                role
                        )
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/admin"
            );

            return false;
        }


        // =====================================================
        // USER ID CHECK
        // =====================================================

        if (
                session.getAttribute(
                        "userId"
                ) == null
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return false;
        }


        return true;
    }
}