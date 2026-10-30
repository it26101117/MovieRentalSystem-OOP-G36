
package com.movierental.service;

import com.movierental.model.Payment;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.charset.StandardCharsets;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.nio.file.StandardOpenOption;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;

public class PaymentService {


    // PAYMENT METHODS


    public static final String DEMO_CARD = "DEMO_CARD";
    public static final String BANK_TRANSFER = "BANK_TRANSFER";


    // PAYMENT STATUSES


    public static final String PENDING = "PENDING";
    public static final String PAID = "PAID";
    public static final String FAILED = "FAILED";
    public static final String REJECTED = "REJECTED";

    // Synchronizes access between instances
    // inside the same Java application process.
    private static final Object FILE_LOCK = new Object();

    private final Path paymentFilePath;


    // CONSTRUCTOR


    public PaymentService(String filePath) {
        if (filePath == null || filePath.trim().isEmpty()) {
            throw new IllegalArgumentException("Payment file path cannot be empty.");
        }

        this.paymentFilePath = Paths.get(filePath).toAbsolutePath().normalize();

        initializeStorage();
    }


    // INITIALIZE STORAGE


    private void initializeStorage() {

        synchronized (FILE_LOCK) {

            try {

                Path parent = paymentFilePath.getParent();

                Files.createDirectories(parent);

                if (Files.notExists(paymentFilePath)) {
                    Files.createFile(paymentFilePath);
                }

            } catch (IOException e) {

                throw new IllegalStateException("Unable to initialize payment storage.", e);
            }
        }
    }


    // CREATE NEW PAYMENT


    public Payment createPendingPayment(String userId, String movieId, BigDecimal amount, String paymentMethod) {

        String validUserId = validateField(userId, "User ID");

        String validMovieId = validateField(movieId, "Movie ID");

        String validMethod = validatePaymentMethod(paymentMethod);

        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("Payment amount must be greater than zero.");
        }

        BigDecimal validAmount = amount.setScale(2, RoundingMode.UNNECESSARY);

        synchronized (FILE_LOCK) {

            List<Payment> payments = readPayments();

            Payment payment = new Payment();

            payment.setPaymentId(generatePaymentId(payments));

            payment.setUserId(validUserId);
            payment.setMovieId(validMovieId);
            payment.setAmount(validAmount);
            payment.setPaymentMethod(validMethod);
            payment.setPaymentStatus(PENDING);
            payment.setRentalId("");
            payment.setCreatedAt(LocalDateTime.now());

            payments.add(payment);

            savePayments(payments);

            return payment;
        }
    }

    // GET ALL PAYMENTS


    public List<Payment> getAllPayments() {

        synchronized (FILE_LOCK) {

            List<Payment> payments = readPayments();

            payments.sort(Comparator.comparing(Payment::getCreatedAt).reversed());

            return payments;
        }
    }


    // GET PAYMENT BY ID


    public Payment getPaymentById(String paymentId) {

        synchronized (FILE_LOCK) {

            for (Payment payment : readPayments()) {

                if (payment.getPaymentId().equals(paymentId)) {
                    return payment;
                }
            }

            return null;
        }
    }


    // GET PAYMENTS BY USER


    public List<Payment> getPaymentsByUser(String userId) {

        List<Payment> result = new ArrayList<>();

        synchronized (FILE_LOCK) {

            for (Payment payment : readPayments()) {

                if (payment.getUserId().equals(userId)) {
                    result.add(payment);
                }
            }
        }

        result.sort(Comparator.comparing(Payment::getCreatedAt).reversed());

        return result;
    }


    // GET PAYMENTS BY STATUS


    public List<Payment> getPaymentsByStatus(String status) {

        List<Payment> result = new ArrayList<>();

        if (status == null) {
            return result;
        }

        String normalizedStatus = status.trim().toUpperCase(Locale.ROOT);

        synchronized (FILE_LOCK) {

            for (Payment payment : readPayments()) {

                if (payment.getPaymentStatus()
                        .equalsIgnoreCase(normalizedStatus)) {

                    result.add(payment);
                }
            }
        }

        result.sort(
                Comparator.comparing(Payment::getCreatedAt).reversed());

        return result;
    }


    // GET PAYMENTS BY MOVIE


    public List<Payment> getPaymentsByMovie(String movieId) {

        List<Payment> result = new ArrayList<>();

        synchronized (FILE_LOCK) {

            for (Payment payment : readPayments()) {

                if (payment.getMovieId().equals(movieId)) {
                    result.add(payment);
                }
            }
        }

        return result;
    }


    // MARK PAYMENT AS PAID


    public Payment markPaymentPaid(String paymentId) {

        return updatePaymentStatus(paymentId, PAID);
    }


    // MARK PAYMENT AS FAILED


    public Payment markPaymentFailed(String paymentId) {

        return updatePaymentStatus(paymentId, FAILED);
    }


    // REJECT BANK TRANSFER


    public Payment rejectPayment(String paymentId) {

        return updatePaymentStatus(paymentId, REJECTED);
    }


    // UPDATE PAYMENT STATUS


    private Payment updatePaymentStatus(String paymentId, String newStatus) {

        synchronized (FILE_LOCK) {

            List<Payment> payments = readPayments();

            for (Payment payment : payments) {

                if (!payment.getPaymentId().equals(paymentId)) {
                    continue;
                }

                String currentStatus = payment.getPaymentStatus();

                // Repeated confirmation should not
                // change the same payment again.
                if (currentStatus.equals(newStatus)) {
                    return payment;
                }

                // A completed, failed or rejected
                // payment cannot be changed again.
                if (!PENDING.equals(currentStatus)) {

                    throw new IllegalStateException("Payment is already finalized: " + currentStatus);
                }

                payment.setPaymentStatus(newStatus);

                savePayments(payments);

                return payment;
            }

            throw new IllegalArgumentException("Payment not found: " + paymentId);
        }
    }

    // LINK RENTAL TO PAID PAYMENT


    public Payment attachRentalId(String paymentId, String rentalId) {

        String validRentalId = validateField(rentalId, "Rental ID");

        synchronized (FILE_LOCK) {

            List<Payment> payments = readPayments();

            Payment selectedPayment = null;

            for (Payment payment : payments) {

                if (payment.getPaymentId().equals(paymentId)) {
                    selectedPayment = payment;
                    break;
                }
            }

            if (selectedPayment == null) {

                throw new IllegalArgumentException("Payment not found: " + paymentId);
            }

            if (!PAID.equals(selectedPayment.getPaymentStatus())) {

                throw new IllegalStateException("Only paid payments can be linked to rentals.");
            }

            String existingRentalId = selectedPayment.getRentalId();

            if (existingRentalId != null && !existingRentalId.isEmpty()) {

                if (existingRentalId.equals(validRentalId)) {
                    return selectedPayment;
                }

                throw new IllegalStateException("Payment is already linked to another rental.");
            }

            // Do not allow a rental ID to be
            // assigned to multiple payments.
            for (Payment payment : payments) {

                if (validRentalId.equals(payment.getRentalId())) {

                    throw new IllegalStateException("Rental is already linked to a payment.");
                }
            }

            selectedPayment.setRentalId(validRentalId);

            savePayments(payments);

            return selectedPayment;
        }
    }

    // CALCULATE TOTAL PAID AMOUNT


    public BigDecimal getTotalPaidAmount() {

        BigDecimal total = BigDecimal.ZERO;

        synchronized (FILE_LOCK) {

            for (Payment payment : readPayments()) {

                if (PAID.equals(payment.getPaymentStatus())) {

                    total = total.add(payment.getAmount());
                }
            }
        }

        return total.setScale(2, RoundingMode.HALF_UP);
    }


    // COUNT PAYMENTS


    public int getTotalPaymentCount() {

        synchronized (FILE_LOCK) {
            return readPayments().size();
        }
    }

    public int getPendingPaymentCount() {

        return getPaymentsByStatus(PENDING).size();
    }

    public int getPaidPaymentCount() {

        return getPaymentsByStatus(PAID).size();
    }


    // GENERATE UNIQUE PAYMENT ID


    private String generatePaymentId(List<Payment> payments) {

        int highestNumber = 0;

        for (Payment payment : payments) {

            String id = payment.getPaymentId();

            if (id == null || !id.matches("P\\d+")) {
                continue;
            }

            try {

                int number = Integer.parseInt(id.substring(1));

                highestNumber = Math.max(highestNumber, number);

            } catch (NumberFormatException ignored) {
                // Ignore IDs outside integer range.
            }
        }

        return String.format(Locale.ROOT, "P%04d", highestNumber + 1);
    }


    // READ PAYMENTS FROM FILE


    private List<Payment> readPayments() {

        List<Payment> payments = new ArrayList<>();

        try {

            List<String> lines = Files.readAllLines(paymentFilePath, StandardCharsets.UTF_8);

            int lineNumber = 0;

            for (String line : lines) {

                lineNumber++;

                if (line.trim().isEmpty()) {
                    continue;
                }

                String[] data = line.split("\\|", -1);

                if (data.length != 8) {

                    throw new IllegalStateException("Invalid payment record at line " + lineNumber);
                }

                Payment payment = new Payment();

                payment.setPaymentId(data[0]);
                payment.setUserId(data[1]);
                payment.setMovieId(data[2]);

                payment.setAmount(new BigDecimal(data[3]));

                payment.setPaymentMethod(data[4]);
                payment.setPaymentStatus(data[5]);
                payment.setRentalId(data[6]);

                payment.setCreatedAt(LocalDateTime.parse(data[7]));

                payments.add(payment);
            }

        } catch (IOException e) {

            throw new IllegalStateException("Unable to read payment records.", e);

        } catch (RuntimeException e) {

            throw new IllegalStateException("Unable to parse payment records.", e);
        }

        return payments;
    }


    // SAVE PAYMENTS TO FILE


    private void savePayments(
            List<Payment> payments
    ) {

        List<String> lines = new ArrayList<>();

        for (Payment payment : payments) {

            String rentalId = payment.getRentalId();

            if (rentalId == null) {
                rentalId = "";
            }

            String line = String.join(
                    "|",
                    validateField(
                            payment.getPaymentId(),
                            "Payment ID"
                    ),
                    validateField(
                            payment.getUserId(),
                            "User ID"
                    ),
                    validateField(
                            payment.getMovieId(),
                            "Movie ID"
                    ),
                    payment.getAmount().toPlainString(),
                    validateField(
                            payment.getPaymentMethod(),
                            "Payment method"
                    ),
                    validateField(
                            payment.getPaymentStatus(),
                            "Payment status"
                    ),
                    rentalId.isEmpty()
                            ? ""
                            : validateField(rentalId, "Rental ID"),
                    payment.getCreatedAt().toString()
            );

            lines.add(line);
        }

        Path temporaryFile = null;

        try {

            temporaryFile = Files.createTempFile(
                    paymentFilePath.getParent(),
                    "payments-",
                    ".tmp"
            );

            Files.write(
                    temporaryFile,
                    lines,
                    StandardCharsets.UTF_8,
                    StandardOpenOption.WRITE,
                    StandardOpenOption.TRUNCATE_EXISTING
            );

            try {

                Files.move(
                        temporaryFile,
                        paymentFilePath,
                        StandardCopyOption.REPLACE_EXISTING,
                        StandardCopyOption.ATOMIC_MOVE
                );

            } catch (AtomicMoveNotSupportedException e) {

                Files.move(
                        temporaryFile,
                        paymentFilePath,
                        StandardCopyOption.REPLACE_EXISTING
                );
            }

        } catch (IOException e) {

            throw new IllegalStateException("Unable to save payment records.", e);

        } finally {

            if (temporaryFile != null) {

                try {
                    Files.deleteIfExists(temporaryFile);
                } catch (IOException ignored) {
                    // Temporary file cleanup failure.
                }
            }
        }
    }


    // VALIDATION


    private String validatePaymentMethod(
            String paymentMethod
    ) {

        String method = validateField(paymentMethod, "Payment method").toUpperCase(Locale.ROOT);

        if (!DEMO_CARD.equals(method) && !BANK_TRANSFER.equals(method)) {

            throw new IllegalArgumentException("Unsupported payment method.");
        }

        return method;
    }

    private String validateField(
            String value,
            String fieldName
    ) {

        if (value == null || value.trim().isEmpty()) {

            throw new IllegalArgumentException(fieldName + " cannot be empty.");
        }

        String cleaned = value.trim();

        if (cleaned.contains("|") || cleaned.contains("\n") || cleaned.contains("\r")) {

            throw new IllegalArgumentException(fieldName + " contains invalid characters.");
        }

        return cleaned;
    }
}
