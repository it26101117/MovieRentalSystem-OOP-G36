
package com.movierental.servlet;

import com.movierental.model.Payment;
import com.movierental.service.PaymentService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.List;

@WebServlet(
        name = "AdminPaymentServlet",
        urlPatterns = {"/admin/payments"}
)
public class AdminPaymentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String VIEW_PATH =
            "/WEB-INF/views/admin-payments.jsp";

    private static final String CSRF_SESSION_KEY =
            "adminPaymentCsrfToken";

    private static final String FLASH_MESSAGE_KEY =
            "adminPaymentFlashMessage";

    private static final String FLASH_TYPE_KEY =
            "adminPaymentFlashType";

    private PaymentService paymentService;

    private final SecureRandom secureRandom =
            new SecureRandom();

    // ==========================================
    // INITIALIZE PAYMENT SERVICE
    // ==========================================

    @Override
    public void init() throws ServletException {

        try {

            String paymentFilePath =
                    DataPathUtil.getFilePath("payments.txt");

            paymentService =
                    new PaymentService(paymentFilePath);

        } catch (Exception e) {

            throw new ServletException(
                    "Failed to initialize Admin Payment Servlet.",
                    e
            );
        }
    }

    // ==========================================
    // GET - ADMIN PAYMENT DASHBOARD
    // ==========================================

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        if (!checkAdminAccess(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);

        try {

            // Retrieve payment records
            List<Payment> payments =
                    paymentService.getAllPayments();

            // Payment statistics
            int totalPayments =
                    paymentService.getTotalPaymentCount();

            int pendingPayments =
                    paymentService.getPendingPaymentCount();

            int paidPayments =
                    paymentService.getPaidPaymentCount();

            int failedPayments =
                    paymentService.getPaymentsByStatus(
                            PaymentService.FAILED
                    ).size();

            int rejectedPayments =
                    paymentService.getPaymentsByStatus(
                            PaymentService.REJECTED
                    ).size();

            BigDecimal totalRevenue =
                    paymentService.getTotalPaidAmount();

            // Admin information
            Object userName =
                    session.getAttribute("userName");

            String adminName =
                    userName == null
                            ? "Administrator"
                            : userName.toString();

            // Create or retrieve CSRF token
            String csrfToken =
                    getOrCreateCsrfToken(session);

            // Set JSP attributes
            request.setAttribute(
                    "payments",
                    payments
            );

            request.setAttribute(
                    "totalPayments",
                    totalPayments
            );

            request.setAttribute(
                    "pendingPayments",
                    pendingPayments
            );

            request.setAttribute(
                    "paidPayments",
                    paidPayments
            );

            request.setAttribute(
                    "failedPayments",
                    failedPayments
            );

            request.setAttribute(
                    "rejectedPayments",
                    rejectedPayments
            );

            request.setAttribute(
                    "totalRevenue",
                    totalRevenue
            );

            request.setAttribute(
                    "adminName",
                    adminName
            );

            request.setAttribute(
                    "csrfToken",
                    csrfToken
            );

            // Retrieve flash messages
            Object flashMessage =
                    session.getAttribute(
                            FLASH_MESSAGE_KEY
                    );

            Object flashType =
                    session.getAttribute(
                            FLASH_TYPE_KEY
                    );

            if (flashMessage != null) {

                request.setAttribute(
                        "paymentMessage",
                        flashMessage.toString()
                );

                request.setAttribute(
                        "paymentMessageType",
                        flashType == null
                                ? "info"
                                : flashType.toString()
                );

                session.removeAttribute(
                        FLASH_MESSAGE_KEY
                );

                session.removeAttribute(
                        FLASH_TYPE_KEY
                );
            }

            // Display payment dashboard
            request.getRequestDispatcher(
                    VIEW_PATH
            ).forward(request, response);

        } catch (Exception e) {

            getServletContext().log(
                    "Failed to load admin payments.",
                    e
            );

            response.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load payment records."
            );
        }
    }

    // ==========================================
    // POST - PROCESS ADMIN PAYMENT ACTIONS
    // ==========================================

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws ServletException, IOException {

        if (!checkAdminAccess(request, response)) {
            return;
        }

        HttpSession session = request.getSession(false);

        // Verify CSRF token before changing data
        String submittedToken =
                request.getParameter("csrfToken");

        if (!isValidCsrfToken(
                session,
                submittedToken
        )) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid CSRF token."
            );

            return;
        }

        String action =
                request.getParameter("action");

        String paymentId =
                request.getParameter("paymentId");

        if (action == null || action.isBlank()
                || paymentId == null
                || paymentId.isBlank()) {

            setFlashMessage(
                    session,
                    "Invalid payment request.",
                    "error"
            );

            redirectToPayments(response, request);
            return;
        }

        action = action.trim()
                .toLowerCase(java.util.Locale.ROOT);

        paymentId = paymentId.trim();

        try {

            Payment payment =
                    paymentService.getPaymentById(
                            paymentId
                    );

            if (payment == null) {

                setFlashMessage(
                        session,
                        "Payment record was not found.",
                        "error"
                );

                redirectToPayments(response, request);
                return;
            }

            // Only bank transfers require
            // manual administrator approval.
            if (!payment.isBankTransfer()) {

                setFlashMessage(
                        session,
                        "Only bank transfers can be manually approved or rejected.",
                        "error"
                );

                redirectToPayments(response, request);
                return;
            }

            // Prevent processing completed payments
            if (!payment.isPending()) {

                setFlashMessage(
                        session,
                        "This payment has already been processed.",
                        "error"
                );

                redirectToPayments(response, request);
                return;
            }

            switch (action) {

                // ==============================
                // APPROVE BANK TRANSFER
                // ==============================

                case "approve":

                    paymentService.markPaymentPaid(
                            paymentId
                    );

                    setFlashMessage(
                            session,
                            "Bank transfer approved successfully.",
                            "success"
                    );

                    break;

                // ==============================
                // REJECT BANK TRANSFER
                // ==============================

                case "reject":

                    paymentService.rejectPayment(
                            paymentId
                    );

                    setFlashMessage(
                            session,
                            "Bank transfer rejected successfully.",
                            "success"
                    );

                    break;

                // ==============================
                // INVALID ACTION
                // ==============================

                default:

                    setFlashMessage(
                            session,
                            "Unsupported payment action.",
                            "error"
                    );

                    break;
            }

        } catch (IllegalArgumentException
                 | IllegalStateException e) {

            getServletContext().log(
                    "Admin payment operation failed.",
                    e
            );

            setFlashMessage(
                    session,
                    "Payment operation could not be completed.",
                    "error"
            );

        } catch (Exception e) {

            getServletContext().log(
                    "Unexpected payment processing error.",
                    e
            );

            setFlashMessage(
                    session,
                    "An unexpected error occurred.",
                    "error"
            );
        }

        // Post/Redirect/Get pattern
        redirectToPayments(response, request);
    }

    // ==========================================
    // ADMIN ACCESS VALIDATION
    // ==========================================

    private boolean checkAdminAccess(
            HttpServletRequest request,
            HttpServletResponse response
    ) throws IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return false;
        }

        Object role =
                session.getAttribute("role");

        if (role == null) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/login"
            );

            return false;
        }

        if (!"admin".equalsIgnoreCase(
                role.toString()
        )) {

            response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access required."
            );

            return false;
        }

        return true;
    }

    // ==========================================
    // GENERATE CSRF TOKEN
    // ==========================================

    private String getOrCreateCsrfToken(
            HttpSession session
    ) {

        Object existingToken =
                session.getAttribute(
                        CSRF_SESSION_KEY
                );

        if (existingToken instanceof String
                && !((String) existingToken).isBlank()) {

            return (String) existingToken;
        }

        byte[] randomBytes = new byte[32];

        secureRandom.nextBytes(randomBytes);

        String token = Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(randomBytes);

        session.setAttribute(
                CSRF_SESSION_KEY,
                token
        );

        return token;
    }

    // ==========================================
    // VALIDATE CSRF TOKEN
    // ==========================================

    private boolean isValidCsrfToken(
            HttpSession session,
            String submittedToken
    ) {

        if (session == null
                || submittedToken == null) {

            return false;
        }

        Object storedToken =
                session.getAttribute(
                        CSRF_SESSION_KEY
                );

        if (!(storedToken instanceof String)) {
            return false;
        }

        byte[] expected =
                ((String) storedToken).getBytes(
                        StandardCharsets.UTF_8
                );

        byte[] actual =
                submittedToken.getBytes(
                        StandardCharsets.UTF_8
                );

        return MessageDigest.isEqual(
                expected,
                actual
        );
    }

    // ==========================================
    // FLASH MESSAGE HELPER
    // ==========================================

    private void setFlashMessage(
            HttpSession session,
            String message,
            String type
    ) {

        session.setAttribute(
                FLASH_MESSAGE_KEY,
                message
        );

        session.setAttribute(
                FLASH_TYPE_KEY,
                type
        );
    }

    // ==========================================
    // REDIRECT TO PAYMENT DASHBOARD
    // ==========================================

    private void redirectToPayments(
            HttpServletResponse response,
            HttpServletRequest request
    ) throws IOException {

        response.sendRedirect(
                request.getContextPath()
                        + "/admin/payments"
        );
    }
}
