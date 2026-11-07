
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.ArrayList,java.util.Comparator,java.util.List,java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="com.movierental.model.Payment" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%!
    private String safe(Object value) {
        return HtmlUtil.escape(value == null ? "" : String.valueOf(value));
    }

    private String badgeClass(Payment payment) {
        if (payment == null) return "other";
        if (payment.isPaid()) return "paid";
        if (payment.isPending()) return "pending";
        return "other";
    }

    private String badgeText(Payment payment) {
        if (payment == null) return "Unknown";
        if (payment.isPaid()) return "Paid";
        if (payment.isPending()) return "Pending";
        String status = payment.getPaymentStatus();
        return status == null || status.isBlank() ? "Unknown" : status;
    }
%>
<%
    // Data provided by PaymentServlet.doGet()
    String context = request.getContextPath();

    Object nameValue = request.getAttribute("userName");
    if (nameValue == null) {
        nameValue = session.getAttribute("userName");
    }

    String userName = nameValue == null || String.valueOf(nameValue).isBlank()
            ? "Customer" : String.valueOf(nameValue).trim();

    String initial = userName.substring(0, 1).toUpperCase(Locale.ROOT);

    Payment selectedPayment = (Payment) request.getAttribute("payment");
    Movie selectedMovie = (Movie) request.getAttribute("movie");

    Object messageValue = request.getAttribute("paymentMessage");
    String paymentMessage = messageValue == null
            ? "" : String.valueOf(messageValue);

    List<Payment> payments = new ArrayList<>();
    Object suppliedPayments = request.getAttribute("payments");

    if (suppliedPayments instanceof List<?>) {
        for (Object entry : (List<?>) suppliedPayments) {
            if (entry instanceof Payment) {
                payments.add((Payment) entry);
            }
        }
    }

    if (payments.isEmpty() && selectedPayment != null) {
        payments.add(selectedPayment);
    }

    payments.sort(Comparator.comparing(
            Payment::getCreatedAt,
            Comparator.nullsLast(Comparator.reverseOrder())
    ));

    int paidCount = 0;
    int pendingCount = 0;
    int otherCount = 0;

    BigDecimal paidTotal = BigDecimal.ZERO;

    for (Payment p : payments) {
        if (p.isPaid()) {
            paidCount++;
            if (p.getAmount() != null) {
                paidTotal = paidTotal.add(p.getAmount());
            }
        } else if (p.isPending()) {
            pendingCount++;
        } else {
            otherCount++;
        }
    }

    String paidTotalText = "LKR " +
            String.format(Locale.US, "%,.2f", paidTotal);

    if (selectedPayment != null && paymentMessage.isBlank()) {
        if (selectedPayment.isPending()) {
            paymentMessage =
                    "PAYHERE".equalsIgnoreCase(
                            selectedPayment.getPaymentMethod()
                    )
                            ? "Waiting for PayHere to confirm your payment. This page does not confirm payments itself."
                            : "Payment is pending administrator verification.";

        } else if (selectedPayment.isPaid()) {
            paymentMessage = selectedPayment.hasRental()
                    ? "Payment confirmed. Your movie rental is linked."
                    : "Payment confirmed. Open the payment details to activate your rental.";

        } else {
            paymentMessage =
                    "This transaction was not completed. Check its status or contact support.";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="theme-color" content="#080c18">

    <title>My Payments | CineRent</title>

    <link rel="stylesheet"
          href="<%= safe(context) %>/css/style.css">

    <style>
        .cr-payments,
        .cr-payments * {
            box-sizing: border-box;
        }

        body.cr-payments {
            margin: 0;
            min-height: 100vh;
            background: #080c18;
            color: #f6f5ff;
            font-family: Inter, "Segoe UI", Arial, sans-serif;
        }

        .cr-payments a {
            color: inherit;
            text-decoration: none;
        }

        .cr-payments a:focus-visible,
        .cr-payments button:focus-visible,
        .cr-payments input:focus-visible {
            outline: 2px solid #c4b5fd;
            outline-offset: 3px;
        }

        .cr-shell {
            max-width: 1240px;
            padding: 0 22px;
            margin: 0 auto;
        }

        .cr-header {
            background: #0b0e1a;
            border-bottom: 1px solid #263048;
        }

        .cr-header-inner {
            min-height: 75px;
            display: flex;
            align-items: center;
            gap: 28px;
        }

        .cr-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 20px;
            font-weight: 850;
            white-space: nowrap;
        }

        .cr-brand-mark {
            display: grid;
            place-items: center;
            width: 38px;
            height: 38px;
            border-radius: 12px;
            background: #7934eb;
            color: #fff;
        }

        .cr-nav {
            display: flex;
            gap: 22px;
            align-items: center;
            margin-right: auto;
        }

        .cr-nav a {
            color: #aab6cf;
            font-size: 13px;
            font-weight: 650;
            padding: 26px 0;
            border-bottom: 2px solid transparent;
            white-space: nowrap;
        }

        .cr-nav a:hover,
        .cr-nav a.active {
            color: #e6d7ff;
            border-bottom-color: #9c63ff;
        }

        .cr-account {
            display: flex;
            gap: 10px;
            align-items: center;
            color: #cfd7ea;
            font-size: 12px;
        }

        .cr-avatar {
            display: grid;
            place-items: center;
            width: 34px;
            height: 34px;
            border-radius: 50%;
            background: #4939c8;
            font-weight: 800;
        }

        .cr-logout {
            padding: 9px 12px;
            border: 1px solid #343e55;
            border-radius: 9px;
        }

        .cr-main {
            padding-top: 38px;
            padding-bottom: 65px;
        }

        .cr-breadcrumb {
            color: #91a1bb;
            font-size: 12px;
            margin-bottom: 17px;
        }

        .cr-breadcrumb a:hover {
            color: #c6b2ff;
        }

        .cr-hero {
            padding: 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 22px;
            border-radius: 20px;
            border: 1px solid #43325f;
            background:
                    radial-gradient(
                            circle at 90% 15%,
                            #41285d 0,
                            transparent 38%
                    ),
                    linear-gradient(120deg, #1d1939, #111a2b);
        }

        .cr-eyebrow {
            color: #c2adff;
            text-transform: uppercase;
            letter-spacing: 1.6px;
            font-size: 11px;
            font-weight: 800;
        }

        .cr-hero h1 {
            margin: 10px 0;
            font-size: clamp(28px, 4vw, 40px);
        }

        .cr-hero p {
            margin: 0;
            max-width: 580px;
            line-height: 1.65;
            color: #b5c2d7;
            font-size: 13px;
        }

        .cr-actions {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .cr-btn {
            display: inline-flex;
            justify-content: center;
            align-items: center;
            min-height: 42px;
            padding: 10px 16px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 800;
            white-space: nowrap;
        }

        .cr-btn.primary {
            background: #7b36ed;
            color: #fff;
        }

        .cr-btn.primary:hover {
            background: #8d56f5;
        }

        .cr-btn.secondary {
            border: 1px solid #4d4a67;
            background: #ffffff0b;
        }

        .cr-btn.secondary:hover {
            background: #ffffff1c;
        }

        .cr-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
            margin: 22px 0;
        }

        .cr-card {
            border: 1px solid #28334a;
            border-radius: 16px;
            background: #121b2c;
        }

        .cr-stat {
            padding: 22px;
        }

        .cr-stat-label {
            color: #9eacc3;
            font-size: 12px;
        }

        .cr-stat-value {
            display: block;
            margin-top: 12px;
            font-size: clamp(22px, 2.4vw, 28px);
            font-weight: 850;
            overflow-wrap: anywhere;
        }

        .cr-stat-foot {
            display: block;
            color: #8293ae;
            font-size: 11px;
            margin-top: 5px;
        }

        .cr-selected {
            padding: 23px;
            margin-bottom: 22px;
            border-color: #58417b;
        }

        .cr-section-title {
            margin: 0;
            font-size: 19px;
        }

        .cr-subtitle {
            color: #93a3bd;
            font-size: 12px;
            margin: 6px 0 0;
        }

        .cr-section-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .cr-notice {
            padding: 14px 16px;
            border-radius: 10px;
            border: 1px solid #514171;
            background: #2c2543;
            color: #e7d9ff;
            font-size: 13px;
            line-height: 1.6;
            margin-top: 18px;
        }

        .cr-details {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 22px;
            margin-top: 22px;
        }

        .cr-detail-label {
            color: #91a0b9;
            font-size: 11px;
            margin-bottom: 7px;
        }

        .cr-detail-value {
            color: #f2f5ff;
            font-size: 13px;
            font-weight: 750;
            overflow-wrap: anywhere;
        }

        .cr-status {
            display: inline-flex;
            align-items: center;
            padding: 6px 10px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 800;
            text-transform: capitalize;
        }

        .cr-status.paid {
            background: #143b30;
            color: #7ce0b3;
            border: 1px solid #24614b;
        }

        .cr-status.pending {
            background: #44371a;
            color: #f4ce7a;
            border: 1px solid #71551e;
        }

        .cr-status.other {
            background: #482530;
            color: #f5a4b1;
            border: 1px solid #70384a;
        }

        .cr-grid {
            display: grid;
            grid-template-columns: minmax(0, 1fr) 280px;
            align-items: start;
            gap: 18px;
        }

        .cr-panel-head {
            padding: 22px;
            border-bottom: 1px solid #28334a;
        }

        .cr-toolbar {
            padding: 14px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 12px;
        }

        .cr-filters {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }

        .cr-filter {
            cursor: pointer;
            border: 1px solid transparent;
            background: transparent;
            color: #9aabc3;
            border-radius: 8px;
            padding: 8px 10px;
            font-size: 12px;
        }

        .cr-filter.active {
            color: #e3d6ff;
            background: #312649;
            border-color: #554071;
        }

        .cr-search {
            width: 200px;
            max-width: 100%;
            padding: 9px 12px;
            border-radius: 9px;
            background: #0a1322;
            border: 1px solid #354159;
            color: #fff;
            font-size: 12px;
        }

        .cr-table-wrap {
            overflow-x: auto;
        }

        .cr-table {
            width: 100%;
            min-width: 610px;
            border-collapse: collapse;
        }

        .cr-table th {
            padding: 13px 17px;
            color: #91a0ba;
            font-size: 11px;
            text-align: left;
            background: #162137;
        }

        .cr-table td {
            padding: 17px;
            border-top: 1px solid #2a354b;
            color: #d5deef;
            font-size: 12px;
        }

        .cr-table tr:hover {
            background: #1b283d;
        }

        .cr-table small {
            display: block;
            color: #8294b1;
            margin-top: 6px;
        }

        .cr-table a.view {
            color: #bca3ff;
            font-weight: 800;
        }

        .cr-empty {
            text-align: center;
            padding: 48px 24px;
        }

        .cr-empty .icon {
            font-size: 42px;
        }

        .cr-empty h3 {
            margin: 12px 0;
        }

        .cr-empty p {
            color: #9dacbf;
            font-size: 13px;
            line-height: 1.7;
        }

        .cr-no-match {
            padding: 18px;
            color: #aab6c9;
            text-align: center;
            font-size: 13px;
        }

        .cr-aside {
            padding: 23px;
        }

        .cr-aside h3 {
            margin: 0 0 17px;
            font-size: 16px;
        }

        .cr-step {
            display: flex;
            gap: 12px;
            margin: 16px 0;
        }

        .cr-step-num {
            display: grid;
            place-items: center;
            width: 26px;
            height: 26px;
            flex: 0 0 26px;
            border-radius: 50%;
            background: #34264e;
            color: #d7c3ff;
            font-size: 12px;
            font-weight: 800;
        }

        .cr-step strong {
            font-size: 12px;
        }

        .cr-step p {
            margin: 5px 0 0;
            color: #91a1ba;
            line-height: 1.55;
            font-size: 11px;
        }

        .cr-footer {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            color: #8091ab;
            font-size: 12px;
            margin-top: 35px;
        }

        .cr-footer a {
            color: #c0aaff;
        }

        [hidden] {
            display: none !important;
        }

        @media (max-width: 950px) {
            .cr-grid {
                grid-template-columns: 1fr;
            }

            .cr-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .cr-nav {
                gap: 12px;
            }
        }

        @media (max-width: 680px) {
            .cr-header-inner {
                flex-wrap: wrap;
                padding-top: 12px;
                padding-bottom: 12px;
                gap: 12px;
            }

            .cr-nav {
                order: 3;
                width: 100%;
                gap: 16px;
                overflow-x: auto;
            }

            .cr-nav a {
                padding: 9px 0;
            }

            .cr-account {
                margin-left: auto;
            }

            .cr-account-name {
                display: none;
            }

            .cr-hero {
                padding: 24px;
                flex-direction: column;
                align-items: flex-start;
            }

            .cr-details {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .cr-stats {
                gap: 9px;
            }

            .cr-stat {
                padding: 15px;
            }

            .cr-shell {
                padding: 0 14px;
            }

            .cr-footer {
                flex-direction: column;
            }
        }
    </style>
</head>

<body class="cr-payments">

<header class="cr-header">
    <div class="cr-shell cr-header-inner">

        <a class="cr-brand" href="<%= safe(context) %>/">
            <span class="cr-brand-mark">C</span>
            CineRent
        </a>

        <nav class="cr-nav" aria-label="Main navigation">
            <a href="<%= safe(context) %>/">Home</a>
            <a href="<%= safe(context) %>/catalog">Movies</a>
            <a href="<%= safe(context) %>/rentals">My Rentals</a>
            <a class="active"
               aria-current="page"
               href="<%= safe(context) %>/payments">
                My Payments
            </a>
            <a href="<%= safe(context) %>/recently-watched">
                Recently Watched
            </a>
        </nav>

        <div class="cr-account">
            <span class="cr-avatar"><%= safe(initial) %></span>
            <span class="cr-account-name">
                Hi, <%= safe(userName) %>
            </span>
            <a class="cr-logout"
               href="<%= safe(context) %>/logout">
                Logout
            </a>
        </div>
    </div>
</header>

<main class="cr-shell cr-main">

    <div class="cr-breadcrumb">
        <a href="<%= safe(context) %>/">Home</a>
        &rsaquo; My Payments
    </div>

    <section class="cr-hero">
        <div>
            <div class="cr-eyebrow">CineRent / Billing</div>
            <h1>My Payments</h1>
            <p>
                Welcome, <strong><%= safe(userName) %></strong>.
                Review payments, track PayHere confirmations
                and bank transfer approvals, and manage your
                movie rentals.
            </p>
        </div>

        <div class="cr-actions">
            <a class="cr-btn primary"
               href="<%= safe(context) %>/catalog">
                Browse Movies
            </a>
            <a class="cr-btn secondary"
               href="<%= safe(context) %>/rentals">
                My Rentals
            </a>
        </div>
    </section>

    <section class="cr-stats" aria-label="Payment overview">

        <div class="cr-card cr-stat">
            <span class="cr-stat-label">Total Transactions</span>
            <strong class="cr-stat-value">
                <%= payments.size() %>
            </strong>
            <span class="cr-stat-foot">All payment records</span>
        </div>

        <div class="cr-card cr-stat">
            <span class="cr-stat-label">Paid</span>
            <strong class="cr-stat-value">
                <%= paidCount %>
            </strong>
            <span class="cr-stat-foot">Successfully confirmed</span>
        </div>

        <div class="cr-card cr-stat">
            <span class="cr-stat-label">Pending</span>
            <strong class="cr-stat-value">
                <%= pendingCount %>
            </strong>
            <span class="cr-stat-foot">Awaiting confirmation</span>
        </div>

        <div class="cr-card cr-stat">
            <span class="cr-stat-label">Total Paid</span>
            <strong class="cr-stat-value">
                <%= safe(paidTotalText) %>
            </strong>
            <span class="cr-stat-foot">Confirmed payment total</span>
        </div>
    </section>

    <% if (selectedPayment != null) {
        String selectedId = URLEncoder.encode(
                selectedPayment.getPaymentId() == null
                        ? "" : selectedPayment.getPaymentId(),
                StandardCharsets.UTF_8
        );
    %>

    <section class="cr-card cr-selected"
             aria-label="Selected payment">

        <div class="cr-section-head">
            <div>
                <h2 class="cr-section-title">Payment Details</h2>
                <p class="cr-subtitle">
                    Transaction
                    <%= safe(selectedPayment.getPaymentId()) %>
                </p>
            </div>

            <span class="cr-status <%= badgeClass(selectedPayment) %>">
                <%= safe(badgeText(selectedPayment)) %>
            </span>
        </div>

        <% if (!paymentMessage.isBlank()) { %>
        <div class="cr-notice">
            <%= safe(paymentMessage) %>
        </div>
        <% } %>

        <div class="cr-details">

            <div>
                <div class="cr-detail-label">Payment ID</div>
                <div class="cr-detail-value">
                    <%= safe(selectedPayment.getPaymentId()) %>
                </div>
            </div>

            <div>
                <div class="cr-detail-label">Movie</div>
                <div class="cr-detail-value">
                    <%= selectedMovie == null
                            ? safe(selectedPayment.getMovieId())
                            : safe(selectedMovie.getTitle()) %>
                </div>
            </div>

            <div>
                <div class="cr-detail-label">Amount</div>
                <div class="cr-detail-value">
                    <%= safe(selectedPayment.getFormattedAmount()) %>
                </div>
            </div>

            <div>
                <div class="cr-detail-label">Payment Method</div>
                <div class="cr-detail-value">
                    <%= safe(selectedPayment.getPaymentMethodDisplay()) %>
                </div>
            </div>

            <div>
                <div class="cr-detail-label">Created At</div>
                <div class="cr-detail-value">
                    <%= safe(selectedPayment.getFormattedCreatedAt()) %>
                </div>
            </div>

            <div>
                <div class="cr-detail-label">Rental Access</div>
                <div class="cr-detail-value">
                    <%= selectedPayment.hasRental()
                            ? "Rental linked"
                            : "Not activated" %>
                </div>
            </div>
        </div>

        <div class="cr-actions" style="margin-top:22px">

            <% if (selectedPayment.isPending()) { %>

            <a class="cr-btn secondary"
               href="<%= safe(context) %>/payments?paymentId=<%= safe(selectedId) %>">
                Refresh Status
            </a>

            <% } else if (selectedPayment.isPaid()
                    && !selectedPayment.hasRental()) { %>

            <a class="cr-btn primary"
               href="<%= safe(context) %>/payments?paymentId=<%= safe(selectedId) %>">
                Continue to Rental Activation
            </a>

            <% } else if (selectedPayment.isPaid()) { %>

            <a class="cr-btn primary"
               href="<%= safe(context) %>/rentals">
                View My Rentals
            </a>

            <% } else { %>

            <a class="cr-btn secondary"
               href="<%= safe(context) %>/catalog">
                Choose Another Movie
            </a>

            <% } %>
        </div>
    </section>

    <% } %>

    <div class="cr-grid">

        <section class="cr-card" aria-labelledby="history-title">

            <div class="cr-panel-head cr-section-head">
                <div>
                    <h2 id="history-title" class="cr-section-title">
                        Payment History
                    </h2>
                    <p class="cr-subtitle">
                        Your CineRent movie rental transactions
                    </p>
                </div>

                <span class="cr-subtitle">
                    <%= payments.size() %> records
                </span>
            </div>

            <% if (payments.isEmpty()) { %>

            <div class="cr-empty">
                <div class="icon">🎬</div>
                <h3>No payments yet</h3>
                <p>
                    Choose a movie, select a payment method,
                    and start your rental journey.
                </p>

                <a class="cr-btn primary"
                   href="<%= safe(context) %>/catalog">
                    Browse Movies
                </a>
            </div>

            <% } else { %>

            <div class="cr-toolbar">

                <div class="cr-filters"
                     role="group"
                     aria-label="Filter payments">

                    <button type="button"
                            class="cr-filter active"
                            data-filter="all"
                            aria-pressed="true">
                        All
                    </button>

                    <button type="button"
                            class="cr-filter"
                            data-filter="paid"
                            aria-pressed="false">
                        Paid
                    </button>

                    <button type="button"
                            class="cr-filter"
                            data-filter="pending"
                            aria-pressed="false">
                        Pending
                    </button>

                    <% if (otherCount > 0) { %>

                    <button type="button"
                            class="cr-filter"
                            data-filter="other"
                            aria-pressed="false">
                        Other
                    </button>

                    <% } %>
                </div>

                <input type="search"
                       class="cr-search"
                       id="payment-search"
                       placeholder="Search payments..."
                       aria-label="Search payments">
            </div>

            <div class="cr-table-wrap">

                <table class="cr-table">

                    <thead>
                    <tr>
                        <th>Transaction</th>
                        <th>Amount</th>
                        <th>Method</th>
                        <th>Status</th>
                        <th>Details</th>
                    </tr>
                    </thead>

                    <tbody id="payment-rows">

                    <% for (Payment payment : payments) {

                        String paymentId =
                                payment.getPaymentId() == null
                                        ? ""
                                        : payment.getPaymentId();

                        String encodedId = URLEncoder.encode(
                                paymentId,
                                StandardCharsets.UTF_8
                        );
                    %>

                    <tr data-status="<%= badgeClass(payment) %>">

                        <td>
                            <strong>
                                <%= safe(paymentId) %>
                            </strong>
                            <small>
                                Movie
                                <%= safe(payment.getMovieId()) %>
                                ·
                                <%= safe(payment.getFormattedCreatedAt()) %>
                            </small>
                        </td>

                        <td>
                            <%= safe(payment.getFormattedAmount()) %>
                        </td>

                        <td>
                            <%= safe(payment.getPaymentMethodDisplay()) %>
                        </td>

                        <td>
                                <span class="cr-status <%= badgeClass(payment) %>">
                                    <%= safe(badgeText(payment)) %>
                                </span>
                        </td>

                        <td>
                            <a class="view"
                               href="<%= safe(context) %>/payments?paymentId=<%= safe(encodedId) %>">
                                View
                            </a>
                        </td>

                    </tr>

                    <% } %>

                    </tbody>
                </table>

                <div id="no-payment-match"
                     class="cr-no-match"
                     hidden>
                    No transactions match your filter.
                </div>

            </div>

            <% } %>

        </section>

        <aside class="cr-card cr-aside"
               aria-label="Payment guidance">

            <h3>How to Rent &amp; Pay</h3>

            <div class="cr-step">
                <span class="cr-step-num">1</span>
                <div>
                    <strong>Choose a movie</strong>
                    <p>
                        Click Rent &amp; Pay from the movie catalog.
                    </p>
                </div>
            </div>

            <div class="cr-step">
                <span class="cr-step-num">2</span>
                <div>
                    <strong>Select payment method</strong>
                    <p>
                        PayHere opens secure hosted checkout.
                        Bank transfers wait for admin approval.
                        Demo Card is for testing only.
                    </p>
                </div>
            </div>

            <div class="cr-step">
                <span class="cr-step-num">3</span>
                <div>
                    <strong>Confirm &amp; activate</strong>
                    <p>
                        Only a verified paid transaction can
                        activate a rental.
                    </p>
                </div>
            </div>

            <div class="cr-notice">
                PayHere confirmation is processed by the server
                callback, not by returning to this page.
            </div>

        </aside>
    </div>

    <footer class="cr-footer">
        <span>
            &copy; <%= java.time.Year.now().getValue() %> CineRent
        </span>
        <span>
            <a href="<%= safe(context) %>/catalog">
                Browse Movies
            </a>
            &middot;
            <a href="<%= safe(context) %>/rentals">
                My Rentals
            </a>
        </span>
    </footer>

</main>

<script>
    (function () {
        const rows = Array.from(
            document.querySelectorAll('#payment-rows tr')
        );

        const buttons = Array.from(
            document.querySelectorAll('.cr-filter')
        );

        const search = document.getElementById('payment-search');
        const noMatch = document.getElementById('no-payment-match');

        if (!rows.length || !buttons.length || !search) {
            return;
        }

        let active = 'all';

        function applyFilters() {
            const term = search.value.trim().toLowerCase();
            let visible = 0;

            rows.forEach(function (row) {
                const show =
                    (active === 'all' || row.dataset.status === active) &&
                    row.textContent.toLowerCase().includes(term);

                row.hidden = !show;

                if (show) {
                    visible++;
                }
            });

            if (noMatch) {
                noMatch.hidden = visible !== 0;
            }
        }

        buttons.forEach(function (button) {
            button.addEventListener('click', function () {
                active = button.dataset.filter;

                buttons.forEach(function (other) {
                    const selected = other === button;

                    other.classList.toggle('active', selected);
                    other.setAttribute(
                        'aria-pressed',
                        String(selected)
                    );
                });

                applyFilters();
            });
        });

        search.addEventListener('input', applyFilters);
    })();
</script>

</body>
</html>
