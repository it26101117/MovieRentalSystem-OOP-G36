
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    // ==========================================
    // CHECKOUT DATA FROM SERVLET
    // ==========================================

    Movie movie =
            (Movie) request.getAttribute("movie");

    BigDecimal rentalPrice =
            (BigDecimal) request.getAttribute("rentalPrice");

    String formattedRentalPrice =
            (String) request.getAttribute("formattedRentalPrice");

    String userName =
            (String) request.getAttribute("userName");

    String csrfToken =
            (String) request.getAttribute("csrfToken");

    String demoCardMethod =
            (String) request.getAttribute("demoCardMethod");

    String bankTransferMethod =
            (String) request.getAttribute("bankTransferMethod");

    String ctx = request.getContextPath();

    // ==========================================
    // VALIDATE CHECKOUT DATA
    // ==========================================

    if (movie == null || rentalPrice == null) {

        response.sendRedirect(
                ctx + "/catalog?error=notfound"
        );

        return;
    }

    if (csrfToken == null || csrfToken.isBlank()) {

        response.sendError(
                500,
                "Checkout security token is missing."
        );

        return;
    }

    if (userName == null || userName.isBlank()) {
        userName = "Customer";
    }

    if (demoCardMethod == null) {
        demoCardMethod = "DEMO_CARD";
    }

    if (bankTransferMethod == null) {
        bankTransferMethod = "BANK_TRANSFER";
    }

    if (formattedRentalPrice == null) {

        formattedRentalPrice = String.format(
                Locale.US,
                "LKR %,.2f",
                rentalPrice
        );
    }

    String movieDescription =
            movie.getDescription() == null
                    ? ""
                    : movie.getDescription();

    String movieGenre =
            movie.getGenre() == null
                    ? ""
                    : movie.getGenre();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Secure Checkout | CineRent
    </title>

    <link rel="stylesheet"
          href="<%= ctx %>/css/style.css">

    <style>

        /* ==========================================
           PAGE
        ========================================== */

        body.checkout-body {
            margin: 0;
            background: #0b1020;
            color: #f8fafc;
        }

        .cr-checkout-page {
            min-height: 100vh;
            padding: 45px 0 80px;

            background:
                    radial-gradient(
                            circle at 85% 5%,
                            rgba(124, 58, 237, 0.14),
                            transparent 38%
                    ),
                    #0b1020;
        }

        .cr-container {
            width: min(1180px, 94%);
            margin: 0 auto;
        }

        /* ==========================================
           HEADER
        ========================================== */

        .cr-checkout-header {
            margin-bottom: 35px;
        }

        .cr-back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            margin-bottom: 25px;

            color: #a5b4fc;
            font-size: 13px;
            font-weight: 600;
            text-decoration: none;
        }

        .cr-back-link:hover {
            color: #ddd6fe;
        }

        .cr-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 8px;

            padding: 8px 14px;
            margin-bottom: 14px;

            border: 1px solid rgba(167,139,250,.24);
            border-radius: 30px;

            background: rgba(124,58,237,.13);
            color: #c4b5fd;

            font-size: 12px;
            font-weight: 700;
            letter-spacing: .5px;
        }

        .cr-checkout-header h1 {
            margin: 0;

            font-size: clamp(29px, 4vw, 42px);
            font-weight: 800;
            letter-spacing: -1px;

            color: #ffffff;
        }

        .cr-checkout-header p {
            margin: 12px 0 0;

            color: #94a3b8;
            font-size: 14px;
            line-height: 1.7;
        }

        /* ==========================================
           CHECKOUT LAYOUT
        ========================================== */

        .cr-checkout-grid {
            display: grid;

            grid-template-columns:
                minmax(0, 1.35fr)
                minmax(320px, 0.85fr);

            gap: 25px;
            align-items: start;
        }

        .cr-card {
            border: 1px solid #283449;
            border-radius: 20px;

            background: #141e30;
            overflow: hidden;
        }

        .cr-card-header {
            padding: 25px;
            border-bottom: 1px solid #283449;
        }

        .cr-card-header h2 {
            margin: 0;

            font-size: 19px;
            font-weight: 750;
            color: #ffffff;
        }

        .cr-card-header p {
            margin: 8px 0 0;

            color: #94a3b8;
            font-size: 13px;
            line-height: 1.6;
        }

        .cr-card-body {
            padding: 25px;
        }

        /* ==========================================
           MOVIE DETAILS
        ========================================== */

        .cr-movie {
            display: grid;
            grid-template-columns: 115px minmax(0, 1fr);
            gap: 20px;
            align-items: start;
        }

        .cr-movie-poster {
            width: 115px;
            aspect-ratio: 2 / 3;

            border-radius: 12px;
            object-fit: cover;

            background: #0f172a;
            border: 1px solid #334155;
        }

        .cr-movie-title {
            margin: 0 0 10px;

            color: #ffffff;
            font-size: 21px;
            font-weight: 750;
            line-height: 1.35;
        }

        .cr-movie-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;

            margin-bottom: 13px;
        }

        .cr-meta-pill {
            display: inline-flex;
            align-items: center;

            padding: 6px 10px;
            border-radius: 8px;

            background: #24304a;
            color: #cbd5e1;

            font-size: 11px;
            font-weight: 650;
        }

        .cr-movie-description {
            margin: 0;

            color: #94a3b8;
            font-size: 13px;
            line-height: 1.75;
        }

        .cr-movie-id {
            margin-top: 15px;

            color: #64748b;
            font-size: 12px;
        }

        /* ==========================================
           CUSTOMER INFO
        ========================================== */

        .cr-customer-info {
            display: flex;
            align-items: center;
            gap: 14px;

            margin-top: 25px;
            padding: 18px;

            border: 1px solid #334155;
            border-radius: 13px;

            background: #10192a;
        }

        .cr-avatar {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 43px;
            height: 43px;

            border-radius: 12px;

            background: rgba(139,92,246,.17);
            color: #c4b5fd;

            font-size: 21px;
        }

        .cr-info-label {
            color: #64748b;
            font-size: 11px;
        }

        .cr-info-value {
            margin-top: 4px;

            color: #f8fafc;
            font-size: 14px;
            font-weight: 650;
        }

        /* ==========================================
           PAYMENT METHOD
        ========================================== */

        .cr-payment-methods {
            display: grid;
            gap: 14px;
        }

        .cr-payment-option {
            position: relative;
            display: block;
            cursor: pointer;
        }

        .cr-payment-option input {
            position: absolute;
            opacity: 0;
            width: 1px;
            height: 1px;
        }

        .cr-payment-option-content {
            display: flex;
            align-items: flex-start;
            gap: 15px;

            padding: 20px;

            border: 1px solid #334155;
            border-radius: 14px;

            background: #10192a;
            transition: .2s ease;
        }

        .cr-payment-option:hover
        .cr-payment-option-content {
            border-color: #8b5cf6;
        }

        .cr-payment-option input:checked
        + .cr-payment-option-content {
            border-color: #8b5cf6;
            background: rgba(124,58,237,.11);

            box-shadow:
                    0 0 0 1px rgba(139,92,246,.22);
        }

        .cr-payment-option input:focus-visible
        + .cr-payment-option-content {
            outline: 2px solid #c4b5fd;
            outline-offset: 3px;
        }

        .cr-payment-icon {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 45px;
            height: 45px;

            flex-shrink: 0;

            border-radius: 12px;

            background: rgba(139,92,246,.15);
            font-size: 22px;
        }

        .cr-payment-text {
            flex: 1;
            min-width: 0;
        }

        .cr-payment-name {
            display: block;

            color: #ffffff;
            font-size: 15px;
            font-weight: 750;
        }

        .cr-payment-description {
            display: block;

            margin-top: 7px;

            color: #94a3b8;
            font-size: 12px;
            line-height: 1.65;
        }

        .cr-radio-indicator {
            width: 19px;
            height: 19px;

            flex-shrink: 0;

            border: 2px solid #64748b;
            border-radius: 50%;

            margin-top: 2px;
        }

        .cr-payment-option input:checked
        + .cr-payment-option-content
        .cr-radio-indicator {
            border: 5px solid #a78bfa;
            background: #ffffff;
        }

        /* ==========================================
           PAYMENT INFORMATION
        ========================================== */

        .cr-payment-notice {
            margin-top: 18px;
            padding: 17px 19px;

            border: 1px solid rgba(139,92,246,.25);
            border-radius: 12px;

            background: rgba(139,92,246,.08);

            color: #cbd5e1;
            font-size: 12px;
            line-height: 1.8;
        }

        .cr-payment-notice strong {
            display: block;
            margin-bottom: 5px;
            color: #ddd6fe;
            font-size: 13px;
        }

        .cr-payment-notice[hidden] {
            display: none;
        }

        /* ==========================================
           ORDER SUMMARY
        ========================================== */

        .cr-summary {
            position: sticky;
            top: 24px;
        }

        .cr-summary-row {
            display: flex;
            justify-content: space-between;
            gap: 15px;

            margin-bottom: 17px;

            color: #94a3b8;
            font-size: 13px;
        }

        .cr-summary-row span:last-child {
            color: #e2e8f0;
            font-weight: 650;
            text-align: right;
        }

        .cr-summary-divider {
            height: 1px;
            background: #334155;
            margin: 23px 0;
        }

        .cr-total-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .cr-total-label {
            color: #f8fafc;
            font-size: 15px;
            font-weight: 700;
        }

        .cr-total-amount {
            color: #c4b5fd;
            font-size: 24px;
            font-weight: 800;
            text-align: right;
        }

        /* ==========================================
           BUTTONS
        ========================================== */

        .cr-pay-button {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 9px;

            width: 100%;

            margin-top: 25px;
            padding: 16px 20px;

            border: none;
            border-radius: 12px;

            background:
                    linear-gradient(
                            135deg,
                            #7c3aed,
                            #5b21b6
                    );

            color: #ffffff;
            font-family: inherit;
            font-size: 14px;
            font-weight: 750;

            cursor: pointer;
            transition: .2s ease;
        }

        .cr-pay-button:hover:not(:disabled) {
            filter: brightness(1.13);
            transform: translateY(-1px);
        }

        .cr-pay-button:disabled {
            opacity: .65;
            cursor: wait;
        }

        .cr-cancel-link {
            display: block;

            margin-top: 16px;
            padding: 11px;

            color: #94a3b8;
            font-size: 13px;
            font-weight: 600;

            text-align: center;
            text-decoration: none;
        }

        .cr-cancel-link:hover {
            color: #ffffff;
        }

        /* ==========================================
           SECURITY INFORMATION
        ========================================== */

        .cr-security-note {
            display: flex;
            align-items: flex-start;
            gap: 10px;

            margin-top: 22px;

            color: #64748b;
            font-size: 12px;
            line-height: 1.7;
        }

        .cr-security-icon {
            font-size: 17px;
        }

        /* ==========================================
           FOOTER
        ========================================== */

        .cr-footer {
            margin-top: 45px;
            text-align: center;

            color: #64748b;
            font-size: 12px;
        }

        /* ==========================================
           RESPONSIVE
        ========================================== */

        @media (max-width: 900px) {

            .cr-checkout-grid {
                grid-template-columns: 1fr;
            }

            .cr-summary {
                position: static;
            }

        }

        @media (max-width: 600px) {

            .cr-checkout-page {
                padding-top: 25px;
            }

            .cr-card-header,
            .cr-card-body {
                padding: 19px;
            }

            .cr-movie {
                grid-template-columns: 90px minmax(0, 1fr);
                gap: 15px;
            }

            .cr-movie-poster {
                width: 90px;
            }

            .cr-movie-title {
                font-size: 17px;
            }

            .cr-payment-option-content {
                padding: 15px;
                gap: 11px;
            }

            .cr-total-amount {
                font-size: 19px;
            }

        }

    </style>

</head>

<body class="checkout-body">

<!-- ==========================================
     CUSTOMER NAVIGATION
========================================== -->

<jsp:include
        page="/WEB-INF/views/partials/customer-nav.jsp"
/>

<!-- ==========================================
     CHECKOUT PAGE
========================================== -->

<main class="cr-checkout-page">

    <div class="cr-container">

        <!-- ==================================
             HEADER
        =================================== -->

        <header class="cr-checkout-header">

            <a href="<%= ctx %>/catalog"
               class="cr-back-link">

                ← Back to Movie Catalogue

            </a>

            <div>

                <span class="cr-eyebrow">
                    🎬 CineRent Checkout
                </span>

            </div>

            <h1>
                Complete Your Rental
            </h1>

            <p>
                Review your movie and select your preferred
                payment method to continue.
            </p>

        </header>

        <!-- ==================================
             PAYMENT FORM
        =================================== -->

        <form
                id="checkoutForm"
                method="post"
                action="<%= ctx %>/payments"
        >

            <!-- MOVIE ID -->

            <input
                    type="hidden"
                    name="movieId"
                    value="<%= HtmlUtil.escape(movie.getMovieId()) %>"
            >

            <!-- CSRF SECURITY TOKEN -->

            <input
                    type="hidden"
                    name="csrfToken"
                    value="<%= HtmlUtil.escape(csrfToken) %>"
            >

            <div class="cr-checkout-grid">

                <!-- ==========================
                     LEFT SIDE
                =========================== -->

                <div>

                    <!-- MOVIE DETAILS -->

                    <section class="cr-card">

                        <div class="cr-card-header">

                            <h2>
                                🎥 Movie Information
                            </h2>

                            <p>
                                Confirm the movie you
                                would like to rent.
                            </p>

                        </div>

                        <div class="cr-card-body">

                            <div class="cr-movie">

                                <!-- POSTER -->

                                <img
                                        class="cr-movie-poster"
                                        src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(movie.getMovieId()) %>"
                                        alt="<%= HtmlUtil.escape(movie.getTitle()) %> poster"
                                >

                                <!-- DETAILS -->

                                <div>

                                    <h3 class="cr-movie-title">

                                        <%= HtmlUtil.escape(
                                                movie.getTitle()
                                        ) %>

                                    </h3>

                                    <div class="cr-movie-meta">

                                        <span class="cr-meta-pill">

                                            <%= HtmlUtil.escape(movieGenre) %>

                                        </span>

                                        <span class="cr-meta-pill">

                                            <%= movie.getReleaseYear() %>

                                        </span>

                                        <span class="cr-meta-pill">

                                            ⭐

                                            <%= String.format(
                                                    Locale.US,
                                                    "%.1f",
                                                    movie.getRating()
                                            ) %>

                                        </span>

                                    </div>

                                    <p class="cr-movie-description">

                                        <%= HtmlUtil.escape(
                                                movieDescription
                                        ) %>

                                    </p>

                                    <div class="cr-movie-id">

                                        Movie ID:

                                        <%= HtmlUtil.escape(
                                                movie.getMovieId()
                                        ) %>

                                    </div>

                                </div>

                            </div>

                            <!-- CUSTOMER -->

                            <div class="cr-customer-info">

                                <div class="cr-avatar">
                                    👤
                                </div>

                                <div>

                                    <div class="cr-info-label">
                                        Renting as
                                    </div>

                                    <div class="cr-info-value">

                                        <%= HtmlUtil.escape(
                                                userName
                                        ) %>

                                    </div>

                                </div>

                            </div>

                        </div>

                    </section>

                    <!-- ==========================
                         PAYMENT METHODS
                    =========================== -->

                    <section
                            class="cr-card"
                            style="margin-top:25px;"
                    >

                        <div class="cr-card-header">

                            <h2>
                                💳 Payment Method
                            </h2>

                            <p>
                                Choose how you want to
                                process this rental payment.
                            </p>

                        </div>

                        <div class="cr-card-body">

                            <div class="cr-payment-methods">

                                <!-- ======================
                                     DEMO CARD
                                ======================= -->

                                <label class="cr-payment-option">

                                    <input
                                            type="radio"
                                            name="paymentMethod"
                                            value="<%= HtmlUtil.escape(demoCardMethod) %>"
                                            id="demoCard"
                                            checked
                                            required
                                    >

                                    <span class="cr-payment-option-content">

                                        <span class="cr-payment-icon">
                                            💳
                                        </span>

                                        <span class="cr-payment-text">

                                            <span class="cr-payment-name">
                                                Demo Card Payment
                                            </span>

                                            <span class="cr-payment-description">

                                                Simulate a successful
                                                card payment for
                                                this academic project.

                                                No real money or
                                                card details are required.

                                            </span>

                                        </span>

                                        <span class="cr-radio-indicator"></span>

                                    </span>

                                </label>

                                <!-- ======================
                                     BANK TRANSFER
                                ======================= -->

                                <label class="cr-payment-option">

                                    <input
                                            type="radio"
                                            name="paymentMethod"
                                            value="<%= HtmlUtil.escape(bankTransferMethod) %>"
                                            id="bankTransfer"
                                            required
                                    >

                                    <span class="cr-payment-option-content">

                                        <span class="cr-payment-icon">
                                            🏦
                                        </span>

                                        <span class="cr-payment-text">

                                            <span class="cr-payment-name">
                                                Bank Transfer
                                            </span>

                                            <span class="cr-payment-description">

                                                Create a pending
                                                payment request.

                                                Your payment must be
                                                verified and approved
                                                by an administrator.

                                            </span>

                                        </span>

                                        <span class="cr-radio-indicator"></span>

                                    </span>

                                </label>

                            </div>

                            <!-- ======================
                                 DEMO INFORMATION
                            ======================= -->

                            <div
                                    class="cr-payment-notice"
                                    id="demoPaymentNotice"
                            >

                                <strong>
                                    Demo Payment Information
                                </strong>

                                This option is for testing the
                                CineRent payment workflow.

                                The system will record the payment
                                as PAID using a simulation.

                                It will not charge a real card.

                            </div>

                            <!-- ======================
                                 BANK INFORMATION
                            ======================= -->

                            <div
                                    class="cr-payment-notice"
                                    id="bankPaymentNotice"
                                    hidden
                            >

                                <strong>
                                    Bank Transfer Instructions
                                </strong>

                                After submitting, the system
                                will generate a payment ID
                                with PENDING status.

                                Obtain the correct bank account
                                details from the administrator.

                                Use the payment ID as your
                                transfer reference and provide
                                your receipt to the administrator
                                for verification.

                                The rental will not become active
                                until the payment is approved
                                and the rental is created.

                            </div>

                        </div>

                    </section>

                </div>

                <!-- ==========================
                     RIGHT SIDE
                =========================== -->

                <aside class="cr-summary">

                    <section class="cr-card">

                        <div class="cr-card-header">

                            <h2>
                                🧾 Order Summary
                            </h2>

                            <p>
                                Your rental payment details.
                            </p>

                        </div>

                        <div class="cr-card-body">

                            <!-- MOVIE -->

                            <div class="cr-summary-row">

                                <span>
                                    Movie
                                </span>

                                <span>

                                    <%= HtmlUtil.escape(
                                            movie.getTitle()
                                    ) %>

                                </span>

                            </div>

                            <!-- PRICE -->

                            <div class="cr-summary-row">

                                <span>
                                    Rental Price
                                </span>

                                <span>

                                    <%= HtmlUtil.escape(
                                            formattedRentalPrice
                                    ) %>

                                </span>

                            </div>

                            <!-- CURRENCY -->

                            <div class="cr-summary-row">

                                <span>
                                    Currency
                                </span>

                                <span>
                                    LKR
                                </span>

                            </div>

                            <!-- AVAILABLE COPIES -->

                            <div class="cr-summary-row">

                                <span>
                                    Availability
                                </span>

                                <span>

                                    <%= movie.getAvailableCopies() %>
                                    available

                                </span>

                            </div>

                            <div class="cr-summary-divider"></div>

                            <!-- TOTAL -->

                            <div class="cr-total-row">

                                <span class="cr-total-label">
                                    Total Amount
                                </span>

                                <span class="cr-total-amount">

                                    <%= HtmlUtil.escape(
                                            formattedRentalPrice
                                    ) %>

                                </span>

                            </div>

                            <!-- PAYMENT BUTTON -->

                            <button
                                    type="submit"
                                    id="checkoutSubmit"
                                    class="cr-pay-button"
                            >

                                <span id="checkoutButtonText">

                                    💳 Simulate Demo Payment

                                </span>

                            </button>

                            <!-- CANCEL -->

                            <a
                                    href="<%= ctx %>/catalog"
                                    class="cr-cancel-link"
                            >

                                Cancel and Return to Catalogue

                            </a>

                            <!-- SECURITY NOTE -->

                            <div class="cr-security-note">

                                <span class="cr-security-icon">
                                    🔒
                                </span>

                                <span>

                                    Your rental amount is
                                    verified by the server.

                                    Payment confirmation
                                    and rental activation
                                    are handled separately.

                                </span>

                            </div>

                        </div>

                    </section>

                </aside>

            </div>

        </form>

        <!-- ==================================
             FOOTER
        =================================== -->

        <footer class="cr-footer">

            © 2026 CineRent

            <span aria-hidden="true"> • </span>

            Movie Rental & Review Platform

        </footer>

    </div>

</main>

<!-- ==========================================
     PAYMENT METHOD INTERACTIONS
========================================== -->

<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {

            const form =
                document.getElementById(
                    "checkoutForm"
                );

            const demoCard =
                document.getElementById(
                    "demoCard"
                );

            const bankTransfer =
                document.getElementById(
                    "bankTransfer"
                );

            const demoNotice =
                document.getElementById(
                    "demoPaymentNotice"
                );

            const bankNotice =
                document.getElementById(
                    "bankPaymentNotice"
                );

            const submitButton =
                document.getElementById(
                    "checkoutSubmit"
                );

            const buttonText =
                document.getElementById(
                    "checkoutButtonText"
                );

            // ==================================
            // UPDATE PAYMENT METHOD DISPLAY
            // ==================================

            function updatePaymentMethod() {

                if (demoCard.checked) {

                    demoNotice.hidden = false;
                    bankNotice.hidden = true;

                    buttonText.textContent =
                        "💳 Simulate Demo Payment";

                } else if (bankTransfer.checked) {

                    demoNotice.hidden = true;
                    bankNotice.hidden = false;

                    buttonText.textContent =
                        "🏦 Create Bank Transfer Request";

                }
            }

            demoCard.addEventListener(
                "change",
                updatePaymentMethod
            );

            bankTransfer.addEventListener(
                "change",
                updatePaymentMethod
            );

            // ==================================
            // PREVENT ACCIDENTAL DOUBLE SUBMIT
            // ==================================

            let submitting = false;

            form.addEventListener(
                "submit",
                function (event) {

                    if (submitting) {

                        event.preventDefault();
                        return;
                    }

                    submitting = true;

                    submitButton.disabled = true;

                    buttonText.textContent =
                        "Processing your request...";

                }
            );

            updatePaymentMethod();

        }
    );

</script>

</body>
</html>
