package com.movierental.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter; //convert date as readble format
import java.util.Locale; //control number and date formatting conversion

public class Payment {

    // Payment methods
    public static final String METHOD_DEMO_CARD = "DEMO_CARD";
    public static final String METHOD_BANK_TRANSFER = "BANK_TRANSFER";
    public static final String METHOD_PAYHERE = "PAYHERE";

    // Payment statuses
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PAID = "PAID";
    public static final String STATUS_FAILED = "FAILED";
    public static final String STATUS_REJECTED = "REJECTED";
    public static final String STATUS_CHARGEBACK = "CHARGEBACK";

    private String paymentId;
    private String userId;
    private String movieId;
    private BigDecimal amount;
    private String paymentMethod;
    private String paymentStatus;
    private String rentalId;
    private String gatewayPaymentId;
    private LocalDateTime createdAt;

    // Required by PaymentService when reading/writing payments.txt.
    public Payment() {
        this.amount = BigDecimal.ZERO;
        this.paymentStatus = STATUS_PENDING;
        this.rentalId = "";
        this.gatewayPaymentId = "";
        this.createdAt = LocalDateTime.now();
    }

    // Retains compatibility with the original eight-argument constructor.
    public Payment(String paymentId, String userId, String movieId,
                   BigDecimal amount, String paymentMethod,
                   String paymentStatus, String rentalId,
                   LocalDateTime createdAt) {
        this();
        this.paymentId = paymentId;
        this.userId = userId;
        this.movieId = movieId;
        setAmount(amount);
        this.paymentMethod = paymentMethod;
        this.paymentStatus = paymentStatus;
        this.rentalId = rentalId;
        this.createdAt = createdAt;
    }

    public String getPaymentId() {
        return paymentId;
    }

    public void setPaymentId(String paymentId) {
        this.paymentId = paymentId;
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

    public BigDecimal getAmount() {
        return amount;
    }

    //validate before assign payment amount
    public void setAmount(BigDecimal amount) {
        if (amount == null) {
            throw new IllegalArgumentException("Payment amount cannot be null.");
        }
        if (amount.signum() < 0) {
            throw new IllegalArgumentException("Payment amount cannot be negative.");
        }
        this.amount = amount;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getRentalId() {
        return rentalId;
    }

    public void setRentalId(String rentalId) {
        this.rentalId = rentalId;
    }

    /** PayHere transaction ID, used by PaymentService for callback idempotency. */
    public String getGatewayPaymentId() {
        return gatewayPaymentId;
    }

    public void setGatewayPaymentId(String gatewayPaymentId) {
        this.gatewayPaymentId = gatewayPaymentId == null ? "" : gatewayPaymentId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

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

    public boolean isChargeback() {
        return STATUS_CHARGEBACK.equalsIgnoreCase(paymentStatus);
    }

    public boolean isDemoCardPayment() {
        return METHOD_DEMO_CARD.equalsIgnoreCase(paymentMethod);
    }

    public boolean isBankTransfer() {
        return METHOD_BANK_TRANSFER.equalsIgnoreCase(paymentMethod);
    }

    public boolean isPayHere() {
        return METHOD_PAYHERE.equalsIgnoreCase(paymentMethod);
    }

    public boolean hasRental() {
        return rentalId != null && !rentalId.trim().isEmpty();
    }

    public String getFormattedAmount() {
        if (amount == null) {
            return "LKR 0.00";
        }
        return "LKR " + String.format(Locale.US, "%,.2f", amount);
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern(
                "dd MMM yyyy, hh:mm a", Locale.ENGLISH);
        return createdAt.format(formatter);
    }

    public String getPaymentMethodDisplay() {
        if (isDemoCardPayment()) {
            return "Demo Card";
        }
        if (isBankTransfer()) {
            return "Bank Transfer";
        }
        if (isPayHere()) {
            return "PayHere Online Payment";
        }
        return paymentMethod == null ? "Unknown" : paymentMethod;
    }

    @Override
    public String toString() {
        return "Payment{" +
                "paymentId='" + paymentId + '\'' +
                ", userId='" + userId + '\'' +
                ", movieId='" + movieId + '\'' +
                ", amount=" + amount +
                ", paymentMethod='" + paymentMethod + '\'' +
                ", paymentStatus='" + paymentStatus + '\'' +
                ", rentalId='" + rentalId + '\'' +
                ", gatewayPaymentId='" + gatewayPaymentId + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}