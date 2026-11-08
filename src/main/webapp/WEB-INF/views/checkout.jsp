<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Locale" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>
<%
    // CheckoutServlet provides these request attributes.
    Movie movie = (Movie) request.getAttribute("movie");
    BigDecimal rentalPrice = (BigDecimal) request.getAttribute("rentalPrice");
    String csrfToken = (String) request.getAttribute("csrfToken");
    String formattedPrice = (String) request.getAttribute("formattedRentalPrice");
    String userName = (String) request.getAttribute("userName");
    String payHereMethod = (String) request.getAttribute("payHereMethod");
    String bankTransferMethod = (String) request.getAttribute("bankTransferMethod");
    String demoCardMethod = (String) request.getAttribute("demoCardMethod");
    boolean demoEnabled = Boolean.TRUE.equals(request.getAttribute("demoEnabled"));
    String ctx = request.getContextPath();

    if (movie == null || rentalPrice == null) {
        response.sendRedirect(ctx + "/catalog?error=notfound");
        return;
    }
    if (csrfToken == null || csrfToken.isBlank()) {
        response.sendError(500, "Checkout security token is missing. Reload checkout.");
        return;
    }
    if (formattedPrice == null || formattedPrice.isBlank()) {
        formattedPrice = String.format(Locale.US, "LKR %,.2f", rentalPrice);
    }
    if (userName == null || userName.isBlank()) userName = "Customer";
    if (payHereMethod == null) payHereMethod = "PAYHERE";
    if (bankTransferMethod == null) bankTransferMethod = "BANK_TRANSFER";
    if (demoCardMethod == null) demoCardMethod = "DEMO_CARD";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="color-scheme" content="dark">
    <title>Secure Checkout | CineRent</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        :root { color-scheme: dark; }
        * { box-sizing: border-box; }
        body.cr-checkout-body {
            margin: 0; color: #f3f4f6; background: #080d1a;
            font-family: Inter, system-ui, -apple-system, Segoe UI, Arial, sans-serif;
        }
        .cr-topbar { background: #111827; border-bottom: 1px solid #293347; }
        .cr-nav { width: min(1180px, 92%); margin: auto; min-height: 70px;
            display: flex; align-items: center; gap: 24px; flex-wrap: wrap; }
        .cr-brand { font-size: 23px; font-weight: 850; color: white;
            text-decoration: none; letter-spacing: -.6px; margin-right: auto; }
        .cr-navlinks { display: flex; flex-wrap: wrap; gap: 20px; }
        .cr-navlinks a { color: #cbd5e1; text-decoration: none; font-size: 14px; }
        .cr-navlinks a:hover, .cr-navlinks a[aria-current="page"] { color: #c4b5fd; }
        .cr-wrap { width: min(1180px, 92%); margin: 0 auto; padding: 40px 0 72px; }
        .cr-back { display: inline-block; margin-bottom: 20px; color: #c4b5fd;
            text-decoration: none; font-size: 14px; }
        .cr-intro { margin-bottom: 30px; }
        .cr-eyebrow { color: #c4b5fd; font-size: 12px; font-weight: 800;
            text-transform: uppercase; letter-spacing: 1.6px; }
        .cr-intro h1 { font-size: clamp(29px, 4vw, 44px); margin: 10px 0 8px; letter-spacing: -1px; }
        .cr-muted { color: #9caac1; line-height: 1.6; }
        .cr-grid { display: grid; grid-template-columns: minmax(0, 1.45fr) minmax(300px, 1fr);
            gap: 24px; align-items: start; }
        .cr-stack { display: grid; gap: 24px; }
        .cr-card { background: #121a2b; border: 1px solid #2a3448; border-radius: 18px;
            box-shadow: 0 12px 35px rgba(0, 0, 0, .14); overflow: hidden; }
        .cr-card-head { padding: 22px 24px 16px; border-bottom: 1px solid #263146; }
        .cr-card-head h2 { margin: 0 0 6px; font-size: 19px; }
        .cr-card-head p { margin: 0; font-size: 13px; color: #9caac1; }
        .cr-card-body { padding: 24px; }
        .cr-movie { display: flex; gap: 20px; }
        .cr-poster { width: 128px; height: 180px; object-fit: cover; border-radius: 12px;
            background: #222e43; flex: none; }
        .cr-movie h3 { margin: 0 0 10px; font-size: 23px; }
        .cr-tags { display: flex; gap: 7px; flex-wrap: wrap; margin-bottom: 13px; }
        .cr-tag { font-size: 12px; padding: 5px 9px; background: #263047;
            border: 1px solid #34415c; border-radius: 7px; color: #dce4f3; }
        .cr-description { margin: 0; color: #b0bdd0; line-height: 1.65; font-size: 14px; }
        .cr-account { margin-top: 22px; padding-top: 18px; border-top: 1px solid #293447;
            color: #b6c1d1; font-size: 14px; }
        .cr-account strong { color: #fff; }
        .cr-methods { display: grid; gap: 12px; }
        .cr-option { display: block; cursor: pointer; position: relative; }
        .cr-option input[type="radio"] { position: absolute; opacity: 0; width: 1px; height: 1px; }
        .cr-option-body { display: flex; gap: 14px; align-items: flex-start; padding: 17px;
            border: 1px solid #39465e; border-radius: 12px; background: #151f32;
            transition: border-color .15s, background .15s; }
        .cr-option input:checked + .cr-option-body { border-color: #a78bfa; background: #251e43; }
        .cr-option input:focus-visible + .cr-option-body { outline: 3px solid #a78bfa; outline-offset: 3px; }
        .cr-option-icon { font-size: 24px; line-height: 1.1; }
        .cr-option-text { flex: 1; }
        .cr-option-text strong { display: block; margin-bottom: 5px; font-size: 15px; }
        .cr-option-text small { display: block; color: #aab7ca; font-size: 12px; line-height: 1.6; }
        .cr-radio-dot { width: 18px; height: 18px; border-radius: 50%; border: 2px solid #8190a9;
            margin-top: 3px; flex: none; }
        .cr-option input:checked + .cr-option-body .cr-radio-dot { border: 5px solid #b49aff; background: #fff; }
        .cr-notice { margin-top: 18px; padding: 16px; background: #1b2840;
            border: 1px solid #364967; border-radius: 12px; color: #b9c9df;
            line-height: 1.6; font-size: 13px; }
        .cr-notice strong { display: block; color: #fff; margin-bottom: 5px; }
        .cr-notice[hidden], .cr-billing[hidden] { display: none !important; }
        .cr-billing { margin-top: 20px; padding-top: 20px; border-top: 1px solid #2b3850; }
        .cr-billing h3 { margin: 0 0 6px; font-size: 17px; }
        .cr-billing-grid { display: grid; gap: 13px; margin-top: 17px; }
        .cr-field { display: grid; gap: 7px; color: #dbe4f2; font-size: 13px; }
        .cr-field input { width: 100%; padding: 12px 13px; color: white; background: #0b1425;
            border: 1px solid #47556d; border-radius: 9px; font: inherit; }
        .cr-field input:focus { outline: 2px solid #a78bfa; border-color: #a78bfa; }
        .cr-summary-row { display: flex; justify-content: space-between; gap: 18px;
            padding: 12px 0; font-size: 14px; border-bottom: 1px solid #293447; }
        .cr-summary-row span:first-child { color: #aab8cb; }
        .cr-summary-row span:last-child { text-align: right; overflow-wrap: anywhere; }
        .cr-total { display: flex; justify-content: space-between; align-items: center;
            gap: 12px; padding: 22px 0; font-size: 17px; font-weight: 750; }
        .cr-total strong { color: #c4b5fd; font-size: 24px; white-space: nowrap; }
        .cr-submit { width: 100%; border: 0; border-radius: 11px; background: #7c3aed;
            color: #fff; padding: 16px; font: inherit; font-weight: 800; cursor: pointer; }
        .cr-submit:hover { background: #6d28d9; }
        .cr-submit:disabled { opacity: .65; cursor: wait; }
        .cr-cancel { display: block; margin-top: 16px; text-align: center;
            color: #b9c7db; font-size: 13px; text-decoration: none; }
        .cr-security { margin-top: 19px; font-size: 12px; line-height: 1.6; color: #91a1b9; }
        .cr-footer { text-align: center; margin-top: 46px; color: #7e8da5; font-size: 12px; }
        @media (max-width: 850px) { .cr-grid { grid-template-columns: 1fr; } }
        @media (max-width: 520px) {
            .cr-nav { padding: 14px 0; gap: 14px; }
            .cr-navlinks { width: 100%; justify-content: space-between; gap: 9px; }
            .cr-wrap { padding-top: 28px; }
            .cr-card-head, .cr-card-body { padding: 18px; }
            .cr-poster { width: 92px; height: 138px; }
            .cr-movie { gap: 12px; }
            .cr-movie h3 { font-size: 18px; }
            .cr-description { font-size: 12px; }
            .cr-total strong { font-size: 20px; }
        }
    </style>
</head>
<body class="cr-checkout-body">

<!-- Navigation is inline: no missing partials/customer-nav.jsp dependency. -->
<header class="cr-topbar">
    <nav class="cr-nav" aria-label="Customer navigation">
        <a class="cr-brand" href="<%= ctx %>/">🎬 CineRent</a>
        <div class="cr-navlinks">
            <a href="<%= ctx %>/catalog">Movies</a>
            <a href="<%= ctx %>/rentals">My Rentals</a>
            <a href="<%= ctx %>/payments">My Payments</a>
            <a href="<%= ctx %>/logout">Log out</a>
        </div>
    </nav>
</header>

<main class="cr-wrap">
    <a class="cr-back" href="<%= ctx %>/catalog">← Back to Movie Catalogue</a>
    <div class="cr-intro">
        <div class="cr-eyebrow">Secure movie rental checkout</div>
        <h1>Complete Your Rental</h1>
        <p class="cr-muted">Review your selected movie and choose a payment method.</p>
    </div>

    <!-- PaymentServlet handles this POST. CheckoutServlet only displays the page. -->
    <form id="checkoutForm" action="<%= ctx %>/payments" method="post">
        <input type="hidden" name="movieId" value="<%= HtmlUtil.escape(movie.getMovieId()) %>">
        <input type="hidden" name="csrfToken" value="<%= HtmlUtil.escape(csrfToken) %>">

        <div class="cr-grid">
            <div class="cr-stack">
                <section class="cr-card" aria-labelledby="movieHeading">
                    <div class="cr-card-head">
                        <h2 id="movieHeading">🎥 Movie Information</h2>
                        <p>Confirm the movie you want to rent.</p>
                    </div>
                    <div class="cr-card-body">
                        <div class="cr-movie">
                            <img class="cr-poster"
                                 src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(movie.getMovieId()) %>"
                                 alt="<%= HtmlUtil.escape(movie.getTitle()) %> poster"
                                 onerror="this.onerror=null;this.src='<%= ctx %>/images/posters/default.svg';">
                            <div>
                                <h3><%= HtmlUtil.escape(movie.getTitle()) %></h3>
                                <div class="cr-tags">
                                    <span class="cr-tag"><%= HtmlUtil.escape(movie.getGenre()) %></span>
                                    <span class="cr-tag"><%= movie.getReleaseYear() %></span>
                                    <span class="cr-tag">⭐ <%= String.format(Locale.US, "%.1f", movie.getRating()) %></span>
                                </div>
                                <p class="cr-description"><%= HtmlUtil.escape(movie.getDescription()) %></p>
                            </div>
                        </div>
                        <div class="cr-account">Renting as <strong><%= HtmlUtil.escape(userName) %></strong></div>
                    </div>
                </section>

                <section class="cr-card" aria-labelledby="methodHeading">
                    <div class="cr-card-head">
                        <h2 id="methodHeading">💳 Select Payment Method</h2>
                        <p>Payment confirmation is required before rental activation.</p>
                    </div>
                    <div class="cr-card-body">
                        <div class="cr-methods">
                            <label class="cr-option">
                                <input id="payHere" type="radio" name="paymentMethod"
                                       value="<%= HtmlUtil.escape(payHereMethod) %>" checked required>
                                <span class="cr-option-body">
                                    <span class="cr-option-icon">🔒</span>
                                    <span class="cr-option-text">
                                        <strong>PayHere Online Payment</strong>
                                        <small>Continue to PayHere's hosted checkout. Your payment is confirmed only after a verified server notification.</small>
                                    </span>
                                    <span class="cr-radio-dot" aria-hidden="true"></span>
                                </span>
                            </label>

                            <label class="cr-option">
                                <input id="bankTransfer" type="radio" name="paymentMethod"
                                       value="<%= HtmlUtil.escape(bankTransferMethod) %>" required>
                                <span class="cr-option-body">
                                    <span class="cr-option-icon">🏦</span>
                                    <span class="cr-option-text">
                                        <strong>Bank Transfer</strong>
                                        <small>Create a pending payment. An administrator must verify the transfer before rental activation.</small>
                                    </span>
                                    <span class="cr-radio-dot" aria-hidden="true"></span>
                                </span>
                            </label>

                            <% if (demoEnabled) { %>
                            <label class="cr-option">
                                <input id="demoCard" type="radio" name="paymentMethod"
                                       value="<%= HtmlUtil.escape(demoCardMethod) %>" required>
                                <span class="cr-option-body">
                                    <span class="cr-option-icon">🧪</span>
                                    <span class="cr-option-text">
                                        <strong>Demo Card (testing only)</strong>
                                        <small>Simulate a successful payment without charging real money.</small>
                                    </span>
                                    <span class="cr-radio-dot" aria-hidden="true"></span>
                                </span>
                            </label>
                            <% } %>
                        </div>

                        <div id="payhereBilling" class="cr-billing">
                            <h3>PayHere Billing Details</h3>
                            <p class="cr-muted">Your CineRent account name and email are used for checkout.</p>
                            <div class="cr-billing-grid">
                                <label class="cr-field" for="payherePhone">Phone number
                                    <input id="payherePhone" name="phone" type="tel" inputmode="tel"
                                           autocomplete="tel" placeholder="0771234567" maxlength="24"
                                           pattern="[+0-9 ()-]{7,24}" required>
                                </label>
                                <label class="cr-field" for="payhereAddress">Billing address
                                    <input id="payhereAddress" name="address" type="text"
                                           autocomplete="street-address" placeholder="Street address"
                                           maxlength="200" required>
                                </label>
                                <label class="cr-field" for="payhereCity">City
                                    <input id="payhereCity" name="city" type="text"
                                           autocomplete="address-level2" placeholder="Colombo"
                                           maxlength="80" required>
                                </label>
                            </div>
                        </div>

                        <div class="cr-notice" id="payhereNotice">
                            <strong>Secure online payment</strong>
                            CineRent redirects you to PayHere. Returning to the website does not
                            automatically mean payment succeeded; confirmation is verified by the server.
                        </div>
                        <div class="cr-notice" id="bankNotice" hidden>
                            <strong>Bank transfer instructions</strong>
                            Your payment will be created with PENDING status. Use the payment ID
                            as the bank transfer reference and send your receipt to the administrator.
                            Rental access starts only after approval and activation.
                        </div>
                        <% if (demoEnabled) { %>
                        <div class="cr-notice" id="demoNotice" hidden>
                            <strong>Testing mode</strong>
                            No real card details or money are used. This simulates payment approval.
                        </div>
                        <% } %>
                    </div>
                </section>
            </div>

            <aside class="cr-card" aria-labelledby="summaryHeading">
                <div class="cr-card-head">
                    <h2 id="summaryHeading">🧾 Order Summary</h2>
                    <p>Your rental payment details</p>
                </div>
                <div class="cr-card-body">
                    <div class="cr-summary-row">
                        <span>Movie</span><span><%= HtmlUtil.escape(movie.getTitle()) %></span>
                    </div>
                    <div class="cr-summary-row">
                        <span>Rental Price</span><span><%= HtmlUtil.escape(formattedPrice) %></span>
                    </div>
                    <div class="cr-summary-row"><span>Currency</span><span>LKR</span></div>
                    <div class="cr-summary-row">
                        <span>Availability</span><span><%= movie.getAvailableCopies() %> copies</span>
                    </div>
                    <div class="cr-total">
                        <span>Total</span><strong><%= HtmlUtil.escape(formattedPrice) %></strong>
                    </div>
                    <button class="cr-submit" type="submit" id="checkoutSubmit">
                        <span id="checkoutButtonText">🔒 Continue to PayHere</span>
                    </button>
                    <a class="cr-cancel" href="<%= ctx %>/catalog">Cancel and return to catalogue</a>
                    <div class="cr-security">
                        🔐 Your rental price is calculated on the server. Never enter card
                        details directly into CineRent; online card payments use PayHere.
                    </div>
                </div>
            </aside>
        </div>
    </form>

    <footer class="cr-footer">© 2026 CineRent · Movie Rental &amp; Review Platform</footer>
</main>

<script>
    (function () {
        'use strict';
        const form = document.getElementById('checkoutForm');
        const payHere = document.getElementById('payHere');
        const bank = document.getElementById('bankTransfer');
        const demo = document.getElementById('demoCard');
        const billing = document.getElementById('payhereBilling');
        const payhereNotice = document.getElementById('payhereNotice');
        const bankNotice = document.getElementById('bankNotice');
        const demoNotice = document.getElementById('demoNotice');
        const button = document.getElementById('checkoutSubmit');
        const buttonText = document.getElementById('checkoutButtonText');
        const billingInputs = billing.querySelectorAll('input');
        let submitting = false;

        function updateMethod() {
            const online = payHere.checked;
            const isBank = bank.checked;
            const isDemo = !!demo && demo.checked;
            billing.hidden = !online;
            payhereNotice.hidden = !online;
            bankNotice.hidden = !isBank;
            if (demoNotice) demoNotice.hidden = !isDemo;
            billingInputs.forEach(function (input) {
                input.required = online;
                input.disabled = !online;
            });
            buttonText.textContent = online ? '🔒 Continue to PayHere'
                : isBank ? '🏦 Create Bank Transfer Request'
                    : '🧪 Simulate Demo Payment';
        }

        [payHere, bank, demo].forEach(function (radio) {
            if (radio) radio.addEventListener('change', updateMethod);
        });
        form.addEventListener('submit', function (event) {
            if (submitting) {
                event.preventDefault();
                return;
            }
            if (!form.checkValidity()) return;
            submitting = true;
            button.disabled = true;
            buttonText.textContent = 'Processing...';
        });
        updateMethod();
    })();
</script>
</body>
</html>
