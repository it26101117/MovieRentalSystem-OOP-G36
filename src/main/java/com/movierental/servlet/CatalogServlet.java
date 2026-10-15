package com.movierental.servlet;

import com.movierental.algorithm.BubbleSort;
import com.movierental.model.Movie;
import com.movierental.service.MovieService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/catalog")
public class CatalogServlet extends HttpServlet {

    private MovieService movieService;

    @Override
    public void init() throws ServletException {

        try {

            String movieFilePath =
                    DataPathUtil.getFilePath("movies.txt");

            movieService =
                    new MovieService(movieFilePath);

            System.out.println(
                    "CatalogServlet movies file: "
                            + movieFilePath
            );

        } catch (Exception e) {

            throw new ServletException(
                    "Failed to initialize CatalogServlet",
                    e
            );
        }
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);


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

            response.sendRedirect(request.getContextPath() + "/login");

            return;
        }


        // =====================================================
        // CUSTOMER ACCESS ONLY
        // =====================================================

        String role =
                (String)
                        session.getAttribute("role");


        if (!"CUSTOMER".equalsIgnoreCase(role)) {

            response.sendRedirect(request.getContextPath() + "/admin");

            return;
        }


        // =====================================================
        // GET MOVIES
        // =====================================================

        List<Movie> movies = movieService.getAllMovies();


        // =====================================================
        // BUBBLE SORT
        // =====================================================

        String sort =
                request.getParameter("sort");


        if ("rating-desc".equalsIgnoreCase(sort)) {

            movies = BubbleSort.sortByRatingDescending(movies);

        } else if ("rating-asc".equalsIgnoreCase(sort)) {

            movies = BubbleSort.sortByRatingAscending(movies);
        }


        // =====================================================
        // SEND DATA TO JSP
        // =====================================================

        request.setAttribute("movies", movies);


        request.setAttribute("selectedSort", sort);


        request.getRequestDispatcher("/WEB-INF/views/catalog.jsp")
                .forward(
                request,
                response
        );
    }
}