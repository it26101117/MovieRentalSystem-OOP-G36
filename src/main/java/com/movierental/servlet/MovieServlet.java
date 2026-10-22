package com.movierental.servlet;

import com.movierental.model.Movie;
import com.movierental.service.MovieService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

@WebServlet("/movies")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 5 * 1024 * 1024,
        maxRequestSize = 6 * 1024 * 1024
)
public class MovieServlet extends HttpServlet {
    private MovieService movieService;
    private Path posterDirectory;

    @Override
    public void init() throws ServletException {
        try {String movieFilePath = DataPathUtil.getFilePath("movies.txt");
            movieService = new MovieService(movieFilePath);
            posterDirectory = Paths.get(System.getProperty("user.dir"), "data", "posters");
            Files.createDirectories(posterDirectory);
            System.out.println("MovieServlet movies file: " + movieFilePath);
            System.out.println("Movie poster folder: " + posterDirectory.toAbsolutePath());
        } catch (Exception e) {
            throw new ServletException("Failed to initialize MovieServlet", e);
        }
    }

    // GET

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        if (
                !checkAdminAccess(
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
        if (action == null) {
            action = "list";
        }
        switch (action) {
            case "add":
                showAddForm(
                        request,
                        response
                );
                break;
            case "edit":
                showEditForm(
                        request,
                        response
                );
                break;
            case "list":
            default:
                listMovies(
                        request,
                        response
                );
                break;
        }
    }

    // POST

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        if (
                !checkAdminAccess(
                        request,
                        response
                )
        ) {
            return;
        }
        request.setCharacterEncoding(
                "UTF-8"
        );
        String action =
                request.getParameter(
                        "action"
                );
        if (action == null) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/movies"
            );
            return;
        }
        switch (action) {
            case "add":
                addMovie(
                        request,
                        response
                );
                break;
            case "update":
                updateMovie(
                        request,
                        response
                );
                break;
            case "delete":
                deleteMovie(
                        request,
                        response
                );
                break;
            default:
                response.sendRedirect(
                        request.getContextPath()
                                + "/movies"
                );
                break;
        }
    }


    // SECURITY

    private boolean checkAdminAccess(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {
        HttpSession session =
                request.getSession(false);
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

    // LIST MOVIES
    private void listMovies(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        List<Movie> movies =
                movieService.getAllMovies();
        request.setAttribute(
                "movies",
                movies
        );
        request.getRequestDispatcher(
                "/WEB-INF/views/movies.jsp"
        ).forward(
                request,
                response
        );
    }


    // ADD FORM

    private void showAddForm(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        request.getRequestDispatcher(
                "/WEB-INF/views/movie-form.jsp"
        ).forward(
                request,
                response
        );
    }


    // EDIT FORM
    private void showEditForm(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        String movieId =
                request.getParameter(
                        "id"
                );
        if (
                movieId == null
                        ||
                        movieId.trim()
                                .isEmpty()
        ) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/movies"
            );
            return;
        }
        Movie movie =
                movieService.getMovieById(
                        movieId
                );
        if (movie == null) {
            response.sendRedirect(
                    request.getContextPath()
                            + "/movies"
            );
            return;
        }
        request.setAttribute(
                "movie",
                movie
        );
        request.getRequestDispatcher(
                "/WEB-INF/views/movie-form.jsp"
        ).forward(
                request,
                response
        );
    }

    // ADD MOVIE
    private void addMovie(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        try {
            String movieId =
                    movieService
                            .generateNextMovieId();
            Movie movie =
                    createMovieFromRequest(
                            request,
                            movieId
                    );
            // Save movie information first
            movieService.addMovie(
                    movie
            );
            // Save poster if selected
            savePoster(
                    request,
                    movieId
            );
            response.sendRedirect(
                    request.getContextPath()
                            + "/movies"
            );
        } catch (
                NumberFormatException e
        ) {
            request.setAttribute(
                    "error",
                    "Please enter valid numeric values."
            );
            request.getRequestDispatcher(
                    "/WEB-INF/views/movie-form.jsp"
            ).forward(
                    request,
                    response
            );
        } catch (
                IllegalArgumentException e
        ) {
            request.setAttribute(
                    "error",
                    e.getMessage()
            );
            request.getRequestDispatcher(
                    "/WEB-INF/views/movie-form.jsp"
            ).forward(
                    request,
                    response
            );
        }
    }

    // UPDATE MOVIE
    private void updateMovie(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {
        try {
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
                                + "/movies"
                );
                return;
            }
            Movie movie =
                    createMovieFromRequest(
                            request,
                            movieId
                    );
            movieService.updateMovie(
                    movie
            );
            /*
             * If no new file was selected,
             * savePoster() does nothing.
             *
             * Therefore the old poster stays.
             */
            savePoster(
                    request,
                    movieId
            );
            response.sendRedirect(
                    request.getContextPath()
                            + "/movies"
            );
        } catch (
                NumberFormatException e
        ) {
            request.setAttribute(
                    "error",
                    "Please enter valid numeric values."
            );
            reloadMovieForError(
                    request
            );
            request.getRequestDispatcher(
                    "/WEB-INF/views/movie-form.jsp"
            ).forward(
                    request,
                    response
            );
        } catch (
                IllegalArgumentException e
        ) {
            request.setAttribute(
                    "error",
                    e.getMessage()
            );
            reloadMovieForError(
                    request
            );
            request.getRequestDispatcher(
                    "/WEB-INF/views/movie-form.jsp"
            ).forward(
                    request,
                    response
            );
        }
    }


    // DELETE MOVIE
    private void deleteMovie(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {
        String movieId =
                request.getParameter(
                        "movieId"
                );
        if (
                movieId != null
                        &&
                        !movieId.trim()
                                .isEmpty()
        ) {
            movieService.deleteMovie(
                    movieId
            );
            deleteExistingPosters(
                    movieId
            );
        }
        response.sendRedirect(
                request.getContextPath()
                        + "/movies"
        );
    }


    // CREATE MOVIE FROM FORM

    private Movie createMovieFromRequest(
            HttpServletRequest request,
            String movieId
    ) {
        String title =
                request.getParameter(
                        "title"
                );
        String genre =
                request.getParameter(
                        "genre"
                );
        int releaseYear =
                Integer.parseInt(
                        request.getParameter(
                                "releaseYear"
                        )
                );
        double rentalPrice =
                Double.parseDouble(
                        request.getParameter(
                                "rentalPrice"
                        )
                );
        double rating =
                Double.parseDouble(
                        request.getParameter(
                                "rating"
                        )
                );
        int availableCopies =
                Integer.parseInt(
                        request.getParameter(
                                "availableCopies"
                        )
                );
        String description =
                request.getParameter(
                        "description"
                );
        return new Movie(
                movieId,
                title,
                genre,
                releaseYear,
                rentalPrice,
                rating,
                availableCopies,
                description
        );
    }


    // SAVE POSTER
    private void savePoster(
            HttpServletRequest request,
            String movieId
    ) throws IOException, ServletException {
        Part posterPart =
                request.getPart(
                        "poster"
                );
        /*
         * No image selected.
         *
         * Important for update:
         * old poster should remain.
         */
        if (
                posterPart == null
                        ||
                        posterPart.getSize() == 0
        ) {
            return;
        }
        String contentType =
                posterPart.getContentType();
        String extension;
        if (
                "image/jpeg".equalsIgnoreCase(
                        contentType
                )
        ) {
            extension = ".jpg";
        } else if (
                "image/png".equalsIgnoreCase(
                        contentType
                )
        ) {
            extension = ".png";
        } else if (
                "image/webp".equalsIgnoreCase(
                        contentType
                )
        ) {
            extension = ".webp";
        } else {
            throw new IllegalArgumentException(
                    "Poster must be JPG, PNG or WEBP."
            );
        }
        if (
                posterPart.getSize()
                        > 5 * 1024 * 1024
        ) {
            throw new IllegalArgumentException(
                    "Poster image must be smaller than 5 MB."
            );
        }
        /*
         * Remove any old poster first.
         *
         * Example:
         * M001.jpg -> replacing with M001.png
         */
        deleteExistingPosters(
                movieId
        );
        Path targetFile =
                posterDirectory.resolve(
                        movieId + extension
                );
        try (
                var inputStream =
                        posterPart
                                .getInputStream()
        ) {
            Files.copy(
                    inputStream,
                    targetFile
            );
        }
    }

    // DELETE EXISTING POSTER

    private void deleteExistingPosters(
            String movieId
    ) throws IOException {
        String[] extensions = {
                ".jpg",
                ".jpeg",
                ".png",
                ".webp"
        };
        for (
                String extension
                : extensions
        ) {
            Path file =
                    posterDirectory.resolve(
                            movieId
                                    + extension
                    );
            Files.deleteIfExists(
                    file
            );
        }
    }


    // RELOAD MOVIE WHEN UPDATE ERROR OCCURS

    private void reloadMovieForError(
            HttpServletRequest request
    ) throws IOException {
        String movieId =
                request.getParameter(
                        "movieId"
                );
        if (
                movieId != null
                        &&
                        !movieId.trim()
                                .isEmpty()
        ) {
            Movie movie =
                    movieService
                            .getMovieById(
                                    movieId
                            );
            request.setAttribute(
                    "movie",
                    movie
            );
        }
    }
}