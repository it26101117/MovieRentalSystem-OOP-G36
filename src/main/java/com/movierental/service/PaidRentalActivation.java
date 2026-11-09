package com.movierental.service;

import com.movierental.model.Movie;
import com.movierental.model.Payment;
import com.movierental.model.Rental;
import com.movierental.util.DataPathUtil;

import java.io.IOException;
import java.time.LocalDate;

/** Activates a verified PAID order exactly once in this single-JVM file-backed app. */
public final class PaidRentalActivationService {
    private static final Object ACTIVATION_LOCK = new Object();
    private final PaymentService payments;
    private final RentalService rentals;
    private final MovieService movies;

    public PaidRentalActivationService() {
        this.payments = new PaymentService(DataPathUtil.getFilePath("payments.txt"));
        this.rentals = new RentalService(DataPathUtil.getFilePath("rentals.txt"));
        this.movies = new MovieService(DataPathUtil.getFilePath("movies.txt"));
    }

    /** The caller must have independently verified the payment (admin or gateway). */
    public String activate(String paymentId) throws IOException {
        synchronized (ACTIVATION_LOCK) {
            Payment payment = payments.getPaymentById(paymentId);
            if (payment == null || !payment.isPaid()) {
                throw new IllegalStateException("A verified PAID payment is required");
            }
            if (payment.hasRental()) {
                Rental linked = rentals.getRentalById(payment.getRentalId());
                if (linked == null) throw new IllegalStateException("Payment links to a missing rental: " + payment.getRentalId());
                if (!payment.getUserId().equals(linked.getUserId()) ||
                        !payment.getMovieId().equals(linked.getMovieId())) {
                    throw new IllegalStateException("Payment rental ownership mismatch");
                }
                return linked.getRentalId();
            }
            if (rentals.hasActiveRental(payment.getUserId(), payment.getMovieId())) {
                throw new IllegalStateException("Customer already has an active rental for this movie");
            }
            Movie movie = movies.getMovieById(payment.getMovieId());
            if (movie == null || movie.getAvailableCopies() <= 0) {
                throw new IllegalStateException("Movie unavailable for rental activation");
            }
            String rentalId = rentals.generateNextRentalId();
            Rental rental = new Rental(rentalId, payment.getUserId(), payment.getMovieId(),
                    LocalDate.now().toString(), "", "RENTED");
            int originalCopies = movie.getAvailableCopies();
            boolean created = false;
            boolean stockUpdated = false;
            try {
                rentals.addRental(rental);
                created = true;
                movie.setAvailableCopies(originalCopies - 1);
                if (!movies.updateMovie(movie)) throw new IOException("Could not update movie inventory");
                stockUpdated = true;
                payments.attachRentalId(paymentId, rentalId);
                return rentalId;
            } catch (Exception failure) {
                // Best-effort recovery: file writes cannot give full database transactions.
                if (created) {
                    try {
                        rentals.deleteRental(rentalId);
                    } catch (Exception rollback) { failure.addSuppressed(rollback); }
                }
                if (stockUpdated) {
                    try {
                        movie.setAvailableCopies(originalCopies);
                        movies.updateMovie(movie);
                    } catch (Exception rollback) { failure.addSuppressed(rollback); }
                }
                if (failure instanceof IOException) throw (IOException) failure;
                if (failure instanceof RuntimeException) throw (RuntimeException) failure;
                throw new IOException("Rental activation failed", failure);
            }
        }
    }
}
