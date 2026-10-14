package com.movierental.model;

public class Movie {
    private String movieId;
    private String title;
    private String genre;
    private int releaseYear;
    private double rentalPrice;
    private double rating;
    private int availableCopies;
    private String description;

    public Movie() {
    }
    public Movie(String movieId,String title, String genre,int releaseYear,double rentalPrice, double rating,int availableCopies,String description){
        this.movieId = movieId;
        this.title = title;
        this.genre = genre;
        this.releaseYear = releaseYear;
        this.rentalPrice = rentalPrice;
        this.rating = rating;
        this.availableCopies = availableCopies;
        this.description = description;
    }
    public String getMovieId() {
        return movieId;
    }
    public void setMovieId(String movieId) {
        this.movieId = movieId;
    }
    public String getTitle() {
        return title;
    }
    public void setTitle(String title) {
        this.title = title;
    }
    public String getGenre() {
        return genre;
    }
    public void setGenre(String genre) {
        this.genre = genre;
    }
    public int getReleaseYear() {
        return releaseYear;
    }
    public void setReleaseYear(int releaseYear) {
        this.releaseYear = releaseYear;
    }
    public double getRentalPrice() {
        return rentalPrice;
    }
    public void setRentalPrice(double rentalPrice) {
        this.rentalPrice = rentalPrice;
    }
    public double getRating() {
        return rating;
    }
    public void setRating(double rating) {
        this.rating = rating;
    }
    public int getAvailableCopies() {
        return availableCopies;
    }
    public void setAvailableCopies(int availableCopies) {
        this.availableCopies = availableCopies;
    }
    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }
    @Override
    public String toString() {
        return movieId + "|" +title + "|" + genre + "|" +releaseYear + "|" + rentalPrice + "|" +rating + "|" +availableCopies + "|" +description;
    }
}