package com.movierental.algorithm;
import com.movierental.model.Movie;
import java.util.ArrayList;
import java.util.List;
public class BubbleSort {
    private BubbleSort() {
        // Prevent creating BubbleSort objects
    }

    // SORT RATING - HIGHEST TO LOWEST
    public static List<Movie> sortByRatingDescending( List<Movie> movies){

        // Create a copy so the original list is not modified
        List<Movie> sortedMovies = new ArrayList<>(movies);

        int n = sortedMovies.size();

        for (int i = 0;  i < n - 1; i++){
            boolean swapped = false;
            for (int j = 0; j < n - i - 1;j++){
                Movie currentMovie =sortedMovies.get(j);
                Movie nextMovie = sortedMovies.get(j + 1);

                //current ration is lower , next rating, swap the movie.
                if ( currentMovie.getRating() < nextMovie.getRating()){
                    sortedMovies.set(j,nextMovie);
                    sortedMovies.set(j + 1, currentMovie);
                    swapped = true;
                }
            }

            if (!swapped) {
                break;
            }
        }
        return sortedMovies;
    }

    // SORT RATING - LOWEST TO HIGHEST
    public static List<Movie> sortByRatingAscending(List<Movie> movies){

        List<Movie> sortedMovies = new ArrayList<>(movies);

        int n =sortedMovies.size();
        for (int i = 0;i < n - 1; i++){
            boolean swapped = false;
            for (int j = 0;j < n - i - 1;  j++){
                Movie currentMovie = sortedMovies.get(j);
                Movie nextMovie = sortedMovies.get(j + 1);

                if (currentMovie.getRating()>nextMovie.getRating()) {
                    sortedMovies.set(j,nextMovie );
                    sortedMovies.set( j + 1,currentMovie);
                    swapped = true;
                }
            }
            if (!swapped){
                break;
            }
        }
        return sortedMovies;
    }
}