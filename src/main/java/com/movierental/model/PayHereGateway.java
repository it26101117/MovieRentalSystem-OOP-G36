package com.movierental.service;

import com.movierental.model.Payment;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URI;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;

/**
 * PayHere Hosted Checkout integration for CineRent.
 *
 * Responsibilities:
 *  - Prepare the signed checkout form fields.
 *  - Verify the signature of PayHere's server-to-server notifications.
 *
 * This class does NOT mark payments as paid or collect card details.
 * Only PayHereNotifyServlet + PaymentService may process verified notifications.
 */
public final class PayHereGateway {

    private static final String CURRENCY = "LKR";
    private static final String SANDBOX_URL =
            "https://sandbox.payhere.lk/pay/checkout";
    private static final String LIVE_URL =
            "https://www.payhere.lk/pay/checkout";

    private final String merchantId;
    private final String merchantSecret;
    private final String publicBaseUrl;
    private final boolean sandbox;

    /** Reads credentials from environment variables. */
    public PayHereGateway() {
        this(
                requiredEnvironmentVariable("PAYHERE_MERCHANT_ID"),
                requiredEnvironmentVariable("PAYHERE_MERCHANT_SECRET"),
                requiredEnvironmentVariable("PAYHERE_PUBLIC_BASE_URL"),
                Boolean.parseBoolean(
                        System.getenv().getOrDefault("PAYHERE_SANDBOX", "true")
                )
        );
    }

    // Package-private constructor to allow tests without real credentials.
    PayHereGateway(String merchantId, String merchantSecret,
                   String publicBaseUrl, boolean sandbox) {
        this.merchantId = requiredText(merchantId, "merchant ID");
        this.merchantSecret = requiredText(merchantSecret, "merchant secret");

        String baseUrl = requiredText(publicBaseUrl, "public base URL")
                .replaceAll("/+$", "");

        URI uri;
        try {
            uri = URI.create(baseUrl);
        } catch (IllegalArgumentException ex) {
            throw new IllegalArgumentException(
                    "PAYHERE_PUBLIC_BASE_URL is not a valid URL", ex
            );
        }

        if (!"https".equalsIgnoreCase(uri.getScheme())
                || uri.getHost() == null
                || uri.getUserInfo() != null
                || uri.getRawQuery() != null
                || uri.getRawFragment() != null) {
            throw new IllegalArgumentException(
                    "PAYHERE_PUBLIC_BASE_URL must be an HTTPS URL "
                            + "without credentials, query parameters, or fragments"
            );
        }

        this.publicBaseUrl = baseUrl;
        this.sandbox = sandbox;
    }

    /** URL that receives the signed HTML POST form. */
    public String getCheckoutUrl() {
        return sandbox ? SANDBOX_URL : LIVE_URL;
    }

    /**
     * Builds PayHere Checkout API fields for an existing pending payment.
     * The returned map can be rendered as hidden inputs in payhere-redirect.jsp.
     */
    public Map<String, String> checkoutFields(
            Payment payment,
            String movieTitle,
            String customerName,
            String email,
            String phone,
            String address,
            String city
    ) {
        if (payment == null
                || !"PAYHERE".equalsIgnoreCase(payment.getPaymentMethod())
                || !"PENDING".equalsIgnoreCase(payment.getPaymentStatus())) {
            throw new IllegalArgumentException(
                    "A pending PayHere payment is required"
            );
        }

        String orderId = requiredText(payment.getPaymentId(), "payment ID");
        if (!orderId.matches("[A-Za-z0-9_-]{1,64}")) {
            throw new IllegalArgumentException("Invalid payment ID for PayHere");
        }

        String fullName = requiredText(customerName, "customer name");
        String[] nameParts = fullName.split("\\s+", 2);
        String firstName = nameParts[0];
        String lastName = nameParts.length == 2 ? nameParts[1] : "Customer";

        String amount = amountText(payment.getAmount());
        String title = requiredText(movieTitle, "movie title");

        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("merchant_id", merchantId);
        fields.put("return_url", publicBaseUrl + "/payments?paymentId=" + orderId);
        fields.put("cancel_url", publicBaseUrl + "/payments?paymentId=" + orderId);
        fields.put("notify_url", publicBaseUrl + "/payhere/notify");
        fields.put("order_id", orderId);
        fields.put("items", title);
        fields.put("currency", CURRENCY);
        fields.put("amount", amount);
        fields.put("first_name", firstName);
        fields.put("last_name", lastName);
        fields.put("email", requiredText(email, "email"));
        fields.put("phone", requiredText(phone, "phone"));
        fields.put("address", requiredText(address, "address"));
        fields.put("city", requiredText(city, "city"));
        fields.put("country", "Sri Lanka");

        // PayHere checkout hash (uppercase hexadecimal MD5).
        // MD5(merchant_id + order_id + amount + currency + MD5(merchant_secret))
        fields.put("hash", md5Upper(
                merchantId + orderId + amount + CURRENCY + md5Upper(merchantSecret)
        ));

        return fields;
    }

    /**
     * Verifies PayHere's md5sig for a server-to-server notification.
     * Use the amount string exactly as supplied by PayHere when checking
     * the signature; do not parse/reformat it first.
     *
     * IMPORTANT: After this check succeeds, PaymentService must still verify
     * the stored order, amount, currency, payment method and state transition.
     */
    public boolean verifyNotification(
            String reportedMerchantId,
            String orderId,
            String payhereAmount,
            String currency,
            String statusCode,
            String signature
    ) {
        if (!merchantId.equals(reportedMerchantId)
                || isBlank(orderId)
                || isBlank(payhereAmount)
                || isBlank(currency)
                || isBlank(statusCode)
                || signature == null
                || !signature.matches("(?i)[0-9a-f]{32}")) {
            return false;
        }

        // PayHere callback signature:
        // MD5(merchant_id + order_id + payhere_amount + payhere_currency
        //     + status_code + MD5(merchant_secret))
        String expectedSignature = md5Upper(
                merchantId + orderId + payhereAmount + currency
                        + statusCode + md5Upper(merchantSecret)
        );

        return MessageDigest.isEqual(
                expectedSignature.getBytes(StandardCharsets.US_ASCII),
                signature.toUpperCase(Locale.ROOT).getBytes(StandardCharsets.US_ASCII)
        );
    }

    /** Formats amounts as 1000.00, without commas or currency symbols. */
    public static String amountText(BigDecimal amount) {
        if (amount == null || amount.signum() <= 0) {
            throw new IllegalArgumentException("Payment amount must be positive");
        }
        return amount.setScale(2, RoundingMode.UNNECESSARY).toPlainString();
    }

    private static String md5Upper(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("MD5")
                    .digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(32);
            for (byte b : digest) {
                hex.append(String.format(Locale.ROOT, "%02X", b & 0xFF));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("MD5 is unavailable", ex);
        }
    }

    private static String requiredEnvironmentVariable(String name) {
        String value = System.getenv(name);
        if (isBlank(value)) {
            throw new IllegalStateException(
                    "Missing PayHere environment variable: " + name
            );
        }
        return value.trim();
    }

    private static String requiredText(String value, String fieldName) {
        if (isBlank(value)) {
            throw new IllegalArgumentException("Missing " + fieldName);
        }
        return value.trim();
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
