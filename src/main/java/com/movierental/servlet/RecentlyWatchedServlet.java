package com.movierental.servlet;

import com.movierental.datastructure.MovieStack;
import com.movierental.model.Movie;
import com.movierental.service.MovieService;
import com.movierental.service.WatchHistoryService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/recently-watched")
public class RecentlyWatchedServlet extends HttpServlet {

    private WatchHistoryService watchHistoryService;



    // INITIALIZATION


    @Override
    public void init() throws ServletException {

        try {

            String movieFilePath =
                    DataPathUtil.getFilePath(
                            "movies.txt"
                    );


            String watchHistoryFilePath =
                    DataPathUtil.getFilePath(
                            "watch_history.txt"
                    );


            MovieService movieService =
                    new MovieService(
                            movieFilePath
                    );


            watchHistoryService =
                    new WatchHistoryService(
                            watchHistoryFilePath,
                            movieService
                    );


            System.out.println(
                    "RecentlyWatchedServlet movies file: "
                            + movieFilePath
            );


            System.out.println(
                    "RecentlyWatchedServlet watch history file: "
                            + watchHistoryFilePath
            );


        } catch (Exception e) {

            throw new ServletException(
                    "Failed to initialize RecentlyWatchedServlet",
                    e
            );
        }
    }



    // GET


    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);



        // LOGIN CHECK


        if (
                session == null
                        ||
                        session.getAttribute(
                                "userId"
                        ) == null
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return;
        }



        // CUSTOMER ACCESS ONLY


        String role =
                (String)
                        session.getAttribute(
                                "role"
                        );


        if (
                !"CUSTOMER"
                        .equalsIgnoreCase(
                                role
                        )
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/admin"
            );

            return;
        }



        // GET LOGGED-IN USER ID


        String userId =
                (String)
                        session.getAttribute(
                                "userId"
                        );



        // BUILD CUSTOM MOVIE STACK


        MovieStack stack =
                watchHistoryService
                        .buildMovieStack(
                                userId
                        );



        // PEEK()
        //
        // Shows the latest movie without removing
        // it from the stack.


        Movie latestMovie =
                stack.peek();



        // RECENTLY WATCHED LIST


        List<Movie> recentlyWatched =
                new ArrayList<>();


        /*
         * pop() removes and returns the
         * newest movie first.
         *
         * Maximum 10 movies are displayed.
         */

        while (
                !stack.isEmpty()
                        &&
                        recentlyWatched.size()
                                < 10
        ) {

            recentlyWatched.add(
                    stack.pop()
            );
        }



        // SEND DATA TO JSP


        request.setAttribute(
                "latestMovie",
                latestMovie
        );


        request.setAttribute(
                "recentlyWatched",
                recentlyWatched
        );



        // FORWARD TO JSP


        request.getRequestDispatcher(
                "/WEB-INF/views/recently-watched.jsp"
        ).forward(
                request,
                response
        );
    }
}