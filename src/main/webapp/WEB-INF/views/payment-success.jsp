
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.model.Payment" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    // ==========================================
    // PAYMENT DATA FROM SERVLET
    // ==========================================

    Payment payment =
            (Payment) request.getAttribute("payment");

    Movie movie =
            (Movie) request.getAttribute("movie");

    String userName =
            (String) request.getAttribute("userName");

    String paymentMessage =
            (String) request.getAttribute("paymentMessage");

    String ctx = request.getContextPath();

    // ==========================================
    // VALIDATE PAYMENT DATA
    // ==========================================

    if (payment == null) {

        response.sendError(
                HttpServletResponse.SC_NOT_FOUND,
                "Payment information not found."
        );

        return;
    }

    // IMPORTANT:
    // The PaymentServlet must authenticate
    // the customer and verify payment ownership
    // before forwarding to this JSP.

    if (userName == null || userName.isBlank()) {

        Object sessionName =
                session.getAttribute("userName");

        userName = sessionName == null
                ? "Customer"
                : sessionName.toString();
    }

    // ==========================================
    // PAYMENT STATUS
    // ==========================================

    boolean isPaid = payment.isPaid();
    boolean isPending = payment.isPending();
    boolean isFailed = payment.isFailed();
    boolean isRejected = payment.isRejected();

    boolean hasRental = payment.hasRental();

    boolean isDemoCard =
            payment.isDemoCardPayment();

    boolean isBankTransfer =
            payment.isBankTransfer();

    // A PAID record does not automatically
    // mean the rental is active.

    boolean rentalReady =
            isPaid && hasRental;

    // ==========================================
    // STATUS DISPLAY
    // ==========================================

    String statusTitle;
    String statusDescription;
    String statusIcon;
    String statusClass;
    String statusLabel;

    if (isPaid) {

        statusTitle = "Payment Recorded Successfully!";

        statusDescription =
                "Your payment has been recorded "
                        + "in the CineRent system.";

        statusIcon = "✓";
        statusClass = "success";
        statusLabel = "PAID";

    } else if (isPending) {

        statusTitle = "Payment Awaiting Verification";

        statusDescription =
                "Your payment request has been created "
                        + "and is awaiting administrator approval.";

        statusIcon = "◷";
        statusClass = "pending";
        statusLabel = "PENDING";

    } else if (isRejected) {

        statusTitle = "Payment Rejected";

        statusDescription =
                "This payment was rejected. "
                        + "Please contact the administrator.";

        statusIcon = "×";
        statusClass = "failed";
        statusLabel = "REJECTED";

    } else if (isFailed) {

        statusTitle = "Payment Failed";

        statusDescription =
                "The payment could not be completed.";

        statusIcon = "×";
        statusClass = "failed";
        statusLabel = "FAILED";

    } else {

        statusTitle = "Payment Status";

        statusDescription =
                "Your payment status is currently unavailable.";

        statusIcon = "!";
        statusClass = "unknown";
        statusLabel = "UNKNOWN";
    }

    // ==========================================
    // MOVIE INFORMATION
    // ==========================================

    String movieTitle =
            movie == null
                    ? payment.getMovieId()
                    : movie.getTitle();

    if (movieTitle == null || movieTitle.isBlank()) {
        movieTitle = "Movie";
    }

    String movieGenre =
            movie == null || movie.getGenre() == null
                    ? ""
                    : movie.getGenre();

    // ==========================================
    // PAYMENT INFORMATION
    // ==========================================

    String paymentId =
            payment.getPaymentId();

    String movieId =
            payment.getMovieId();

    String rentalId =
            payment.getRentalId();

    String formattedAmount =
            payment.getFormattedAmount();

    String formattedDate =
            payment.getFormattedCreatedAt();

    String paymentMethod =
            payment.getPaymentMethodDisplay();

    if (paymentMessage == null) {
        paymentMessage = "";
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Payment Confirmation | CineRent
    </title>

    <link rel="stylesheet"
          href="<%= ctx %>/css/style.css">

    <style>

        /* ==========================================
           PAGE
        ========================================== */

        .ps-page {
            min-height: 100vh;
            padding: 55px 20px 85px;

            background:
                    radial-gradient(
                            circle at 50% 0%,
                            rgba(124,58,237,0.18),
                            transparent 42%
                    ),
                    #0b1020;

            color: #f8fafc;
        }

        .ps-container {
            max-width: 790px;
            margin: 0 auto;
        }

        /* ==========================================
           SUCCESS CARD
        ========================================== */

        .ps-card {
            overflow: hidden;

            border: 1px solid #293449;
            border-radius: 24px;

            background: #141e30;

            box-shadow:
                    0 24px 75px rgba(0,0,0,0.22);
        }

        .ps-status-header {
            padding: 45px 30px 35px;
            text-align: center;

            background:
                    linear-gradient(
                            180deg,
                            rgba(139,92,246,0.09),
                            transparent
                    );
        }

        /* ==========================================
           STATUS ICON
        ========================================== */

        .ps-status-icon {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 92px;
            height: 92px;

            margin: 0 auto 25px;

            border-radius: 50%;

            font-size: 43px;
            font-weight: 800;
        }

        .ps-status-icon.success {
            color: #86efac;
            background: rgba(16,185,129,0.14);
            border: 2px solid rgba(16,185,129,0.3);
        }

        .ps-status-icon.pending {
            color: #fcd34d;
            background: rgba(245,158,11,0.14);
            border: 2px solid rgba(245,158,11,0.3);
        }

        .ps-status-icon.failed {
            color: #fca5a5;
            background: rgba(239,68,68,0.14);
            border: 2px solid rgba(239,68,68,0.3);
        }

        .ps-status-icon.unknown {
            color: #cbd5e1;
            background: #334155;
            border: 2px solid #475569;
        }

        /* ==========================================
           HEADER TEXT
        ========================================== */

        .ps-eyebrow {
            display: inline-block;

            padding: 7px 13px;
            margin-bottom: 15px;

            border: 1px solid rgba(167,139,250,0.25);
            border-radius: 30px;

            background: rgba(139,92,246,0.12);
            color: #c4b5fd;

            font-size: 11px;
            font-weight: 750;
            letter-spacing: 0.7px;
            text-transform: uppercase;
        }

        .ps-status-header h1 {
            margin: 0 0 13px;

            color: #ffffff;
            font-size: clamp(25px, 4vw, 34px);
            font-weight: 800;
            letter-spacing: -0.8px;
        }

        .ps-status-header p {
            max-width: 490px;
            margin: 0 auto;

            color: #94a3b8;
            font-size: 14px;
            line-height: 1.8;
        }

        /* ==========================================
           STATUS BADGE
        ========================================== */

        .ps-status-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;

            margin-top: 22px;
            padding: 9px 15px;

            border-radius: 30px;

            font-size: 12px;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .ps-status-badge.success {
            color: #86efac;
            background: rgba(16,185,129,0.13);
        }

        .ps-status-badge.pending {
            color: #fcd34d;
            background: rgba(245,158,11,0.13);
        }

        .ps-status-badge.failed {
            color: #fca5a5;
            background: rgba(239,68,68,0.13);
        }

        .ps-status-badge.unknown {
            color: #cbd5e1;
            background: #334155;
        }

        /* ==========================================
           CONTENT
        ========================================== */

        .ps-content {
            padding: 30px;
        }

        .ps-section-title {
            margin: 0 0 22px;

            color: #ffffff;
            font-size: 18px;
            font-weight: 750;
        }

        /* ==========================================
           MOVIE SUMMARY
        ========================================== */

        .ps-movie-box {
            display: flex;
            align-items: center;
            gap: 16px;

            margin-bottom: 28px;
            padding: 20px;

            border: 1px solid #334155;
            border-radius: 15px;

            background: #10192a;
        }

        .ps-movie-icon {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 65px;
            height: 75px;

            flex-shrink: 0;

            border-radius: 11px;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #312e81
                    );

            font-size: 28px;
        }

        .ps-movie-details {
            min-width: 0;
        }

        .ps-movie-details h3 {
            margin: 0 0 7px;

            color: #ffffff;
            font-size: 18px;
            font-weight: 750;
            overflow-wrap: anywhere;
        }

        .ps-movie-details p {
            margin: 5px 0;

            color: #94a3b8;
            font-size: 12px;
        }

        /* ==========================================
           TRANSACTION DETAILS
        ========================================== */

        .ps-detail-list {
            display: grid;
            gap: 0;
        }

        .ps-detail-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;

            padding: 17px 0;

            border-bottom: 1px solid #283449;
        }

        .ps-detail-row:last-child {
            border-bottom: none;
        }

        .ps-detail-label {
            color: #94a3b8;
            font-size: 13px;
        }

        .ps-detail-value {
            color: #f8fafc;
            font-size: 13px;
            font-weight: 700;
            text-align: right;
            overflow-wrap: anywhere;
        }

        .ps-payment-id {
            color: #c4b5fd;
        }

        .ps-total {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;

            margin-top: 12px;
            padding: 22px;

            border-radius: 14px;

            background: rgba(139,92,246,0.1);
            border: 1px solid rgba(139,92,246,0.2);
        }

        .ps-total-label {
            color: #e2e8f0;
            font-size: 15px;
            font-weight: 750;
        }

        .ps-total-amount {
            color: #c4b5fd;
            font-size: 24px;
            font-weight: 800;
            text-align: right;
        }

        /* ==========================================
           NOTICE
        ========================================== */

        .ps-notice {
            margin-top: 26px;
            padding: 19px 20px;

            border: 1px solid rgba(139,92,246,0.3);
            border-radius: 13px;

            background: rgba(139,92,246,0.08);

            color: #cbd5e1;
            font-size: 13px;
            line-height: 1.8;
        }

        .ps-notice strong {
            display: block;
            margin-bottom: 7px;

            color: #ddd6fe;
            font-size: 13px;
        }

        .ps-notice-warning {
            border-color: rgba(245,158,11,0.3);
            background: rgba(245,158,11,0.08);
        }

        .ps-notice-warning strong {
            color: #fcd34d;
        }

        .ps-notice-success {
            border-color: rgba(16,185,129,0.3);
            background: rgba(16,185,129,0.08);
        }

        .ps-notice-success strong {
            color: #86efac;
        }

        .ps-notice-error {
            border-color: rgba(239,68,68,0.3);
            background: rgba(239,68,68,0.08);
        }

        .ps-notice-error strong {
            color: #fca5a5;
        }

        /* ==========================================
           ACTION BUTTONS
        ========================================== */

        .ps-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 13px;

            margin-top: 30px;
        }

        .ps-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;

            min-height: 48px;
            padding: 13px 16px;

            border: 1px solid #334155;
            border-radius: 12px;

            background: #1e293b;
            color: #f8fafc;

            font-family: inherit;
            font-size: 13px;
            font-weight: 750;
            text-decoration: none;

            cursor: pointer;
            transition: .2s ease;
        }

        .ps-btn:hover {
            border-color: #8b5cf6;
            background: #293651;
        }

        .ps-btn-primary {
            border-color: #7c3aed;
            background:
                    linear-gradient(
                            135deg,
                            #7c3aed,
                            #5b21b6
                    );
        }

        .ps-btn-primary:hover {
            filter: brightness(1.12);
        }

        .ps-print-btn {
            width: 100%;
            margin-top: 13px;
        }

        /* ==========================================
           FOOTER
        ========================================== */

        .ps-footer {
            margin-top: 28px;

            color: #64748b;
            font-size: 12px;
            text-align: center;
            line-height: 1.8;
        }

        /* ==========================================
           RESPONSIVE
        ========================================== */

        @media (max-width: 600px) {

            .ps-page {
                padding: 25px 12px 60px;
            }

            .ps-status-header {
                padding: 35px 20px 28px;
            }

            .ps-content {
                padding: 20px;
            }

            .ps-status-icon {
                width: 75px;
                height: 75px;
                font-size: 34px;
            }

            .ps-actions {
                grid-template-columns: 1fr;
            }

            .ps-total-amount {
                font-size: 19px;
            }

            .ps-detail-label,
            .ps-detail-value {
                font-size: 12px;
            }
        }

        /* ==========================================
           PRINT STYLES
        ========================================== */

        @media print {

            body {
                background: #ffffff !important;
                color: #111827 !important;
            }

            .ps-page {
                background: #ffffff !important;
                padding: 0;
            }

            .ps-card {
                background: #ffffff !important;
                border: 1px solid #d1d5db;
                box-shadow: none;
            }

            .ps-card * {
                color: #111827 !important;
            }

            .ps-status-header {
                background: #ffffff !important;
            }

            .ps-actions,
            .ps-print-btn,
            .ps-footer,
            .ps-hide-print {
                display: none !important;
            }

            .ps-total,
            .ps-movie-box,
            .ps-notice {
                background: #ffffff !important;
            }
        }

    </style>

</head>

<body>

<!-- ==========================================
     CUSTOMER NAVIGATION
========================================== -->

<div class="ps-hide-print">

    <jsp:include
            page="/WEB-INF/views/partials/customer-nav.jsp"
    />

</div>

<!-- ==========================================
     PAYMENT CONFIRMATION
========================================== -->

<main class="ps-page">

    <div class="ps-container">

        <section class="ps-card">

            <!-- ==================================
                 STATUS HEADER
            =================================== -->

            <header class="ps-status-header">

                <div class="ps-status-icon <%= statusClass %>">

                    <%= statusIcon %>

                </div>

                <div class="ps-eyebrow">
                    🎬 CineRent Payments
                </div>

                <h1>

                    <%= HtmlUtil.escape(statusTitle) %>

                </h1>

                <p>

                    <%= HtmlUtil.escape(statusDescription) %>

                </p>

                <span class="ps-status-badge <%= statusClass %>">

                    <%= statusIcon %>

                    <%= statusLabel %>

                </span>

            </header>

            <!-- ==================================
                 PAYMENT CONTENT
            =================================== -->

            <div class="ps-content">

                <!-- MOVIE INFORMATION -->

                <h2 class="ps-section-title">
                    Movie Rental
                </h2>

                <div class="ps-movie-box">

                    <div class="ps-movie-icon">
                        🎬
                    </div>

                    <div class="ps-movie-details">

                        <h3>

                            <%= HtmlUtil.escape(movieTitle) %>

                        </h3>

                        <p>

                            Movie ID:

                            <%= HtmlUtil.escape(movieId) %>

                        </p>

                        <%
                            if (!movieGenre.isBlank()) {
                        %>

                        <p>

                            Genre:

                            <%= HtmlUtil.escape(movieGenre) %>

                        </p>

                        <%
                            }
                        %>

                        <p>

                            Customer:

                            <%= HtmlUtil.escape(userName) %>

                        </p>

                    </div>

                </div>

                <!-- ==================================
                     TRANSACTION DETAILS
                =================================== -->

                <h2 class="ps-section-title">
                    Transaction Details
                </h2>

                <div class="ps-detail-list">

                    <!-- PAYMENT ID -->

                    <div class="ps-detail-row">

                        <span class="ps-detail-label">
                            Payment Reference
                        </span>

                        <span class="ps-detail-value ps-payment-id"
                              id="paymentReference">

                            <%= HtmlUtil.escape(paymentId) %>

                        </span>

                    </div>

                    <!-- METHOD -->

                    <div class="ps-detail-row">

                        <span class="ps-detail-label">
                            Payment Method
                        </span>

                        <span class="ps-detail-value">

                            <%= HtmlUtil.escape(paymentMethod) %>

                        </span>

                    </div>

                    <!-- DATE -->

                    <div class="ps-detail-row">

                        <span class="ps-detail-label">
                            Payment Created
                        </span>

                        <span class="ps-detail-value">

                            <%= HtmlUtil.escape(formattedDate) %>

                        </span>

                    </div>

                    <!-- STATUS -->

                    <div class="ps-detail-row">

                        <span class="ps-detail-label">
                            Payment Status
                        </span>

                        <span class="ps-detail-value">

                            <%= statusLabel %>

                        </span>

                    </div>

                    <!-- RENTAL -->

                    <div class="ps-detail-row">

                        <span class="ps-detail-label">
                            Rental Reference
                        </span>

                        <span class="ps-detail-value">

                            <%
                                if (hasRental) {
                            %>

                            <%= HtmlUtil.escape(rentalId) %>

                            <%
                            } else {
                            %>

                            Not yet linked

                            <%
                                }
                            %>

                        </span>

                    </div>

                </div>

                <!-- ==================================
                     TOTAL
                =================================== -->

                <div class="ps-total">

                    <span class="ps-total-label">
                        Payment Amount
                    </span>

                    <span class="ps-total-amount">

                        <%= HtmlUtil.escape(formattedAmount) %>

                    </span>

                </div>

                <!-- ==================================
                     RENTAL ACTIVATION NOTICE
                =================================== -->

                <%
                    if (rentalReady) {
                %>

                <div class="ps-notice ps-notice-success">

                    <strong>
                        ✓ Rental Linked Successfully
                    </strong>

                    Your payment has been recorded and
                    linked to rental

                    <%= HtmlUtil.escape(rentalId) %>.

                    Visit My Rentals to check its
                    current rental status and availability.

                </div>

                <%
                } else if (isPaid) {
                %>

                <div class="ps-notice ps-notice-warning">

                    <strong>
                        ◷ Rental Activation Pending
                    </strong>

                    Your payment is marked as PAID,
                    but no rental has been linked yet.

                    Please wait for rental activation
                    or contact the administrator with
                    your payment reference.

                    Do not submit another payment
                    for this transaction.

                </div>

                <%
                } else if (isPending && isBankTransfer) {
                %>

                <div class="ps-notice ps-notice-warning">

                    <strong>
                        🏦 Bank Transfer Instructions
                    </strong>

                    Your payment request is pending.

                    Obtain the correct bank details
                    from the administrator and
                    complete your transfer.

                    Use your payment ID as the reference:

                    <strong style="display:inline;">

                        <%= HtmlUtil.escape(paymentId) %>

                    </strong>

                    Keep your receipt and submit it
                    to the administrator for verification.

                    Your movie rental will not be
                    activated until payment approval
                    and rental creation are completed.

                </div>

                <%
                } else if (isFailed || isRejected) {
                %>

                <div class="ps-notice ps-notice-error">

                    <strong>
                        Payment Not Completed
                    </strong>

                    This payment is not approved.

                    Please contact the administrator
                    if you believe this is an error.

                </div>

                <%
                    }
                %>

                <!-- ==================================
                     DEMO PAYMENT NOTICE
                =================================== -->

                <%
                    if (isDemoCard) {
                %>

                <div class="ps-notice">

                    <strong>
                        Demo Card Payment
                    </strong>

                    This transaction is a simulated
                    payment for the CineRent academic
                    project.

                    No actual bank card was charged,
                    and no real money was collected.

                </div>

                <%
                    }
                %>

                <!-- ==================================
                     OPTIONAL SERVLET MESSAGE
                =================================== -->

                <%
                    if (!paymentMessage.isBlank()) {
                %>

                <div class="ps-notice">

                    <strong>
                        Payment Information
                    </strong>

                    <%= HtmlUtil.escape(paymentMessage) %>

                </div>

                <%
                    }
                %>

                <!-- ==================================
                     ACTION BUTTONS
                =================================== -->

                <div class="ps-actions">

                    <!-- MY PAYMENTS -->

                    <a href="<%= ctx %>/payments"
                       class="ps-btn">

                        💳 My Payments

                    </a>

                    <!-- MY RENTALS OR CATALOG -->

                    <%
                        if (rentalReady) {
                    %>

                    <a href="<%= ctx %>/rentals"
                       class="ps-btn ps-btn-primary">

                        🎬 View My Rentals

                    </a>

                    <%
                    } else {
                    %>

                    <a href="<%= ctx %>/catalog"
                       class="ps-btn ps-btn-primary">

                        🎥 Browse Movies

                    </a>

                    <%
                        }
                    %>

                </div>

                <!-- PRINT PAYMENT RECORD -->

                <button
                        type="button"
                        class="ps-btn ps-print-btn"
                        onclick="window.print()"
                >

                    🖨 Print Payment Record

                </button>

            </div>

        </section>

        <!-- ==================================
             FOOTER
        =================================== -->

        <footer class="ps-footer">

            © 2026 CineRent

            <div>
                Movie Rental & Review Platform
            </div>

            <div>
                Payment references are generated
                by the CineRent system.
            </div>

        </footer>

    </div>

</main>

</body>
</html>
