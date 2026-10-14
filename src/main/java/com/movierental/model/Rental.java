package com.movierental.model;

public class Rental {

    private String rentalId;
    private String userId;
    private String movieId;
    private String rentalDate;
    private String returnDate;
    private String status;

    public Rental() {
    }
    public Rental( String rentalId, String userId,String movieId,String rentalDate,String returnDate,String status){
        this.rentalId = rentalId;
        this.userId = userId;
        this.movieId = movieId;
        this.rentalDate = rentalDate;
        this.returnDate = returnDate;
        this.status = status;
    }

    public String getRentalId() {
        return rentalId;
    }

    public void setRentalId(String rentalId) {
        this.rentalId = rentalId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getMovieId() {
        return movieId;
    }

    public void setMovieId(String movieId) {
        this.movieId = movieId;
    }

    public String getRentalDate() {
        return rentalDate;
    }

    public void setRentalDate(String rentalDate) {
        this.rentalDate = rentalDate;
    }

    public String getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(String returnDate) {
        this.returnDate = returnDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}