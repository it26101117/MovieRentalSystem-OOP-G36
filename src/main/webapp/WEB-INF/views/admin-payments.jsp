
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.movierental.model.Payment" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    // ==========================================
    // DATA FROM ADMIN PAYMENT SERVLET
    // ==========================================

    List<Payment> payments =
            (List<Payment>) request.getAttribute("payments");

    Integer totalPayments =
            (Integer) request.getAttribute("totalPayments");

    Integer pendingPayments =
            (Integer) request.getAttribute("pendingPayments");

    Integer paidPayments =
            (Integer) request.getAttribute("paidPayments");

    Integer failedPayments =
            (Integer) request.getAttribute("failedPayments");

    Integer rejectedPayments =
            (Integer) request.getAttribute("rejectedPayments");

    BigDecimal totalRevenue =
            (BigDecimal) request.getAttribute("totalRevenue");

    String adminName =
            (String) request.getAttribute("adminName");

    String csrfToken =
            (String) request.getAttribute("csrfToken");

    String paymentMessage =
            (String) request.getAttribute("paymentMessage");

    String paymentMessageType =
            (String) request.getAttribute("paymentMessageType");

    // ==========================================
    // DEFAULT VALUES
    // ==========================================

    if (totalPayments == null) totalPayments = 0;
    if (pendingPayments == null) pendingPayments = 0;
    if (paidPayments == null) paidPayments = 0;
    if (failedPayments == null) failedPayments = 0;
    if (rejectedPayments == null) rejectedPayments = 0;

    if (totalRevenue == null) {
        totalRevenue = BigDecimal.ZERO;
    }

    if (adminName == null || adminName.isBlank()) {
        adminName = "Administrator";
    }

    if (csrfToken == null) {
        csrfToken = "";
    }

    String ctx = request.getContextPath();

    String revenueDisplay = String.format(
            Locale.US,
            "%,.2f",
            totalRevenue
    );

    boolean hasPayments =
            payments != null && !payments.isEmpty();

    boolean successMessage =
            "success".equalsIgnoreCase(paymentMessageType);
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Payment Management | CineRent Admin</title>

    <link rel="stylesheet"
          href="<%= ctx %>/css/style.css">

    <style>

        /* ==========================================
           CINE RENT PAYMENT DASHBOARD
        ========================================== */

        .ap-page {
            min-height: 100vh;
            padding: 40px 0 70px;
            background:
                    radial-gradient(
                            circle at 85% 0%,
                            rgba(124, 58, 237, 0.13),
                            transparent 35%
                    ),
                    #0b1020;
            color: #f8fafc;
        }

        .ap-container {
            width: min(1320px, 94%);
            margin: 0 auto;
        }

        /* ==========================================
           HEADER
        ========================================== */

        .ap-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 24px;
            margin-bottom: 30px;
        }

        .ap-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 12px;
            padding: 7px 13px;
            border-radius: 30px;
            background: rgba(124, 58, 237, 0.13);
            border: 1px solid rgba(167, 139, 250, 0.2);
            color: #c4b5fd;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: 0.7px;
            text-transform: uppercase;
        }

        .ap-header h1 {
            margin: 0;
            font-size: clamp(28px, 4vw, 38px);
            font-weight: 800;
            letter-spacing: -1px;
            color: #ffffff;
        }

        .ap-header p {
            margin: 10px 0 0;
            color: #94a3b8;
            line-height: 1.6;
            font-size: 14px;
        }

        .ap-back-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 9px;
            padding: 12px 18px;
            border: 1px solid #334155;
            border-radius: 12px;
            background: #182236;
            color: #e2e8f0;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
            white-space: nowrap;
            transition: 0.2s ease;
        }

        .ap-back-btn:hover {
            border-color: #8b5cf6;
            background: #24304b;
            color: #ffffff;
        }

        /* ==========================================
           STATISTICS
        ========================================== */

        .ap-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;
            margin-bottom: 28px;
        }

        .ap-stat {
            position: relative;
            overflow: hidden;
            padding: 23px;
            border: 1px solid #273249;
            border-radius: 18px;
            background: #141e30;
            transition: transform 0.2s ease,
            border-color 0.2s ease;
        }

        .ap-stat:hover {
            transform: translateY(-3px);
            border-color: #6d55b3;
        }

        .ap-stat-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .ap-stat-icon {
            display: flex;
            align-items: center;
            justify-content: center;
            width: 46px;
            height: 46px;
            border-radius: 13px;
            font-size: 23px;
        }

        .ap-icon-purple {
            background: rgba(139, 92, 246, 0.16);
        }

        .ap-icon-green {
            background: rgba(16, 185, 129, 0.14);
        }

        .ap-icon-yellow {
            background: rgba(245, 158, 11, 0.14);
        }

        .ap-icon-blue {
            background: rgba(59, 130, 246, 0.14);
        }

        .ap-stat-label {
            color: #94a3b8;
            font-size: 13px;
            font-weight: 500;
        }

        .ap-stat-value {
            margin-top: 7px;
            font-size: 29px;
            font-weight: 800;
            letter-spacing: -0.7px;
            color: #ffffff;
            overflow-wrap: anywhere;
        }

        .ap-stat-value.ap-revenue {
            font-size: 24px;
            color: #86efac;
        }

        .ap-stat-note {
            margin-top: 9px;
            color: #64748b;
            font-size: 12px;
        }




        .ap-alert {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px 18px;
            margin-bottom: 25px;
            border-radius: 12px;
            font-size: 14px;
            line-height: 1.5;
        }

        .ap-alert-success {
            color: #bbf7d0;
            background: rgba(16, 185, 129, 0.1);
            border: 1px solid rgba(16, 185, 129, 0.3);
        }

        .ap-alert-error {
            color: #fecaca;
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.3);
        }



        .ap-panel {
            border: 1px solid #273249;
            border-radius: 20px;
            background: #141e30;
            overflow: hidden;
        }

        .ap-panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 16px;
            padding: 25px;
            border-bottom: 1px solid #273249;
        }

        .ap-panel-header h2 {
            margin: 0;
            color: #ffffff;
            font-size: 19px;
            font-weight: 750;
        }

        .ap-panel-header p {
            margin: 7px 0 0;
            color: #94a3b8;
            font-size: 13px;
        }

        .ap-record-count {
            padding: 8px 13px;
            border-radius: 9px;
            background: rgba(139, 92, 246, 0.13);
            color: #c4b5fd;
            font-size: 12px;
            font-weight: 700;
        }



        .ap-toolbar {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
            padding: 20px 25px;
            border-bottom: 1px solid #273249;
        }

        .ap-search {
            flex: 1;
            min-width: 220px;
        }

        .ap-input,
        .ap-select {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #334155;
            border-radius: 11px;
            outline: none;
            background: #0f172a;
            color: #f8fafc;
            font-size: 13px;
            font-family: inherit;
            transition: border-color 0.2s;
        }

        .ap-input:focus,
        .ap-select:focus {
            border-color: #8b5cf6;
        }

        .ap-input::placeholder {
            color: #64748b;
        }

        .ap-filter {
            width: 180px;
        }


        .ap-table-wrap {
            width: 100%;
            overflow-x: auto;
        }

        .ap-table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1060px;
        }

        .ap-table thead {
            background: #10192a;
        }

        .ap-table th {
            padding: 16px 18px;
            color: #94a3b8;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            text-align: left;
            white-space: nowrap;
        }

        .ap-table td {
            padding: 19px 18px;
            border-top: 1px solid #263146;
            color: #cbd5e1;
            font-size: 13px;
            vertical-align: middle;
        }

        .ap-table tbody tr:hover {
            background: rgba(139, 92, 246, 0.045);
        }

        .ap-payment-id {
            color: #c4b5fd;
            font-weight: 750;
            font-size: 13px;
        }

        .ap-primary-text {
            color: #f8fafc;
            font-weight: 650;
        }

        .ap-muted {
            display: block;
            margin-top: 5px;
            color: #64748b;
            font-size: 11px;
        }

        .ap-amount {
            color: #f8fafc;
            font-weight: 750;
            white-space: nowrap;
        }


        .ap-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 11px;
            border-radius: 30px;
            font-size: 11px;
            font-weight: 750;
            white-space: nowrap;
        }

        .ap-status-paid {
            color: #86efac;
            background: rgba(16, 185, 129, 0.13);
        }

        .ap-status-pending {
            color: #fcd34d;
            background: rgba(245, 158, 11, 0.13);
        }

        .ap-status-failed,
        .ap-status-rejected {
            color: #fca5a5;
            background: rgba(239, 68, 68, 0.13);
        }

        .ap-status-unknown {
            color: #cbd5e1;
            background: #334155;
        }

        /*
           PAYMENT ACTION BUTTONS
         */

        .ap-actions {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
        }

        .ap-action-form {
            margin: 0;
        }

        .ap-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 9px 12px;
            border-radius: 9px;
            border: 1px solid transparent;
            font-size: 11px;
            font-weight: 750;
            cursor: pointer;
            white-space: nowrap;
            font-family: inherit;
            transition: 0.2s ease;
        }

        .ap-btn-approve {
            color: #bbf7d0;
            background: rgba(16, 185, 129, 0.13);
            border-color: rgba(16, 185, 129, 0.25);
        }

        .ap-btn-approve:hover {
            background: rgba(16, 185, 129, 0.25);
        }

        .ap-btn-reject {
            color: #fca5a5;
            background: rgba(239, 68, 68, 0.12);
            border-color: rgba(239, 68, 68, 0.25);
        }

        .ap-btn-reject:hover {
            background: rgba(239, 68, 68, 0.23);
        }

        .ap-no-action {
            color: #64748b;
            font-size: 12px;
        }

        /*
           EMPTY STATE
         */

        .ap-empty {
            padding: 65px 20px;
            text-align: center;
        }

        .ap-empty-icon {
            margin-bottom: 15px;
            font-size: 42px;
        }

        .ap-empty h3 {
            margin: 0 0 10px;
            color: #f8fafc;
            font-size: 18px;
        }

        .ap-empty p {
            margin: 0;
            color: #94a3b8;
            font-size: 13px;
        }

        /*
           FOOTER
         */

        .ap-footer {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            flex-wrap: wrap;
            margin-top: 25px;
            color: #64748b;
            font-size: 12px;
        }

        /*
           RESPONSIVE
        */

        @media (max-width: 1050px) {

            .ap-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

        }

        @media (max-width: 650px) {

            .ap-page {
                padding-top: 25px;
            }

            .ap-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .ap-back-btn {
                width: 100%;
            }

            .ap-stats {
                grid-template-columns: 1fr;
            }

            .ap-panel-header,
            .ap-toolbar {
                padding: 18px;
            }

            .ap-search,
            .ap-filter {
                width: 100%;
                min-width: 0;
                flex: auto;
            }

        }

    </style>

</head>

<body>

<!--
     ADMIN NAVIGATION
 -->

<jsp:include page="/WEB-INF/views/partials/admin-nav.jsp" />

<!--
     MAIN PAGE
 -->

<main class="ap-page">

    <div class="ap-container">

        <!-- PAGE HEADER-->

        <div class="ap-header">

            <div>

                <div class="ap-eyebrow">
                    💳 Financial Management
                </div>

                <h1>Payment Management</h1>

                <p>
                    Manage customer payments, verify bank
                    transfers and monitor CineRent revenue.
                </p>

            </div>

            <a href="<%= ctx %>/admin"
               class="ap-back-btn">

                ← Back to Dashboard

            </a>

        </div>

        <!--
             FLASH MESSAGE
        -->

        <%
            if (paymentMessage != null
                    && !paymentMessage.isBlank()) {
        %>

        <div class="ap-alert <%= successMessage
                ? "ap-alert-success"
                : "ap-alert-error" %>"
             role="alert">

            <span>
                <%= successMessage ? "✓" : "!" %>
            </span>

            <span>
                <%= HtmlUtil.escape(paymentMessage) %>
            </span>

        </div>

        <%
            }
        %>

        <!--
             STATISTICS CARDS
        -->

        <section class="ap-stats"
                 aria-label="Payment statistics">

            <!-- TOTAL PAYMENTS -->

            <div class="ap-stat">

                <div class="ap-stat-top">

                    <div class="ap-stat-icon ap-icon-purple">
                        💳
                    </div>

                </div>

                <div class="ap-stat-label">
                    Total Payments
                </div>

                <div class="ap-stat-value">
                    <%= totalPayments %>
                </div>

                <div class="ap-stat-note">
                    All payment records
                </div>

            </div>

            <!-- PAID PAYMENTS -->

            <div class="ap-stat">

                <div class="ap-stat-top">

                    <div class="ap-stat-icon ap-icon-green">
                        ✓
                    </div>

                </div>

                <div class="ap-stat-label">
                    Successful Payments
                </div>

                <div class="ap-stat-value">
                    <%= paidPayments %>
                </div>

                <div class="ap-stat-note">
                    Confirmed payment records
                </div>

            </div>

            <!-- PENDING PAYMENTS -->

            <div class="ap-stat">

                <div class="ap-stat-top">

                    <div class="ap-stat-icon ap-icon-yellow">
                        ⏳
                    </div>

                </div>

                <div class="ap-stat-label">
                    Pending Payments
                </div>

                <div class="ap-stat-value">
                    <%= pendingPayments %>
                </div>

                <div class="ap-stat-note">
                    Awaiting payment processing
                </div>

            </div>

            <!-- TOTAL REVENUE -->

            <div class="ap-stat">

                <div class="ap-stat-top">

                    <div class="ap-stat-icon ap-icon-blue">
                        📈
                    </div>

                </div>

                <div class="ap-stat-label">
                    Recorded Paid Amount
                </div>

                <div class="ap-stat-value ap-revenue">
                    LKR <%= revenueDisplay %>
                </div>

                <div class="ap-stat-note">
                    Includes simulated demo payments
                </div>

            </div>

        </section>

        <!--
             PAYMENT TABLE PANEL
       -->

        <section class="ap-panel">

            <!-- PANEL HEADER -->

            <div class="ap-panel-header">

                <div>

                    <h2>Customer Transactions</h2>

                    <p>
                        Review payments and process
                        pending bank transfer requests.
                    </p>

                </div>

                <div class="ap-record-count">

                    <span id="apVisibleCount">
                        <%= totalPayments %>
                    </span>

                    Records

                </div>

            </div>

            <!-- SEARCH AND FILTER -->

            <div class="ap-toolbar">

                <div class="ap-search">

                    <input
                            type="search"
                            id="apSearchInput"
                            class="ap-input"
                            placeholder="Search payment, customer or movie ID..."
                            aria-label="Search payments"
                    >

                </div>

                <div class="ap-filter">

                    <select
                            id="apStatusFilter"
                            class="ap-select"
                            aria-label="Filter by payment status"
                    >

                        <option value="ALL">
                            All Statuses
                        </option>

                        <option value="PENDING">
                            Pending
                        </option>

                        <option value="PAID">
                            Paid
                        </option>

                        <option value="FAILED">
                            Failed
                        </option>

                        <option value="REJECTED">
                            Rejected
                        </option>

                    </select>

                </div>

            </div>

            <!--
                 TABLE
           -->

            <div class="ap-table-wrap">

                <table class="ap-table">

                    <thead>

                    <tr>

                        <th>Payment ID</th>
                        <th>Customer</th>
                        <th>Movie</th>
                        <th>Amount</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th>Rental</th>
                        <th>Date</th>
                        <th>Actions</th>

                    </tr>

                    </thead>

                    <tbody id="apPaymentTableBody">

                    <%
                        if (hasPayments) {

                            for (Payment payment : payments) {

                                String paymentId =
                                        payment.getPaymentId();

                                String userId =
                                        payment.getUserId();

                                String movieId =
                                        payment.getMovieId();

                                String rentalId =
                                        payment.getRentalId();

                                String status =
                                        payment.getPaymentStatus();

                                if (status == null) {
                                    status = "UNKNOWN";
                                }

                                String statusClass;

                                switch (status.toUpperCase(Locale.ROOT)) {

                                    case "PAID":
                                        statusClass = "ap-status-paid";
                                        break;

                                    case "PENDING":
                                        statusClass = "ap-status-pending";
                                        break;

                                    case "FAILED":
                                        statusClass = "ap-status-failed";
                                        break;

                                    case "REJECTED":
                                        statusClass = "ap-status-rejected";
                                        break;

                                    default:
                                        statusClass = "ap-status-unknown";
                                        break;
                                }

                                boolean canReview =
                                        payment.isBankTransfer()
                                                && payment.isPending();

                                boolean linkedRental =
                                        rentalId != null
                                                && !rentalId.isBlank();

                                String searchText =
                                        String.valueOf(paymentId) + " " +
                                                String.valueOf(userId) + " " +
                                                String.valueOf(movieId) + " " +
                                                String.valueOf(rentalId) + " " +
                                                payment.getPaymentMethodDisplay();
                    %>

                    <tr class="ap-payment-row"
                        data-status="<%= HtmlUtil.escape(status) %>"
                        data-search="<%= HtmlUtil.escape(searchText) %>">

                        <!-- PAYMENT ID -->

                        <td>

                            <span class="ap-payment-id">

                                <%= HtmlUtil.escape(
                                        paymentId
                                ) %>

                            </span>

                        </td>

                        <!-- CUSTOMER -->

                        <td>

                            <span class="ap-primary-text">

                                <%= HtmlUtil.escape(
                                        userId
                                ) %>

                            </span>

                            <span class="ap-muted">
                                Customer ID
                            </span>

                        </td>

                        <!-- MOVIE -->

                        <td>

                            <span class="ap-primary-text">

                                <%= HtmlUtil.escape(
                                        movieId
                                ) %>

                            </span>

                            <span class="ap-muted">
                                Movie ID
                            </span>

                        </td>

                        <!-- AMOUNT -->

                        <td>

                            <span class="ap-amount">

                                <%= HtmlUtil.escape(
                                        payment.getFormattedAmount()
                                ) %>

                            </span>

                        </td>

                        <!-- PAYMENT METHOD -->

                        <td>

                            <span class="ap-primary-text">

                                <%= HtmlUtil.escape(
                                        payment.getPaymentMethodDisplay()
                                ) %>

                            </span>

                        </td>

                        <!-- STATUS -->

                        <td>

                            <span class="ap-status <%= statusClass %>">

                                <%
                                    if (payment.isPaid()) {
                                %>

                                ✓

                                <%
                                } else if (payment.isPending()) {
                                %>

                                ◷

                                <%
                                } else {
                                %>

                                ×

                                <%
                                    }
                                %>

                                <%= HtmlUtil.escape(status) %>

                            </span>

                        </td>

                        <!-- RENTAL -->

                        <td>

                            <%
                                if (linkedRental) {
                            %>

                            <span class="ap-primary-text">

                                <%= HtmlUtil.escape(rentalId) %>

                            </span>

                            <%
                            } else {
                            %>

                            <span class="ap-no-action">
                                Not linked
                            </span>

                            <%
                                }
                            %>

                        </td>

                        <!-- PAYMENT DATE -->

                        <td>

                            <span class="ap-primary-text">

                                <%= HtmlUtil.escape(
                                        payment.getFormattedCreatedAt()
                                ) %>

                            </span>

                        </td>

                        <!-- ACTIONS -->

                        <td>

                            <%
                                if (canReview) {
                            %>

                            <div class="ap-actions">

                                <!-- APPROVE -->

                                <form
                                        method="post"
                                        action="<%= ctx %>/admin/payments"
                                        class="ap-action-form"
                                        onsubmit="return confirm('Have you verified this bank transfer in your bank records?');"
                                >

                                    <input
                                            type="hidden"
                                            name="csrfToken"
                                            value="<%= HtmlUtil.escape(csrfToken) %>"
                                    >

                                    <input
                                            type="hidden"
                                            name="paymentId"
                                            value="<%= HtmlUtil.escape(paymentId) %>"
                                    >

                                    <button
                                            type="submit"
                                            name="action"
                                            value="approve"
                                            class="ap-btn ap-btn-approve"
                                    >

                                        ✓ Approve

                                    </button>

                                </form>

                                <!-- REJECT -->

                                <form
                                        method="post"
                                        action="<%= ctx %>/admin/payments"
                                        class="ap-action-form"
                                        onsubmit="return confirm('Are you sure you want to reject this payment?');"
                                >

                                    <input
                                            type="hidden"
                                            name="csrfToken"
                                            value="<%= HtmlUtil.escape(csrfToken) %>"
                                    >

                                    <input
                                            type="hidden"
                                            name="paymentId"
                                            value="<%= HtmlUtil.escape(paymentId) %>"
                                    >

                                    <button
                                            type="submit"
                                            name="action"
                                            value="reject"
                                            class="ap-btn ap-btn-reject"
                                    >

                                        × Reject

                                    </button>

                                </form>

                            </div>

                            <%
                            } else {
                            %>

                            <span class="ap-no-action">
                                No actions
                            </span>

                            <%
                                }
                            %>

                        </td>

                    </tr>

                    <%
                        }
                    } else {
                    %>

                    <tr>

                        <td colspan="9">

                            <div class="ap-empty">

                                <div class="ap-empty-icon">
                                    💳
                                </div>

                                <h3>No payment records yet</h3>

                                <p>
                                    Customer payment transactions
                                    will appear here.
                                </p>

                            </div>

                        </td>

                    </tr>

                    <%
                        }
                    %>

                    </tbody>

                </table>

            </div>

            <!-- NO SEARCH RESULTS -->

            <div
                    id="apNoResults"
                    class="ap-empty"
                    style="display:none;"
            >

                <div class="ap-empty-icon">
                    🔎
                </div>

                <h3>No matching payments</h3>

                <p>
                    Try a different search or payment status.
                </p>

            </div>

        </section>

        <!-- ==================================
             FOOTER
        =================================== -->

        <div class="ap-footer">

            <span>
                © 2026 CineRent · Payment Management
            </span>

            <span>
                Signed in as
                <%= HtmlUtil.escape(adminName) %>
            </span>

        </div>

    </div>

</main>

<!-- ==========================================
     SEARCH AND FILTER SCRIPT
========================================== -->

<script>

    document.addEventListener("DOMContentLoaded", function () {

        const searchInput =
            document.getElementById("apSearchInput");

        const statusFilter =
            document.getElementById("apStatusFilter");

        const paymentRows =
            document.querySelectorAll(".ap-payment-row");

        const visibleCount =
            document.getElementById("apVisibleCount");

        const noResults =
            document.getElementById("apNoResults");

        function filterPayments() {

            const searchValue =
                searchInput.value
                    .trim()
                    .toLowerCase();

            const selectedStatus =
                statusFilter.value.toUpperCase();

            let visible = 0;

            paymentRows.forEach(function (row) {

                const rowSearch =
                    (row.dataset.search || "")
                        .toLowerCase();

                const rowStatus =
                    (row.dataset.status || "")
                        .toUpperCase();

                const matchesSearch =
                    rowSearch.includes(searchValue);

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
                paymentRows.length > 0 && visible === 0
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

    });

</script>

</body>
</html>
