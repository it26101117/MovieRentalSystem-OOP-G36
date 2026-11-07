package com.movierental.servlet;

import com.movierental.model.Payment;
import com.movierental.service.PayHereGateway;
import com.movierental.service.PaymentService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Locale;

/**
 * Handles PayHere server-to-server payment notifications.
 *
 * Endpoint: POST /payhere/notify
 *
 * This endpoint must be publicly accessible. A valid PayHere signature
 * is required before a payment status can change.
 */
@WebServlet(name = "PayHereNotifyServlet", urlPatterns = "/payhere/notify")
public class PayHereNotifyServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private PaymentService paymentService;

    @Override
    public void init() throws ServletException {
        try {
            paymentService = new PaymentService(
                    DataPathUtil.getFilePath("payments.txt")
            );
        } catch (RuntimeException ex) {
            throw new ServletException(
                    "Could not initialize PayHere payment storage", ex
            );
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        response.setHeader("X-Content-Type-Options", "nosniff");

        // PayHere sends a form-encoded POST rather than JSON.
        String contentType = request.getContentType();
        if (contentType == null || !contentType.toLowerCase(Locale.ROOT)
                .startsWith("application/x-www-form-urlencoded")) {
            reply(response, HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE,
                    "Expected form-encoded PayHere notification");
            return;
        }

        // Reject duplicate values of signed fields to avoid ambiguous parsing.
        String[] signedFields = {
                "merchant_id", "order_id", "payhere_amount",
                "payhere_currency", "status_code", "md5sig", "payment_id"
        };
        for (String field : signedFields) {
            String[] values = request.getParameterValues(field);
            if (values != null && values.length != 1) {
                reply(response, HttpServletResponse.SC_BAD_REQUEST,
                        "Duplicate notification parameter: " + field);
                return;
            }
        }

        String merchantId = request.getParameter("merchant_id");
        String orderId = request.getParameter("order_id");
        String amountText = request.getParameter("payhere_amount");
        String currency = request.getParameter("payhere_currency");
        String statusText = request.getParameter("status_code");
        String signature = request.getParameter("md5sig");
        String gatewayPaymentId = request.getParameter("payment_id");

        // Initialize credentials here so missing configuration does not stop
        // the entire web application from starting.
        final PayHereGateway gateway;
        try {
            gateway = new PayHereGateway();
        } catch (IllegalArgumentException | IllegalStateException ex) {
            getServletContext().log(
                    "[CineRent] PayHere merchant configuration is missing or invalid", ex);
            reply(response, HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "PayHere is not configured on this server");
            return;
        }

        try {
            // Check the signature before trusting the callback fields.
            if (!gateway.verifyNotification(
                    merchantId, orderId, amountText,
                    currency, statusText, signature)) {
                getServletContext().log(
                        "[CineRent] Rejected PayHere notification: invalid signature");
                reply(response, HttpServletResponse.SC_BAD_REQUEST,
                        "Invalid notification signature");
                return;
            }

            BigDecimal reportedAmount = new BigDecimal(amountText);
            int statusCode = Integer.parseInt(statusText);

            // PaymentService also validates the stored order, currency,
            // amount, payment method, transaction ID, and status transition.
            Payment updatedPayment = paymentService.applyVerifiedPayHereNotification(
                    orderId, gatewayPaymentId, reportedAmount,
                    currency, statusCode
            );

            if ("CHARGEBACK".equalsIgnoreCase(updatedPayment.getPaymentStatus())) {
                getServletContext().log(
                        "[CineRent] ACTION REQUIRED: PayHere chargeback for order "
                                + updatedPayment.getPaymentId()
                                + ". Revoke any associated rental access.");
            }

            getServletContext().log(
                    "[CineRent] Verified PayHere notification: order="
                            + updatedPayment.getPaymentId()
                            + ", status=" + updatedPayment.getPaymentStatus());

            // Acknowledge only after the updated payment has been saved.
            reply(response, HttpServletResponse.SC_OK, "OK");

        } catch (NumberFormatException ex) {
            getServletContext().log("[CineRent] Invalid PayHere amount/status", ex);
            reply(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid notification amount or status");

        } catch (IllegalArgumentException ex) {
            getServletContext().log("[CineRent] Invalid PayHere order data", ex);
            reply(response, HttpServletResponse.SC_BAD_REQUEST,
                    "Invalid notification data");

        } catch (RuntimeException ex) {
            getServletContext().log("[CineRent] PayHere processing failed", ex);
            reply(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Temporary payment processing failure");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.setHeader("Allow", "POST");
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                "PayHere notifications must use POST");
    }

    private static void reply(HttpServletResponse response, int status, String text)
            throws IOException {
        response.setStatus(status);
        response.getWriter().write(text);
    }
}
