package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.model.Review;
import com.movierental.model.User;

import com.movierental.service.MovieService;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/reviews")
public class AdminReviewServlet extends HttpServlet {

    private ReviewService reviewService;
    private MovieService movieService;
    private UserService userService;


    // =========================================================
    // INITIALIZATION
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

            String userFilePath =
                    DataPathUtil.getFilePath(
                            "users.txt"
                    );


            reviewService =
                    new ReviewService(
                            reviewFilePath
                    );

            movieService =
                    new MovieService(
                            movieFilePath
                    );

            userService =
                    new UserService(
                            userFilePath
                    );


            System.out.println(
                    "AdminReviewServlet reviews file: "
                            + reviewFilePath
            );

            System.out.println(
                    "AdminReviewServlet movies file: "
                            + movieFilePath
            );

            System.out.println(
                    "AdminReviewServlet users file: "
                            + userFilePath
            );

        } catch (Exception e) {

            throw new ServletException(
                    "Failed to initialize AdminReviewServlet",
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
        // ADMIN SECURITY CHECK
        // =====================================================

        if (
                !checkAdminAccess(
                        session,
                        request,
                        response
                )
        ) {

            return;
        }


        // =====================================================
        // LOAD DATA
        // =====================================================

        List<Review> allReviews =
                reviewService
                        .getAllReviews();


        List<User> users =
                userService
                        .getAllUsers();


        List<Movie> movies =
                movieService
                        .getAllMovies();


        // =====================================================
        // USER LOOKUP MAP
        // =====================================================

        Map<String, User> userMap =
                new HashMap<>();


        for (User user : users) {

            userMap.put(
                    user.getUserId(),
                    user
            );
        }


        // =====================================================
        // MOVIE LOOKUP MAP
        // =====================================================

        Map<String, Movie> movieMap =
                new HashMap<>();


        for (Movie movie : movies) {

            movieMap.put(
                    movie.getMovieId(),
                    movie
            );
        }


        // =====================================================
        // SEARCH PARAMETER
        // =====================================================

        String search =
                request.getParameter(
                        "search"
                );


        if (search == null) {

            search =
                    "";
        }


        String searchText =
                search
                        .trim()
                        .toLowerCase();


        // =====================================================
        // RATING FILTER
        // =====================================================

        String ratingFilter =
                request.getParameter(
                        "rating"
                );


        if (
                ratingFilter == null
                        ||
                        ratingFilter.trim().isEmpty()
        ) {

            ratingFilter =
                    "all";
        }


        // =====================================================
        // FILTER REVIEWS
        // =====================================================

        List<Review> filteredReviews =
                new ArrayList<>();


        for (Review review : allReviews) {

            // =================================================
            // RATING MATCH
            // =================================================

            boolean ratingMatches =
                    true;


            if (
                    !"all".equalsIgnoreCase(
                            ratingFilter
                    )
            ) {

                try {

                    int selectedRating =
                            Integer.parseInt(
                                    ratingFilter
                            );


                    ratingMatches =
                            review.getRating()
                                    == selectedRating;

                } catch (
                        NumberFormatException e
                ) {

                    ratingMatches =
                            true;
                }
            }


            if (!ratingMatches) {

                continue;
            }


            // =================================================
            // SEARCH
            // =================================================

            boolean searchMatches =
                    searchText.isEmpty();


            User user =
                    userMap.get(
                            review.getUserId()
                    );


            Movie movie =
                    movieMap.get(
                            review.getMovieId()
                    );


            if (!searchText.isEmpty()) {

                // ---------------------------------------------
                // REVIEW ID
                // ---------------------------------------------

                if (
                        review.getReviewId() != null
                                &&
                                review.getReviewId()
                                        .toLowerCase()
                                        .contains(
                                                searchText
                                        )
                ) {

                    searchMatches =
                            true;
                }


                // ---------------------------------------------
                // USER ID
                // ---------------------------------------------

                if (
                        review.getUserId() != null
                                &&
                                review.getUserId()
                                        .toLowerCase()
                                        .contains(
                                                searchText
                                        )
                ) {

                    searchMatches =
                            true;
                }


                // ---------------------------------------------
                // MOVIE ID
                // ---------------------------------------------

                if (
                        review.getMovieId() != null
                                &&
                                review.getMovieId()
                                        .toLowerCase()
                                        .contains(
                                                searchText
                                        )
                ) {

                    searchMatches =
                            true;
                }


                // ---------------------------------------------
                // COMMENT
                // ---------------------------------------------

                if (
                        review.getComment() != null
                                &&
                                review.getComment()
                                        .toLowerCase()
                                        .contains(
                                                searchText
                                        )
                ) {

                    searchMatches =
                            true;
                }


                // ---------------------------------------------
                // CUSTOMER NAME / EMAIL
                // ---------------------------------------------

                if (user != null) {

                    if (
                            user.getName() != null
                                    &&
                                    user.getName()
                                            .toLowerCase()
                                            .contains(
                                                    searchText
                                            )
                    ) {

                        searchMatches =
                                true;
                    }


                    if (
                            user.getEmail() != null
                                    &&
                                    user.getEmail()
                                            .toLowerCase()
                                            .contains(
                                                    searchText
                                            )
                    ) {

                        searchMatches =
                                true;
                    }
                }


                // ---------------------------------------------
                // MOVIE TITLE
                // ---------------------------------------------

                if (movie != null) {

                    if (
                            movie.getTitle() != null
                                    &&
                                    movie.getTitle()
                                            .toLowerCase()
                                            .contains(
                                                    searchText
                                            )
                    ) {

                        searchMatches =
                                true;
                    }
                }
            }


            if (searchMatches) {

                filteredReviews.add(
                        review
                );
            }
        }


        // =====================================================
        // REVIEW STATISTICS
        // =====================================================

        int fiveStarCount =
                0;

        int fourStarCount =
                0;

        int threeStarCount =
                0;

        int twoStarCount =
                0;

        int oneStarCount =
                0;


        for (Review review : allReviews) {

            switch (
                    review.getRating()
            ) {

                case 5:

                    fiveStarCount++;
                    break;


                case 4:

                    fourStarCount++;
                    break;


                case 3:

                    threeStarCount++;
                    break;


                case 2:

                    twoStarCount++;
                    break;


                case 1:

                    oneStarCount++;
                    break;


                default:

                    break;
            }
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute(
                "reviews",
                filteredReviews
        );


        request.setAttribute(
                "userMap",
                userMap
        );


        request.setAttribute(
                "movieMap",
                movieMap
        );


        request.setAttribute(
                "search",
                search
        );


        request.setAttribute(
                "selectedRating",
                ratingFilter
        );


        request.setAttribute(
                "totalReviewCount",
                allReviews.size()
        );


        request.setAttribute(
                "filteredCount",
                filteredReviews.size()
        );


        request.setAttribute(
                "fiveStarCount",
                fiveStarCount
        );


        request.setAttribute(
                "fourStarCount",
                fourStarCount
        );


        request.setAttribute(
                "threeStarCount",
                threeStarCount
        );


        request.setAttribute(
                "twoStarCount",
                twoStarCount
        );


        request.setAttribute(
                "oneStarCount",
                oneStarCount
        );


        // =====================================================
        // FORWARD TO JSP
        // =====================================================

        request.getRequestDispatcher(
                "/WEB-INF/views/admin-reviews.jsp"
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


        // =====================================================
        // ADMIN SECURITY CHECK
        // =====================================================

        if (
                !checkAdminAccess(
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
        // DELETE REVIEW
        // =====================================================

        if (
                "delete".equalsIgnoreCase(
                        action
                )
        ) {

            deleteReview(
                    request,
                    response
            );

            return;
        }


        // =====================================================
        // INVALID ACTION
        // =====================================================

        response.sendRedirect(
                request.getContextPath()
                        + "/admin/reviews"
        );
    }


    // =========================================================
    // DELETE REVIEW
    // =========================================================

    private void deleteReview(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        String reviewId =
                request.getParameter(
                        "reviewId"
                );


        if (
                reviewId == null
                        ||
                        reviewId.trim().isEmpty()
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/admin/reviews"
            );

            return;
        }


        Review reviewToDelete =
                null;


        List<Review> reviews =
                reviewService
                        .getAllReviews();


        for (Review review : reviews) {

            if (
                    review.getReviewId() != null
                            &&
                            review.getReviewId()
                                    .equals(
                                            reviewId
                                    )
            ) {

                reviewToDelete =
                        review;

                break;
            }
        }


        // =====================================================
        // DELETE IF FOUND
        // =====================================================

        if (reviewToDelete != null) {

            String movieId =
                    reviewToDelete
                            .getMovieId();


            boolean deleted =
                    reviewService
                            .deleteReview(
                                    reviewId
                            );


            // Recalculate movie rating after deletion
            if (deleted) {

                updateMovieAverageRating(
                        movieId
                );
            }
        }


        response.sendRedirect(
                request.getContextPath()
                        + "/admin/reviews"
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


        double averageRating =
                reviewService
                        .calculateAverageRating(
                                movieId
                        );


        movie.setRating(
                averageRating
        );


        movieService
                .updateMovie(
                        movie
                );
    }


    // =========================================================
    // ADMIN SECURITY
    // =========================================================

    private boolean checkAdminAccess(
            HttpSession session,
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        // =====================================================
        // LOGIN CHECK
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



        String role =
                (String)
                        session.getAttribute(
                                "role"
                        );


        if (
                role == null
                        ||
                        !"ADMIN".equalsIgnoreCase(
                                role
                        )
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog"
            );
            return false;
        }

        return true;
    }
}