
package com.movierental.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class Payment {


    // PAYMENT METHODS


    public static final String METHOD_DEMO_CARD = "DEMO_CARD";
    public static final String METHOD_BANK_TRANSFER = "BANK_TRANSFER";


    // PAYMENT STATUSES


    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PAID = "PAID";
    public static final String STATUS_FAILED = "FAILED";
    public static final String STATUS_REJECTED = "REJECTED";


    // PAYMENT ATTRIBUTES


    private String paymentId;
    private String userId;
    private String movieId;
    private BigDecimal amount;
    private String paymentMethod;
    private String paymentStatus;

    private String rentalId;

    private LocalDateTime createdAt;


    // DEFAULT CONSTRUCTOR


    public Payment() {

        this.amount = BigDecimal.ZERO;
        this.paymentStatus = STATUS_PENDING;
        this.rentalId = "";
        this.createdAt = LocalDateTime.now();
    }


    // PARAMETERIZED CONSTRUCTOR

    public Payment(
            String paymentId,
            String userId,
            String movieId,
            BigDecimal amount,
            String paymentMethod,
            String paymentStatus,
            String rentalId,
            LocalDateTime createdAt
    ) {

        this.paymentId = paymentId;
        this.userId = userId;
        this.movieId = movieId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.rentalId = rentalId;
        this.createdAt = createdAt;
    }


    // PAYMENT ID


    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
    }


    // USER ID


    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }


    // MOVIE ID


    public String getMovieId() {
        return movieId;
    }

    public void setMovieId(String movieId) {
        this.movieId = movieId;
    }


    // PAYMENT AMOUNT


    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {

        if (amount == null) {
            throw new IllegalArgumentException("Payment amount cannot be null.");
        }

        if (amount.signum() < 0) {
            throw new IllegalArgumentException("Payment amount cannot be negative.");
        }

        this.amount = amount;
    }


    // PAYMENT METHOD


    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }


    // PAYMENT STATUS


    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }


    // RENTAL ID


    public String getRentalId() {
        return rentalId;
    }

    public void setRentalId(String rentalId) {
        this.rentalId = rentalId;
    }


    // CREATED DATE AND TIME


    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }


    // CHECK PAYMENT STATUS


    public boolean isPending() {

        return STATUS_PENDING.equalsIgnoreCase(paymentStatus);
    }

    public boolean isPaid() {

        return STATUS_PAID.equalsIgnoreCase(paymentStatus);
    }

    public boolean isFailed() {

        return STATUS_FAILED.equalsIgnoreCase(paymentStatus);
    }

    public boolean isRejected() {

        return STATUS_REJECTED.equalsIgnoreCase(paymentStatus);
    }


    // CHECK PAYMENT METHOD


    public boolean isDemoCardPayment() {

        return METHOD_DEMO_CARD.equalsIgnoreCase(paymentMethod);
    }

    public boolean isBankTransfer() {

        return METHOD_BANK_TRANSFER.equalsIgnoreCase(paymentMethod);
    }


    // CHECK RENTAL LINK


    public boolean hasRental() {

        return rentalId != null && !rentalId.trim().isEmpty();
    }


    // FORMATTED PAYMENT AMOUNT


    public String getFormattedAmount() {

        if (amount == null) {
            return "LKR 0.00";
        }

        return "LKR " + String.format(java.util.Locale.US, "%,.2f", amount);
    }


    // FORMATTED PAYMENT DATE


    public String getFormattedCreatedAt() {

        if (createdAt == null) {
            return "";
        }

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a", java.util.Locale.ENGLISH);

        return createdAt.format(formatter);
    }


    // PAYMENT METHOD DISPLAY NAME


    public String getPaymentMethodDisplay() {

        if (isDemoCardPayment()) {
            return "Demo Card";
        }

        if (isBankTransfer()) {
            return "Bank Transfer";
        }

        return paymentMethod == null ? "Unknown" : paymentMethod;
    }


    // TO STRING


    @Override
    public String toString() {

        return "Payment{" + "paymentId='" + paymentId + '\'' + ", userId='" + userId + '\'' + ", movieId='" + movieId + '\'' + ", amount=" + amount + ", paymentMethod='" + paymentMethod + '\'' + ", paymentStatus='" + paymentStatus + '\'' + ", rentalId='" + rentalId + '\'' + ", createdAt=" + createdAt + '}';
    }
}
