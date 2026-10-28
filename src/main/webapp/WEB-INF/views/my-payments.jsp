
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.movierental.model.Payment" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    // ==========================================
    // DATA FROM PAYMENT SERVLET
    // ==========================================

    Payment selectedPayment =
            (Payment) request.getAttribute("payment");

    Movie selectedMovie =
            (Movie) request.getAttribute("movie");

    List<Payment> payments =
            (List<Payment>) request.getAttribute("payments");

    String userName =
            (String) request.getAttribute("userName");

    String paymentMessage =
            (String) request.getAttribute("paymentMessage");

    String ctx = request.getContextPath();

    // ==========================================
    // DEFAULT VALUES
    // ==========================================

    if (userName == null || userName.isBlank()) {

        Object sessionName =
                session.getAttribute("userName");

        userName = sessionName == null
                ? "Customer"
                : sessionName.toString();
    }

    // If only one payment was supplied by the
    // servlet, display that payment in the table.

    if (payments == null) {

        payments = selectedPayment == null
                ? Collections.emptyList()
                : Collections.singletonList(selectedPayment);
    }

    // ==========================================
    // PAYMENT STATISTICS
    // ==========================================

    int totalPayments = 0;
    int paidPayments = 0;
    int pendingPayments = 0;
    int failedPayments = 0;

    BigDecimal totalPaidAmount =
            BigDecimal.ZERO;

    for (Payment payment : payments) {

        if (payment == null) {
            continue;
        }

        totalPayments++;

        if (payment.isPaid()) {

            paidPayments++;

            if (payment.getAmount() != null) {

                totalPaidAmount =
                        totalPaidAmount.add(
                                payment.getAmount()
                        );
            }

        } else if (payment.isPending()) {

            pendingPayments++;

        } else if (
                payment.isFailed()
                        || payment.isRejected()
        ) {

            failedPayments++;
        }
    }

    String formattedTotalPaid =
            String.format(
                    Locale.US,
                    "LKR %,.2f",
                    totalPaidAmount
            );

    // ==========================================
    // SELECTED PAYMENT STATUS
    // ==========================================

    String selectedStatusClass = "status-unknown";
    String selectedStatusLabel = "Unknown";
    String selectedStatusIcon = "•";

    if (selectedPayment != null) {

        if (selectedPayment.isPaid()) {

            selectedStatusClass = "status-paid";
            selectedStatusLabel = "Paid";
            selectedStatusIcon = "✓";

        } else if (selectedPayment.isPending()) {

            selectedStatusClass = "status-pending";
            selectedStatusLabel = "Pending";
            selectedStatusIcon = "◷";

        } else if (selectedPayment.isRejected()) {

            selectedStatusClass = "status-failed";
            selectedStatusLabel = "Rejected";
            selectedStatusIcon = "×";

        } else if (selectedPayment.isFailed()) {

            selectedStatusClass = "status-failed";
            selectedStatusLabel = "Failed";
            selectedStatusIcon = "×";
        }
    }

    // ==========================================
    // PAYMENT MESSAGE
    // ==========================================

    if (selectedPayment != null
            && (paymentMessage == null
            || paymentMessage.isBlank())) {

        if (selectedPayment.isPending()) {

            paymentMessage =
                    "Your bank transfer request is awaiting "
                            + "administrator verification.";

        } else if (selectedPayment.isPaid()
                && selectedPayment.hasRental()) {

            paymentMessage =
                    "Your payment is recorded and "
                            + "your rental is linked.";

        } else if (selectedPayment.isPaid()) {

            paymentMessage =
                    "Your payment is recorded, but "
                            + "rental activation is not complete.";

        } else if (selectedPayment.isRejected()) {

            paymentMessage =
                    "Your payment was rejected. "
                            + "Please contact the administrator.";

        } else if (selectedPayment.isFailed()) {

            paymentMessage =
                    "Your payment failed. "
                            + "Please return to the catalogue.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>My Payments | CineRent</title>

    <link rel="stylesheet"
          href="<%= ctx %>/css/style.css">

    <style>

        /* ==========================================
           PAGE DESIGN
        ========================================== */

        .mp-page {
            min-height: 100vh;
            padding: 42px 0 75px;

            background:
                    radial-gradient(
                            circle at 85% 5%,
                            rgba(124, 58, 237, 0.15),
                            transparent 35%
                    ),
                    #0b1020;

            color: #f8fafc;
        }

        .mp-container {
            width: min(1250px, 94%);
            margin: 0 auto;
        }

        /* ==========================================
           HEADER
        ========================================== */

        .mp-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;

            margin-bottom: 30px;
        }

        .mp-eyebrow {
            display: inline-block;

            padding: 7px 13px;
            margin-bottom: 12px;

            border-radius: 30px;
            border: 1px solid rgba(167,139,250,.25);

            background: rgba(124,58,237,.13);
            color: #c4b5fd;

            font-size: 12px;
            font-weight: 700;
        }

        .mp-header h1 {
            margin: 0;

            color: #ffffff;
            font-size: clamp(28px, 4vw, 38px);
            font-weight: 800;
            letter-spacing: -1px;
        }

        .mp-header p {
            margin: 10px 0 0;

            color: #94a3b8;
            font-size: 14px;
            line-height: 1.7;
        }

        .mp-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;

            padding: 12px 17px;

            border: 1px solid #334155;
            border-radius: 11px;

            background: #1e293b;
            color: #f8fafc;

            text-decoration: none;
            font-size: 13px;
            font-weight: 650;

            transition: .2s ease;
        }

        .mp-btn:hover {
            border-color: #8b5cf6;
            background: #293651;
        }

        .mp-btn-primary {
            border-color: #7c3aed;
            background: #7c3aed;
        }

        .mp-btn-primary:hover {
            background: #6d28d9;
        }

        /* ==========================================
           STATISTICS
        ========================================== */

        .mp-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;

            margin-bottom: 30px;
        }

        .mp-stat {
            padding: 23px;

            border: 1px solid #283449;
            border-radius: 17px;

            background: #141e30;
        }

        .mp-stat-icon {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 45px;
            height: 45px;

            margin-bottom: 19px;

            border-radius: 12px;

            background: rgba(139,92,246,.15);
            font-size: 22px;
        }

        .mp-stat-label {
            color: #94a3b8;
            font-size: 13px;
        }

        .mp-stat-value {
            margin-top: 8px;

            color: #ffffff;
            font-size: 28px;
            font-weight: 800;

            overflow-wrap: anywhere;
        }

        .mp-stat-value.green {
            color: #86efac;
        }

        .mp-stat-value.yellow {
            color: #fcd34d;
        }

        .mp-stat-value.amount {
            color: #c4b5fd;
            font-size: 21px;
        }

        /* ==========================================
           SELECTED PAYMENT DETAILS
        ========================================== */

        .mp-details {
            margin-bottom: 30px;

            border: 1px solid #283449;
            border-radius: 20px;

            background: #141e30;
            overflow: hidden;
        }

        .mp-section-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;

            padding: 24px;

            border-bottom: 1px solid #283449;
        }

        .mp-section-header h2 {
            margin: 0;

            color: #ffffff;
            font-size: 19px;
            font-weight: 750;
        }

        .mp-section-header p {
            margin: 7px 0 0;

            color: #94a3b8;
            font-size: 13px;
        }

        .mp-details-body {
            padding: 25px;
        }

        .mp-detail-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 22px;
        }

        .mp-detail-label {
            margin-bottom: 7px;

            color: #64748b;
            font-size: 12px;
        }

        .mp-detail-value {
            color: #f8fafc;
            font-size: 14px;
            font-weight: 650;
            overflow-wrap: anywhere;
        }

        .mp-detail-amount {
            color: #c4b5fd;
            font-size: 23px;
            font-weight: 800;
        }

        /* ==========================================
           STATUS
        ========================================== */

        .mp-status {
            display: inline-flex;
            align-items: center;
            gap: 7px;

            padding: 7px 12px;

            border-radius: 30px;

            font-size: 11px;
            font-weight: 750;
            white-space: nowrap;
        }

        .status-paid {
            color: #86efac;
            background: rgba(16,185,129,.14);
        }

        .status-pending {
            color: #fcd34d;
            background: rgba(245,158,11,.14);
        }

        .status-failed {
            color: #fca5a5;
            background: rgba(239,68,68,.14);
        }

        .status-unknown {
            color: #cbd5e1;
            background: #334155;
        }

        /* ==========================================
           PAYMENT NOTICE
        ========================================== */

        .mp-notice {
            margin-top: 25px;
            padding: 18px;

            border: 1px solid rgba(139,92,246,.25);
            border-radius: 13px;

            background: rgba(139,92,246,.08);

            color: #cbd5e1;
            font-size: 13px;
            line-height: 1.8;
        }

        .mp-notice strong {
            display: block;
            margin-bottom: 6px;
            color: #ddd6fe;
        }

        .mp-notice-warning {
            border-color: rgba(245,158,11,.3);
            background: rgba(245,158,11,.08);
        }

        .mp-notice-warning strong {
            color: #fcd34d;
        }

        .mp-notice-error {
            border-color: rgba(239,68,68,.3);
            background: rgba(239,68,68,.08);
        }

        .mp-notice-error strong {
            color: #fca5a5;
        }

        .mp-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
            margin-top: 23px;
        }

        /* ==========================================
           HISTORY TABLE
        ========================================== */

        .mp-history {
            border: 1px solid #283449;
            border-radius: 20px;

            background: #141e30;
            overflow: hidden;
        }

        .mp-toolbar {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;

            padding: 20px 24px;
            border-bottom: 1px solid #283449;
        }

        .mp-search,
        .mp-filter {
            padding: 12px 14px;

            border: 1px solid #334155;
            border-radius: 10px;

            background: #0f172a;
            color: #f8fafc;

            font-family: inherit;
            font-size: 13px;
            outline: none;
        }

        .mp-search {
            flex: 1;
            min-width: 200px;
        }

        .mp-filter {
            min-width: 155px;
        }

        .mp-search:focus,
        .mp-filter:focus {
            border-color: #8b5cf6;
        }

        .mp-table-wrap {
            overflow-x: auto;
        }

        .mp-table {
            width: 100%;
            min-width: 890px;
            border-collapse: collapse;
        }

        .mp-table th {
            padding: 17px;

            background: #10192a;

            color: #94a3b8;
            font-size: 11px;
            font-weight: 750;
            text-transform: uppercase;
            text-align: left;
        }

        .mp-table td {
            padding: 18px 17px;

            border-top: 1px solid #283449;

            color: #cbd5e1;
            font-size: 13px;
            vertical-align: middle;
        }

        .mp-table tbody tr:hover {
            background: rgba(139,92,246,.045);
        }

        .mp-payment-id {
            color: #c4b5fd;
            font-weight: 750;
        }

        .mp-strong {
            color: #f8fafc;
            font-weight: 650;
        }

        .mp-muted {
            display: block;
            margin-top: 5px;

            color: #64748b;
            font-size: 11px;
        }

        .mp-view-link {
            color: #c4b5fd;
            text-decoration: none;
            font-weight: 700;
        }

        .mp-view-link:hover {
            color: #ddd6fe;
            text-decoration: underline;
        }

        /* ==========================================
           EMPTY STATE
        ========================================== */

        .mp-empty {
            padding: 60px 20px;
            text-align: center;
        }

        .mp-empty-icon {
            margin-bottom: 16px;
            font-size: 43px;
        }

        .mp-empty h3 {
            margin: 0 0 10px;
            color: #ffffff;
            font-size: 18px;
        }

        .mp-empty p {
            margin: 0 0 22px;
            color: #94a3b8;
            font-size: 13px;
        }

        .mp-no-results {
            display: none;
        }

        /* ==========================================
           FOOTER
        ========================================== */

        .mp-footer {
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;

            margin-top: 30px;

            color: #64748b;
            font-size: 12px;
        }

        /* ==========================================
           RESPONSIVE
        ========================================== */

        @media (max-width: 1050px) {

            .mp-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 650px) {

            .mp-page {
                padding-top: 25px;
            }

            .mp-stats,
            .mp-detail-grid {
                grid-template-columns: 1fr;
            }

            .mp-section-header,
            .mp-details-body,
            .mp-toolbar {
                padding: 18px;
            }

            .mp-search,
            .mp-filter {
                width: 100%;
                min-width: 0;
            }

            .mp-header .mp-btn {
                width: 100%;
            }
        }

    </style>

</head>

<body>

<!-- ==========================================
     CUSTOMER NAVIGATION
========================================== -->

<jsp:include
        page="/WEB-INF/views/partials/customer-nav.jsp"
/>

<!-- ==========================================
     MAIN PAGE
========================================== -->

<main class="mp-page">

    <div class="mp-container">

        <!-- ==================================
             PAGE HEADER
        =================================== -->

        <header class="mp-header">

            <div>

                <span class="mp-eyebrow">
                    💳 Customer Payments
                </span>

                <h1>My Payments</h1>

                <p>
                    Welcome,
                    <%= HtmlUtil.escape(userName) %>.
                    Track your payments and rental transactions.
                </p>

            </div>

            <a href="<%= ctx %>/catalog"
               class="mp-btn">

                ← Browse Movies

            </a>

        </header>

        <!-- ==================================
             STATISTICS
        =================================== -->

        <section class="mp-stats"
                 aria-label="Payment statistics">

            <!-- TOTAL -->

            <div class="mp-stat">

                <div class="mp-stat-icon">
                    💳
                </div>

                <div class="mp-stat-label">
                    Total Payments
                </div>

                <div class="mp-stat-value">
                    <%= totalPayments %>
                </div>

            </div>

            <!-- PAID -->

            <div class="mp-stat">

                <div class="mp-stat-icon">
                    ✓
                </div>

                <div class="mp-stat-label">
                    Paid Payments
                </div>

                <div class="mp-stat-value green">
                    <%= paidPayments %>
                </div>

            </div>

            <!-- PENDING -->

            <div class="mp-stat">

                <div class="mp-stat-icon">
                    ⏳
                </div>

                <div class="mp-stat-label">
                    Pending Payments
                </div>

                <div class="mp-stat-value yellow">
                    <%= pendingPayments %>
                </div>

            </div>

            <!-- AMOUNT -->

            <div class="mp-stat">

                <div class="mp-stat-icon">
                    📊
                </div>

                <div class="mp-stat-label">
                    Recorded Paid Amount
                </div>

                <div class="mp-stat-value amount">

                    <%= HtmlUtil.escape(
                            formattedTotalPaid
                    ) %>

                </div>

            </div>

        </section>

        <!-- ==================================
             SELECTED PAYMENT
        =================================== -->

        <%
            if (selectedPayment != null) {
        %>

        <section class="mp-details">

            <div class="mp-section-header">

                <div>

                    <h2>
                        Payment Details
                    </h2>

                    <p>
                        Transaction reference:
                        <%= HtmlUtil.escape(
                                selectedPayment.getPaymentId()
                        ) %>
                    </p>

                </div>

                <span class="mp-status <%= selectedStatusClass %>">

                    <%= selectedStatusIcon %>

                    <%= selectedStatusLabel %>

                </span>

            </div>

            <div class="mp-details-body">

                <div class="mp-detail-grid">

                    <!-- PAYMENT ID -->

                    <div>

                        <div class="mp-detail-label">
                            Payment ID
                        </div>

                        <div class="mp-detail-value">

                            <%= HtmlUtil.escape(
                                    selectedPayment.getPaymentId()
                            ) %>

                        </div>

                    </div>

                    <!-- MOVIE -->

                    <div>

                        <div class="mp-detail-label">
                            Movie
                        </div>

                        <div class="mp-detail-value">

                            <%
                                if (selectedMovie != null) {
                            %>

                            <%= HtmlUtil.escape(
                                    selectedMovie.getTitle()
                            ) %>

                            <%
                            } else {
                            %>

                            <%= HtmlUtil.escape(
                                    selectedPayment.getMovieId()
                            ) %>

                            <%
                                }
                            %>

                        </div>

                    </div>

                    <!-- PAYMENT METHOD -->

                    <div>

                        <div class="mp-detail-label">
                            Payment Method
                        </div>

                        <div class="mp-detail-value">

                            <%= HtmlUtil.escape(
                                    selectedPayment.getPaymentMethodDisplay()
                            ) %>

                        </div>

                    </div>

                    <!-- AMOUNT -->

                    <div>

                        <div class="mp-detail-label">
                            Payment Amount
                        </div>

                        <div class="mp-detail-value mp-detail-amount">

                            <%= HtmlUtil.escape(
                                    selectedPayment.getFormattedAmount()
                            ) %>

                        </div>

                    </div>

                    <!-- DATE -->

                    <div>

                        <div class="mp-detail-label">
                            Payment Created
                        </div>

                        <div class="mp-detail-value">

                            <%= HtmlUtil.escape(
                                    selectedPayment.getFormattedCreatedAt()
                            ) %>

                        </div>

                    </div>

                    <!-- RENTAL ID -->

                    <div>

                        <div class="mp-detail-label">
                            Linked Rental
                        </div>

                        <div class="mp-detail-value">

                            <%
                                if (selectedPayment.hasRental()) {
                            %>

                            <%= HtmlUtil.escape(
                                    selectedPayment.getRentalId()
                            ) %>

                            <%
                            } else {
                            %>

                            Not yet linked

                            <%
                                }
                            %>

                        </div>

                    </div>

                </div>

                <!-- ==========================
                     PAYMENT MESSAGE
                =========================== -->

                <%
                    if (paymentMessage != null
                            && !paymentMessage.isBlank()) {
                %>

                <div class="mp-notice
                    <%= selectedPayment.isPending()
                            ? "mp-notice-warning"
                            : "" %>
                    <%= selectedPayment.isFailed()
                            || selectedPayment.isRejected()
                            ? "mp-notice-error"
                            : "" %>">

                    <strong>

                        <%
                            if (selectedPayment.isPending()) {
                        %>

                        Payment Awaiting Verification

                        <%
                        } else if (selectedPayment.isPaid()
                                && selectedPayment.hasRental()) {
                        %>

                        Payment and Rental Linked

                        <%
                        } else if (selectedPayment.isPaid()) {
                        %>

                        Payment Recorded — Activation Pending

                        <%
                        } else {
                        %>

                        Payment Update

                        <%
                            }
                        %>

                    </strong>

                    <%= HtmlUtil.escape(
                            paymentMessage
                    ) %>

                </div>

                <%
                    }
                %>

                <!-- ==========================
                     BANK TRANSFER INSTRUCTIONS
                =========================== -->

                <%
                    if (selectedPayment.isPending()
                            && selectedPayment.isBankTransfer()) {
                %>

                <div class="mp-notice mp-notice-warning">

                    <strong>
                        🏦 Bank Transfer Instructions
                    </strong>

                    Complete your transfer using the bank
                    details provided by the administrator.

                    Use payment reference

                    <strong style="display:inline;">

                        <%= HtmlUtil.escape(
                                selectedPayment.getPaymentId()
                        ) %>

                    </strong>

                    when contacting the administrator.

                    Keep your transfer receipt and submit
                    it for verification.

                    Your rental will become available
                    only after payment approval and
                    successful rental activation.

                </div>

                <%
                    }
                %>

                <!-- ==========================
                     ACTION BUTTONS
                =========================== -->

                <div class="mp-actions">

                    <a href="<%= ctx %>/payments"
                       class="mp-btn">

                        All My Payments

                    </a>

                    <%
                        if (selectedPayment.isPaid()
                                && selectedPayment.hasRental()) {
                    %>

                    <a href="<%= ctx %>/rentals"
                       class="mp-btn mp-btn-primary">

                        View My Rentals

                    </a>

                    <%
                    } else {
                    %>

                    <a href="<%= ctx %>/catalog"
                       class="mp-btn">

                        Browse Movies

                    </a>

                    <%
                        }
                    %>

                </div>

            </div>

        </section>

        <%
            }
        %>

        <!-- ==================================
             PAYMENT HISTORY
        =================================== -->

        <section class="mp-history">

            <div class="mp-section-header">

                <div>

                    <h2>
                        Payment History
                    </h2>

                    <p>
                        View your payment records and statuses.
                    </p>

                </div>

                <span class="mp-status status-unknown">

                    <span id="visiblePaymentCount">
                        <%= totalPayments %>
                    </span>

                    Records

                </span>

            </div>

            <!-- SEARCH -->

            <div class="mp-toolbar">

                <input
                        type="search"
                        id="paymentSearch"
                        class="mp-search"
                        placeholder="Search payment or movie ID..."
                        aria-label="Search payments"
                >

                <select
                        id="paymentStatusFilter"
                        class="mp-filter"
                        aria-label="Filter payments by status"
                >

                    <option value="ALL">
                        All Statuses
                    </option>

                    <option value="PAID">
                        Paid
                    </option>

                    <option value="PENDING">
                        Pending
                    </option>

                    <option value="FAILED">
                        Failed
                    </option>

                    <option value="REJECTED">
                        Rejected
                    </option>

                </select>

            </div>

            <!-- PAYMENT TABLE -->

            <div class="mp-table-wrap">

                <table class="mp-table">

                    <thead>

                    <tr>

                        <th>Payment ID</th>
                        <th>Movie ID</th>
                        <th>Amount</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th>Rental ID</th>
                        <th>Date</th>
                        <th>Action</th>

                    </tr>

                    </thead>

                    <tbody>

                    <%
                        for (Payment payment : payments) {

                            if (payment == null) {
                                continue;
                            }

                            String status =
                                    payment.getPaymentStatus();

                            if (status == null) {
                                status = "UNKNOWN";
                            }

                            String statusClass =
                                    "status-unknown";

                            if (payment.isPaid()) {

                                statusClass = "status-paid";

                            } else if (payment.isPending()) {

                                statusClass = "status-pending";

                            } else if (payment.isFailed()
                                    || payment.isRejected()) {

                                statusClass = "status-failed";
                            }

                            String searchText =
                                    String.valueOf(payment.getPaymentId())
                                            + " "
                                            + String.valueOf(payment.getMovieId())
                                            + " "
                                            + payment.getPaymentMethodDisplay();
                    %>

                    <tr class="payment-row"
                        data-status="<%= HtmlUtil.escape(status) %>"
                        data-search="<%= HtmlUtil.escape(searchText) %>">

                        <!-- PAYMENT ID -->

                        <td>

                            <span class="mp-payment-id">

                                <%= HtmlUtil.escape(
                                        payment.getPaymentId()
                                ) %>

                            </span>

                        </td>

                        <!-- MOVIE ID -->

                        <td>

                            <span class="mp-strong">

                                <%= HtmlUtil.escape(
                                        payment.getMovieId()
                                ) %>

                            </span>

                        </td>

                        <!-- AMOUNT -->

                        <td>

                            <span class="mp-strong">

                                <%= HtmlUtil.escape(
                                        payment.getFormattedAmount()
                                ) %>

                            </span>

                        </td>

                        <!-- METHOD -->

                        <td>

                            <%= HtmlUtil.escape(
                                    payment.getPaymentMethodDisplay()
                            ) %>

                        </td>

                        <!-- STATUS -->

                        <td>

                            <span class="mp-status <%= statusClass %>">

                                <%= HtmlUtil.escape(status) %>

                            </span>

                        </td>

                        <!-- RENTAL -->

                        <td>

                            <%
                                if (payment.hasRental()) {
                            %>

                            <span class="mp-strong">

                                <%= HtmlUtil.escape(
                                        payment.getRentalId()
                                ) %>

                            </span>

                            <%
                            } else {
                            %>

                            <span class="mp-muted">
                                Not linked
                            </span>

                            <%
                                }
                            %>

                        </td>

                        <!-- DATE -->

                        <td>

                            <%= HtmlUtil.escape(
                                    payment.getFormattedCreatedAt()
                            ) %>

                        </td>

                        <!-- VIEW -->

                        <td>

                            <a class="mp-view-link"
                               href="<%= ctx %>/payments?paymentId=<%= HtmlUtil.escape(payment.getPaymentId()) %>">

                                View Details

                            </a>

                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

            <!-- EMPTY PAYMENT HISTORY -->

            <%
                if (totalPayments == 0) {
            %>

            <div class="mp-empty">

                <div class="mp-empty-icon">
                    💳
                </div>

                <h3>
                    No payments yet
                </h3>

                <p>
                    Your movie rental payments
                    will appear here.
                </p>

                <a href="<%= ctx %>/catalog"
                   class="mp-btn mp-btn-primary">

                    Explore Movies

                </a>

            </div>

            <%
                }
            %>

            <!-- FILTER EMPTY STATE -->

            <div
                    id="noMatchingPayments"
                    class="mp-empty mp-no-results"
            >

                <div class="mp-empty-icon">
                    🔎
                </div>

                <h3>
                    No matching payments
                </h3>

                <p>
                    Try another search or status filter.
                </p>

            </div>

        </section>

        <!-- ==================================
             FOOTER
        =================================== -->

        <footer class="mp-footer">

            <span>
                © 2026 CineRent
            </span>

            <span>
                Movie Rental & Review Platform
            </span>

        </footer>

    </div>

</main>

<!-- ==========================================
     PAYMENT SEARCH AND FILTER
========================================== -->

<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {

            const searchInput =
                document.getElementById(
                    "paymentSearch"
                );

            const statusFilter =
                document.getElementById(
                    "paymentStatusFilter"
                );

            const paymentRows =
                document.querySelectorAll(
                    ".payment-row"
                );

            const visibleCount =
                document.getElementById(
                    "visiblePaymentCount"
                );

            const noResults =
                document.getElementById(
                    "noMatchingPayments"
                );

            function filterPayments() {

                const searchValue =
                    searchInput.value
                        .trim()
                        .toLowerCase();

                const selectedStatus =
                    statusFilter.value.toUpperCase();

                let visible = 0;

                paymentRows.forEach(function (row) {

                    const searchText =
                        (row.dataset.search || "")
                            .toLowerCase();

                    const rowStatus =
                        (row.dataset.status || "")
                            .toUpperCase();

                    const matchesSearch =
                        searchText.includes(searchValue);

                    const matchesStatus =
                        selectedStatus === "ALL"
                        || rowStatus === selectedStatus;

                    const show =
                        matchesSearch && matchesStatus;

                    row.style.display =
                        show ? "" : "none";

                    if (show) {
                        visible++;
                    }
                });

                visibleCount.textContent = visible;

                noResults.style.display =
                    paymentRows.length > 0
                    && visible === 0
                        ? "block"
                        : "none";
            }

            searchInput.addEventListener(
                "input",
                filterPayments
            );

            statusFilter.addEventListener(
                "change",
                filterPayments
            );

        }
    );

</script>

</body>
</html>
