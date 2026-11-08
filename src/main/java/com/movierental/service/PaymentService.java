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

/**
 * CineRent payment storage and PayHere notification processing.
 *
 * Uses payments.txt for the existing academic project. The static lock
 * protects one running JVM only; use a transactional database for production.
 */
public class PaymentService {

    public static final String DEMO_CARD = "DEMO_CARD";
    public static final String BANK_TRANSFER = "BANK_TRANSFER";
    public static final String PAYHERE = "PAYHERE";

    public static final String PENDING = "PENDING";
    public static final String PAID = "PAID";
    public static final String FAILED = "FAILED";
    public static final String REJECTED = "REJECTED";
    public static final String CHARGEBACK = "CHARGEBACK";

    private static final Object FILE_LOCK = new Object();
    private final Path paymentFilePath;

    public PaymentService(String filePath) {
        if (filePath == null || filePath.isBlank()) {
            throw new IllegalArgumentException("Payment file path is required");
        }
        paymentFilePath = Paths.get(filePath).toAbsolutePath().normalize();
        synchronized (FILE_LOCK) {
            try {
                Files.createDirectories(paymentFilePath.getParent());
                if (Files.notExists(paymentFilePath)) {
                    Files.createFile(paymentFilePath);
                }
            } catch (IOException ex) {
                throw new IllegalStateException("Cannot initialize payment storage", ex);
            }
        }
    }

    /** Create an order. Do not grant a rental at this stage. */
    public Payment createPendingPayment(String userId, String movieId,
                                        BigDecimal amount, String paymentMethod) {
        String validUserId = safeField(userId, "User ID");
        String validMovieId = safeField(movieId, "Movie ID");
        String method = safeField(paymentMethod, "Payment method")
                .toUpperCase(Locale.ROOT);
        if (!DEMO_CARD.equals(method) && !BANK_TRANSFER.equals(method)
                && !PAYHERE.equals(method)) {
            throw new IllegalArgumentException("Unsupported payment method: " + method);
        }
        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("Payment amount must be positive");
        }
        BigDecimal normalizedAmount = amount.setScale(2, RoundingMode.UNNECESSARY);

        synchronized (FILE_LOCK) {
            List<Payment> payments = readPayments();
            Payment payment = new Payment();
            payment.setPaymentId(nextPaymentId(payments));
            payment.setUserId(validUserId);
            payment.setMovieId(validMovieId);
            payment.setAmount(normalizedAmount);
            payment.setPaymentMethod(method);
            payment.setPaymentStatus(PENDING);
            payment.setRentalId("");
            payment.setGatewayPaymentId("");
            payment.setCreatedAt(LocalDateTime.now());
            payments.add(payment);
            writePayments(payments);
            return payment;
        }
    }

    public List<Payment> getAllPayments() {
        synchronized (FILE_LOCK) {
            return newestFirst(readPayments());
        }
    }

    public Payment getPaymentById(String paymentId) {
        if (paymentId == null) return null;
        synchronized (FILE_LOCK) {
            for (Payment payment : readPayments()) {
                if (paymentId.equals(payment.getPaymentId())) return payment;
            }
            return null;
        }
    }

    public List<Payment> getPaymentsByUser(String userId) {
        List<Payment> result = new ArrayList<>();
        synchronized (FILE_LOCK) {
            for (Payment payment : readPayments()) {
                if (userId != null && userId.equals(payment.getUserId())) {
                    result.add(payment);
                }
            }
        }
        return newestFirst(result);
    }

    public List<Payment> getPaymentsByMovie(String movieId) {
        List<Payment> result = new ArrayList<>();
        synchronized (FILE_LOCK) {
            for (Payment payment : readPayments()) {
                if (movieId != null && movieId.equals(payment.getMovieId())) {
                    result.add(payment);
                }
            }
        }
        return newestFirst(result);
    }

    public List<Payment> getPaymentsByStatus(String status) {
        List<Payment> result = new ArrayList<>();
        if (status == null) return result;
        synchronized (FILE_LOCK) {
            for (Payment payment : readPayments()) {
                if (status.equalsIgnoreCase(payment.getPaymentStatus())) {
                    result.add(payment);
                }
            }
        }
        return newestFirst(result);
    }

    /** For Demo Card testing and admin-approved Bank Transfers only. */
    public Payment markPaymentPaid(String paymentId) {
        return updateNonGatewayStatus(paymentId, PAID);
    }

    public Payment markPaymentFailed(String paymentId) {
        return updateNonGatewayStatus(paymentId, FAILED);
    }

    public Payment rejectPayment(String paymentId) {
        return updateNonGatewayStatus(paymentId, REJECTED);
    }

    private Payment updateNonGatewayStatus(String paymentId, String nextStatus) {
        synchronized (FILE_LOCK) {
            List<Payment> payments = readPayments();
            for (Payment payment : payments) {
                if (!payment.getPaymentId().equals(paymentId)) continue;
                // Critical: PayHere must NEVER be marked paid from admin/demo endpoints.
                if (PAYHERE.equalsIgnoreCase(payment.getPaymentMethod())) {
                    throw new IllegalStateException(
                            "PayHere status requires a verified gateway notification");
                }
                String current = payment.getPaymentStatus();
                if (nextStatus.equals(current)) return payment;
                if (!PENDING.equals(current)) {
                    throw new IllegalStateException("Payment already finalized: " + current);
                }
                payment.setPaymentStatus(nextStatus);
                writePayments(payments);
                return payment;
            }
            throw new IllegalArgumentException("Payment not found: " + paymentId);
        }
    }

    /**
     * Call ONLY after PayHereNotifyServlet verifies merchant_id and md5sig.
     * Also checks the stored order amount, currency, method and gateway ID.
     * PayHere status codes: 2=success, 0=pending, -1=cancelled,
     * -2=failed, -3=chargeback.
     */
    public Payment applyVerifiedPayHereNotification(
            String orderId, String gatewayPaymentId, BigDecimal reportedAmount,
            String currency, int statusCode) {

        if (orderId == null || !orderId.matches("P\\d+")) {
            throw new IllegalArgumentException("Invalid PayHere order ID");
        }
        if (reportedAmount == null || reportedAmount.signum() <= 0) {
            throw new IllegalArgumentException("Invalid PayHere amount");
        }
        if (!"LKR".equals(currency)) {
            throw new IllegalArgumentException("Unexpected PayHere currency");
        }
        if (statusCode != 2 && statusCode != 0 && statusCode != -1
                && statusCode != -2 && statusCode != -3) {
            throw new IllegalArgumentException("Unknown PayHere status: " + statusCode);
        }
        String transactionId = gatewayPaymentId == null ? "" : gatewayPaymentId.trim();
        if (!transactionId.isEmpty() && !transactionId.matches("[A-Za-z0-9_-]{1,128}")) {
            throw new IllegalArgumentException("Invalid PayHere transaction ID");
        }
        if ((statusCode == 2 || statusCode == -3) && transactionId.isEmpty()) {
            throw new IllegalArgumentException("Missing PayHere transaction ID");
        }

        synchronized (FILE_LOCK) {
            List<Payment> payments = readPayments();
            for (Payment payment : payments) {
                if (!orderId.equals(payment.getPaymentId())) continue;
                if (!PAYHERE.equalsIgnoreCase(payment.getPaymentMethod())) {
                    throw new IllegalArgumentException("Order is not a PayHere payment");
                }
                if (payment.getAmount().compareTo(reportedAmount) != 0) {
                    throw new IllegalArgumentException("PayHere amount mismatch");
                }

                String storedTransactionId = payment.getGatewayPaymentId();
                if (storedTransactionId == null) storedTransactionId = "";
                if (!storedTransactionId.isEmpty() && !transactionId.isEmpty()
                        && !storedTransactionId.equals(transactionId)) {
                    throw new IllegalArgumentException("PayHere transaction ID mismatch");
                }

                String current = payment.getPaymentStatus();
                String next = current;
                if (statusCode == 2) {
                    if (PENDING.equals(current)) next = PAID;
                    else if (!PAID.equals(current)) {
                        throw new IllegalStateException(
                                "Cannot confirm a finalized payment: " + current);
                    }
                } else if (statusCode == -3) {
                    if (PAID.equals(current) || CHARGEBACK.equals(current)) {
                        next = CHARGEBACK;
                    } else {
                        throw new IllegalStateException(
                                "Chargeback received for a non-paid order: " + current);
                    }
                } else if ((statusCode == -1 || statusCode == -2)
                        && PENDING.equals(current)) {
                    next = FAILED;
                }
                // A stale pending/failure notification cannot downgrade PAID.
                boolean idChanged = storedTransactionId.isEmpty() && !transactionId.isEmpty();
                if (!current.equals(next) || idChanged) {
                    payment.setPaymentStatus(next);
                    if (idChanged) payment.setGatewayPaymentId(transactionId);
                    writePayments(payments);
                }
                return payment;
            }
            throw new IllegalArgumentException("Unknown PayHere order: " + orderId);
        }
    }

    /** Link one confirmed payment to one rental. Safe to repeat with same rental ID. */
    public Payment attachRentalId(String paymentId, String rentalId) {
        String validRentalId = safeField(rentalId, "Rental ID");
        synchronized (FILE_LOCK) {
            List<Payment> payments = readPayments();
            Payment selected = null;
            for (Payment payment : payments) {
                if (paymentId != null && paymentId.equals(payment.getPaymentId())) {
                    selected = payment;
                    break;
                }
            }
            if (selected == null) throw new IllegalArgumentException("Payment not found");
            if (!PAID.equals(selected.getPaymentStatus())) {
                throw new IllegalStateException("Rental requires a paid payment");
            }
            if (selected.hasRental()) {
                if (validRentalId.equals(selected.getRentalId())) return selected;
                throw new IllegalStateException("Payment already linked to a rental");
            }
            for (Payment payment : payments) {
                if (validRentalId.equals(payment.getRentalId())) {
                    throw new IllegalStateException("Rental already linked to a payment");
                }
            }
            selected.setRentalId(validRentalId);
            writePayments(payments);
            return selected;
        }
    }

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

    private static List<Payment> newestFirst(List<Payment> payments) {
        payments.sort(Comparator.comparing(Payment::getCreatedAt).reversed());
        return payments;
    }

    private static String nextPaymentId(List<Payment> payments) {
        int highest = 0;
        for (Payment payment : payments) {
            String id = payment.getPaymentId();
            if (id == null || !id.matches("P\\d+")) continue;
            try {
                highest = Math.max(highest, Integer.parseInt(id.substring(1)));
            } catch (NumberFormatException ignored) {
                // Legacy IDs outside the int range are ignored.
            }
        }
        if (highest == Integer.MAX_VALUE) {
            throw new IllegalStateException("Payment ID sequence exhausted");
        }
        return String.format(Locale.ROOT, "P%04d", highest + 1);
    }

    /** Read both legacy 8-field and PayHere 9-field records. */
    private List<Payment> readPayments() {
        List<Payment> result = new ArrayList<>();
        try {
            List<String> lines = Files.readAllLines(paymentFilePath, StandardCharsets.UTF_8);
            int lineNumber = 0;
            for (String line : lines) {
                lineNumber++;
                if (line.isBlank()) continue;
                String[] data = line.split("\\|", -1);
                if (data.length != 8 && data.length != 9) {
                    throw new IllegalStateException("Invalid payment record on line " + lineNumber);
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
                if (data.length == 9) payment.setGatewayPaymentId(data[8]);
                result.add(payment);
            }
            return result;
        } catch (IOException ex) {
            throw new IllegalStateException("Cannot read payment storage", ex);
        } catch (RuntimeException ex) {
            throw new IllegalStateException("Cannot parse payment storage", ex);
        }
    }

    /** Write all records through a temporary file to avoid partial writes. */
    private void writePayments(List<Payment> payments) {
        List<String> lines = new ArrayList<>();
        for (Payment payment : payments) {
            String rentalId = payment.getRentalId() == null ? "" : payment.getRentalId();
            String transactionId = payment.getGatewayPaymentId() == null
                    ? "" : payment.getGatewayPaymentId();
            lines.add(String.join("|",
                    safeField(payment.getPaymentId(), "Payment ID"),
                    safeField(payment.getUserId(), "User ID"),
                    safeField(payment.getMovieId(), "Movie ID"),
                    payment.getAmount().toPlainString(),
                    safeField(payment.getPaymentMethod(), "Payment method"),
                    safeField(payment.getPaymentStatus(), "Payment status"),
                    rentalId.isEmpty() ? "" : safeField(rentalId, "Rental ID"),
                    payment.getCreatedAt().toString(),
                    transactionId.isEmpty() ? "" : safeField(transactionId, "Transaction ID")
            ));
        }

        Path temporary = null;
        try {
            temporary = Files.createTempFile(paymentFilePath.getParent(), "payments-", ".tmp");
            Files.write(temporary, lines, StandardCharsets.UTF_8,
                    StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING);
            try {
                Files.move(temporary, paymentFilePath,
                        StandardCopyOption.REPLACE_EXISTING,
                        StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException ex) {
                Files.move(temporary, paymentFilePath, StandardCopyOption.REPLACE_EXISTING);
            }
        } catch (IOException ex) {
            throw new IllegalStateException("Cannot save payment storage", ex);
        } finally {
            if (temporary != null) {
                try { Files.deleteIfExists(temporary); }
                catch (IOException ignored) { /* Best-effort cleanup. */ }
            }
        }
    }

    private static String safeField(String value, String fieldName) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(fieldName + " is required");
        }
        String cleaned = value.trim();
        if (cleaned.contains("|") || cleaned.contains("\n") || cleaned.contains("\r")) {
            throw new IllegalArgumentException(fieldName + " contains invalid characters");
        }
        return cleaned;
    }
}