package com.movierental.datastructure;
import com.movierental.model.Movie;
public class MovieStack {
    private Movie[] movies;
    private int top;

    public MovieStack(int capacity) {
        if (capacity <= 0) {
            capacity = 10;
        }
        movies = new Movie[capacity];
        top = -1;
    }

    // PUSH
    public void push(Movie movie){
        if (movie == null) {
            return;
        }
        // Increase array size if full
        if (top == movies.length - 1) {
            resize();
        }
        top++;
        movies[top] = movie;
    }

    // POP
    public Movie pop() {
        if (isEmpty()) {
            return null;
        }
        Movie movie = movies[top];
        movies[top] = null;
        top--;
        return movie;
    }

    // PEEK
    public Movie peek() {
        if (isEmpty()) {
            return null;
        }
        return movies[top];
    }

    // CHECK EMPTY
    public boolean isEmpty() {
        return top == -1;
    }

    // STACK SIZE
    public int size() {
        return top + 1;
    }
    private void resize() {
        Movie[] newArray = new Movie[movies.length * 2];
        for (int i = 0;  i < movies.length; i++) {
            newArray[i] =  movies[i];
        }
        movies = newArray;
    }
}