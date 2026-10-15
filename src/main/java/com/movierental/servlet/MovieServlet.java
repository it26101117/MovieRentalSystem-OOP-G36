package com.movierental.servlet;

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

@WebServlet("/movies")
public class MovieServlet extends HttpServlet {

    private MovieService movieService;
    // INITIALIZATION
    @Override
    public void init() throws ServletException {

        try {
            String movieFilePath = DataPathUtil.getFilePath("movies.txt");

            movieService = new MovieService(movieFilePath);

            System.out.println("MovieServlet movies file: " + movieFilePath);

        } catch (Exception e) {

            throw new ServletException(
                    "Failed to initialize MovieServlet",
                    e
            );
        }
    }

    // GET
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check admin access
        if (!checkAdminAccess(request, response)) {
            return;
        }

        String action = request.getParameter("action");

        if (action == null) {
            action = "list";
        }
        switch (action) {
            case "add": showAddForm(request, response);
                break;
            case "edit":

                showEditForm(request, response);

                break;


            case "list":

            default:
                listMovies(request, response);
                break;
        }
    }

    // POST
    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        // Check admin access
        if (!checkAdminAccess(request, response)) {
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if (action == null) {

            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }
        switch (action) {
            case "add": addMovie(request, response);
            break;
            case "update":
                updateMovie(request, response);
                break;
            case "delete": deleteMovie(request, response);
            break;
            default:
                response.sendRedirect(request.getContextPath() + "/movies");
                break;
        }
    }
    // ADMIN ACCESS CHECK

    private boolean checkAdminAccess(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        HttpSession session = request.getSession(false);

        // Not logged in
        if (session == null || session.getAttribute("loggedUser") == null) {

            response.sendRedirect(request.getContextPath() + "/login");

            return false;
        }
        String role = (String) session.getAttribute("role");

        // Logged in but not admin
        if (role == null || "ADMIN".equalsIgnoreCase(role)) {

            response.sendRedirect(request.getContextPath() + "/catalog");

            return false;
        }
        return true;
    }
    // LIST MOVIES

    private void listMovies(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Movie> movies = movieService.getAllMovies();


        request.setAttribute("movies", movies);


        request.getRequestDispatcher("/WEB-INF/views/movies.jsp")
                .forward(request, response);
    }
    // SHOW ADD FORM

    private void showAddForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/movie-form.jsp")
                .forward(request, response);
    }
    // SHOW EDIT FORM

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String movieId = request.getParameter("id");

        if (movieId == null || movieId.trim().isEmpty()) {

            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        Movie movie = movieService.getMovieById(movieId);
        if (movie == null) {

            response.sendRedirect(request.getContextPath() + "/movies");

            return;
        }
        request.setAttribute("movie", movie);
        request.getRequestDispatcher("/WEB-INF/views/movie-form.jsp")
                .forward(request, response);
    }
    // ADD MOVIE
    private void addMovie(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            String movieId = movieService.generateNextMovieId();


            Movie movie = createMovieFromRequest(request, movieId);


            movieService.addMovie(movie);


            response.sendRedirect(request.getContextPath() + "/movies");

        } catch (NumberFormatException e) {

            request.setAttribute("error", "Please enter valid numeric values for year, price, rating and available copies.");


            request.getRequestDispatcher("/WEB-INF/views/movie-form.jsp")
                    .forward(request, response);
        }
    }

    // UPDATE MOVIE
    private void updateMovie(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String movieId = request.getParameter("movieId");


            if (movieId == null || movieId.trim().isEmpty()) {

                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }
            Movie movie = createMovieFromRequest(request, movieId);
            movieService.updateMovie(movie);

            response.sendRedirect(request.getContextPath() + "/movies");

        } catch (NumberFormatException e) {

            request.setAttribute("error", "Please enter valid numeric values.");

            request.getRequestDispatcher("/WEB-INF/views/movie-form.jsp")
                    .forward(request, response);
        }
    }

    // DELETE MOVIE

    private void deleteMovie(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String movieId = request.getParameter("movieId");


        if (movieId != null && !movieId.trim().isEmpty()) {

            movieService.deleteMovie(movieId);
        }


        response.sendRedirect(request.getContextPath() + "/movies");
    }

    // CREATE MOVIE OBJECT FROM FORM

    private Movie createMovieFromRequest(HttpServletRequest request, String movieId) {

        String title = request.getParameter("title");


        String genre = request.getParameter("genre");

        int releaseYear = Integer.parseInt(request.getParameter("releaseYear"));


        double rentalPrice = Double.parseDouble(request.getParameter("rentalPrice"));

        double rating = Double.parseDouble(request.getParameter("rating"));


        int availableCopies =Integer.parseInt(request.getParameter("availableCopies"));


        String description = request.getParameter("description");


        return new Movie(movieId, title, genre, releaseYear, rentalPrice, rating, availableCopies, description);
    }
}