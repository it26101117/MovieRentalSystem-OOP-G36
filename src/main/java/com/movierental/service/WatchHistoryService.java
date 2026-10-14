package com.movierental.service;


import com.movierental.datastructure.MovieStack;
import com.movierental.model.Movie;
import com.movierental.util.FileHandler;


import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

public class WatchHistoryService {

    private final String watchHistoryFilePath;

    private final MovieService movieService;


    public WatchHistoryService(
            String watchHistoryFilePath,
            MovieService movieService
    ) {

        this.watchHistoryFilePath =
                watchHistoryFilePath;

        this.movieService =
                movieService;
    }



    // RECORD WATCHED MOVIE


    public void recordWatchedMovie(
            String userId,
            String movieId
    ) throws IOException {

        String line =
                clean(userId)
                        + "|"
                        + clean(movieId)
                        + "|"
                        + LocalDateTime.now();

        FileHandler.appendLine(
                watchHistoryFilePath,
                line
        );
    }



    // BUILD STACK


    public MovieStack buildMovieStack(
            String userId
    ) throws IOException {

        List<String> lines =
                FileHandler.readAllLines(
                        watchHistoryFilePath
                );


        MovieStack stack =
                new MovieStack(10);


        for (String line : lines) {

            if (
                    line == null
                            ||
                            line.trim().isEmpty()
            ) {

                continue;
            }


            String[] data =
                    line.split(
                            "\\|",
                            -1
                    );


            if (data.length != 3) {
                continue;
            }


            String storedUserId =
                    data[0];

            String movieId =
                    data[1];


            if (
                    !storedUserId.equals(
                            userId
                    )
            ) {

                continue;
            }


            Movie movie =
                    movieService
                            .getMovieById(
                                    movieId
                            );


            if (movie != null) {

                stack.push(movie);
            }
        }



        return stack;
    }



    private String clean(
            String value
    ) {

        if (value == null) {
            return "";
        }

        return value.replace(
                "|",
                " "
        );
    }
}