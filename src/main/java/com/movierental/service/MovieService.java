package com.movierental.service;

import com.movierental.model.Movie;
import com.movierental.util.FileHandler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MovieService {
    private final String movieFilePath;
    public MovieService(String movieFilePath) {
        this.movieFilePath = movieFilePath;
    }

    // CREATE
    public void addMovie(Movie movie) throws IOException {
        FileHandler.appendLine( movieFilePath,convertMovieToLine(movie) );
    }

    // READ
    public List<Movie> getAllMovies() throws IOException {
        List<String> lines =FileHandler.readAllLines(movieFilePath);
        List<Movie> movies = new ArrayList<>();

        for (String line : lines) {
            if (line.trim().isEmpty()) {
                continue;
            }
            Movie movie = convertLineToMovie(line);
            if (movie != null) {
                movies.add(movie);
            }
        }
        return movies;
    }

    // READ ONE MOVIE
    public Movie getMovieById(String movieId)
            throws IOException {

        for (Movie movie : getAllMovies()) {
            if (movie.getMovieId().equals(movieId)) {
                return movie;
            }
        }

        return null;
    }

    // UPDATE
    public boolean updateMovie(Movie updatedMovie)
            throws IOException {

        List<Movie> movies = getAllMovies();
        boolean found = false;
        for (int i = 0; i < movies.size(); i++) {
            if (movies.get(i).getMovieId().equals(updatedMovie.getMovieId())) {
                movies.set(i, updatedMovie);
                found = true;
                break;
            }
        }
        if (found) {
            saveAllMovies(movies);
        }
        return found;
    }

    // DELETE
    public boolean deleteMovie(String movieId)
            throws IOException {

        List<Movie> movies = getAllMovies();
        boolean removed =movies.removeIf(movie -> movie.getMovieId().equals(movieId) );

        if (removed) {
            saveAllMovies(movies);
        }
        return removed;
    }
    // Generate M001, M002, M003...
    public String generateNextMovieId()
            throws IOException {

        List<Movie> movies = getAllMovies();
        int highestNumber = 0;
        for (Movie movie : movies) {
            String id = movie.getMovieId();
            if (id != null && id.startsWith("M")) {
                try {
                    int number =Integer.parseInt(  id.substring(1)     );
                    if (number > highestNumber) {
                        highestNumber = number;
                    }

                } catch (NumberFormatException ignored) {
                }
            }
        }

        return String.format( "M%03d",  highestNumber + 1 );
    }
    private void saveAllMovies(List<Movie> movies)
            throws IOException {
        List<String> lines = new ArrayList<>();
        for (Movie movie : movies) {
            lines.add(convertMovieToLine(movie));
        }
        FileHandler.writeAllLines(movieFilePath, lines);
    }
    private String convertMovieToLine(Movie movie) {
        return clean(movie.getMovieId()) + "|" +
                clean(movie.getTitle()) + "|" +
                clean(movie.getGenre()) + "|" +
                movie.getReleaseYear() + "|" +
                movie.getRentalPrice() + "|" +
                movie.getRating() + "|" +
                movie.getAvailableCopies() + "|" +
                clean(movie.getDescription());
    }
    private Movie convertLineToMovie(String line) {
        try {
            String[] data =line.split("\\|", -1);
            if (data.length != 8) {
                return null;
            }
            return new Movie(data[0], data[1], data[2], Integer.parseInt(data[3]), Double.parseDouble(data[4]), Double.parseDouble(data[5]), Integer.parseInt(data[6]), data[7]);

        } catch (Exception e) {
            return null;
        }
    }
    private String clean(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("|", " ");
    }
}