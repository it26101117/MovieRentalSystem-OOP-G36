
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="java.util.List,java.util.ArrayList,java.util.Comparator,java.util.Locale" %>
<%@ page import="com.movierental.model.Payment" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%!
    private String esc(Object value) {
        return HtmlUtil.escape(value == null ? "" : String.valueOf(value));
    }

    private String kind(Payment payment) {
        return payment.isPaid() ? "paid" : payment.isPending() ? "pending" : "other";
    }

    private String label(Payment payment) {
        if (payment.isPaid()) return "Paid";
        if (payment.isPending()) return "Pending";

        String value = payment.getPaymentStatus();

        return value == null || value.trim().isEmpty()
                ? "Unknown" : value;
    }
%>

<%
    String ctx = request.getContextPath();

    Object nameValue = request.getAttribute("userName");

    if (nameValue == null && session != null) {
        nameValue = session.getAttribute("userName");
    }

    String userName = nameValue == null ||
            String.valueOf(nameValue).trim().isEmpty()
            ? "Customer" : String.valueOf(nameValue).trim();

    Payment selected = (Payment) request.getAttribute("payment");
    Movie selectedMovie = (Movie) request.getAttribute("movie");

    String message = request.getAttribute("paymentMessage") == null
            ? "" : String.valueOf(request.getAttribute("paymentMessage"));

    List<Payment> payments = new ArrayList<>();

    Object supplied = request.getAttribute("payments");

    if (supplied instanceof List<?>) {
        for (Object element : (List<?>) supplied) {
            if (element instanceof Payment) {
                payments.add((Payment) element);
            }
        }
    }

    if (selected != null) {
        boolean exists = false;

        for (Payment p : payments) {
            if (p.getPaymentId().equals(selected.getPaymentId())) {
                exists = true;
                break;
            }
        }

        if (!exists) payments.add(selected);
    }

    payments.sort(Comparator.comparing(
            Payment::getCreatedAt,
            Comparator.nullsLast(Comparator.reverseOrder())
    ));

    int paid = 0, pending = 0, other = 0;

    for (Payment p : payments) {
        if (p.isPaid()) paid++;
        else if (p.isPending()) pending++;
        else other++;
    }
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <meta name="theme-color" content="#090c17">

    <title>My Payments | CineRent</title>

    <style>
        :root {
            color-scheme: dark;
            --bg: #090c17;
            --surface: #121a2c;
            --surface2: #171f35;
            --line: #2b3550;
            --text: #f5f6ff;
            --muted: #a9b6d3;
            --purple: #8b5cf6;
            --green: #44ddb3;
            --amber: #f6bb55;
        }

        *, *::before, *::after {
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            margin: 0;
            background: var(--bg);
            color: var(--text);
            font: 15px/1.55 Inter, system-ui,
            -apple-system, "Segoe UI", Arial, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        button, input, select {
            font: inherit;
        }

        a:focus-visible,
        button:focus-visible,
        input:focus-visible,
        select:focus-visible {
            outline: 2px solid #c7b3ff;
            outline-offset: 3px;
        }

        .cr-topbar {
            background: #0e1322;
            border-bottom: 1px solid #252f47;
        }

        .cr-shell {
            width: min(1160px, calc(100% - 40px));
            margin-inline: auto;
        }

        .cr-top-inner {
            min-height: 70px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
        }

        .cr-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 21px;
            font-weight: 850;
            letter-spacing: -.7px;
        }

        .cr-logo-icon {
            display: grid;
            place-items: center;
            width: 35px;
            height: 35px;
            border-radius: 10px;
            background: #312457;
            font-size: 19px;
        }

        .cr-logo b {
            color: #b9a0ff;
        }

        .cr-nav {
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }

        .cr-nav a {
            font-size: 13px;
            color: #cad4e9;
            padding: 9px 12px;
            border-radius: 9px;
        }

        .cr-nav a:hover,
        .cr-nav a[aria-current="page"] {
            color: #fff;
            background: #252041;
        }

        .cr-main {
            padding: 30px 0 75px;
        }

        .cr-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 21px;
        }

        .cr-eyebrow {
            font-size: 11px;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: #b9a0ff;
            font-weight: 850;
            margin: 0 0 7px;
        }

        .cr-heading h1 {
            font-size: clamp(29px, 4vw, 42px);
            line-height: 1.15;
            letter-spacing: -1.5px;
            margin: 0 0 8px;
        }

        .cr-heading h1 span {
            color: #b49bff;
        }

        .cr-sub {
            margin: 0;
            color: var(--muted);
            font-size: 14px;
        }

        .cr-btn {
            border: 1px solid transparent;
            border-radius: 10px;
            background: #7c3aed;
            color: #fff;
            display: inline-flex;
            gap: 8px;
            justify-content: center;
            align-items: center;
            padding: 11px 16px;
            font-weight: 750;
            font-size: 13px;
            cursor: pointer;
            white-space: nowrap;
            transition: background .15s;
        }

        .cr-btn:hover {
            background: #6d28d9;
        }

        .cr-btn-secondary {
            background: #202b43;
            border-color: #394763;
        }

        .cr-btn-secondary:hover {
            background: #2c3b59;
        }

        .cr-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
            margin-bottom: 31px;
        }

        .cr-stat {
            border: 1px solid var(--line);
            background: var(--surface);
            border-radius: 14px;
            padding: 18px 21px;
            min-height: 105px;
        }

        .cr-stat .cr-label {
            font-size: 12px;
            color: var(--muted);
        }

        .cr-value {
            font-size: 31px;
            font-weight: 850;
            margin-top: 8px;
            line-height: 1.1;
            letter-spacing: -1px;
        }

        .cr-green {
            color: var(--green);
        }

        .cr-amber {
            color: var(--amber);
        }

        .cr-sectionhead {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            gap: 16px;
            margin: 0 0 18px;
        }

        .cr-sectionhead h2 {
            margin: 0 0 4px;
            font-size: 22px;
            letter-spacing: -.6px;
        }

        .cr-sectionhead p {
            margin: 0;
            color: var(--muted);
            font-size: 13px;
        }

        .cr-controls {
            display: flex;
            gap: 11px;
            align-items: center;
            margin-bottom: 15px;
        }

        .cr-search {
            flex: 1;
            min-width: 0;
            border: 1px solid #34405b;
            background: var(--surface);
            color: #fff;
            border-radius: 10px;
            padding: 13px 15px;
        }

        .cr-filter {
            border: 1px solid #34405b;
            background: var(--surface);
            color: #fff;
            border-radius: 10px;
            padding: 13px 34px 13px 14px;
            min-width: 155px;
        }

        .cr-results {
            color: var(--muted);
            font-size: 12px;
            white-space: nowrap;
        }

        .cr-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 15px;
        }

        .cr-card {
            background: var(--surface);
            border: 1px solid var(--line);
            border-radius: 16px;
            padding: 21px;
            min-width: 0;
        }

        .cr-cardhead {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 16px;
        }

        .cr-id {
            font-size: 12px;
            color: var(--muted);
        }

        .cr-badge {
            border-radius: 99px;
            padding: 4px 10px;
            font-size: 11px;
            font-weight: 850;
            text-transform: uppercase;
            letter-spacing: .4px;
            border: 1px solid;
        }

        .cr-badge.paid {
            border-color: #21634e;
            background: #12392d;
            color: #70f0bb;
        }

        .cr-badge.pending {
            border-color: #76501b;
            background: #3b2a14;
            color: #ffc975;
        }

        .cr-badge.other {
            border-color: #763f48;
            background: #3e222b;
            color: #ffb0b8;
        }

        .cr-movie {
            margin: 0 0 4px;
            font-size: 20px;
            font-weight: 850;
            letter-spacing: -.4px;
        }

        .cr-secondary {
            font-size: 12px;
            color: var(--muted);
            margin: 0 0 16px;
        }

        .cr-info {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 14px;
            margin-bottom: 17px;
        }

        .cr-info small {
            display: block;
            color: var(--muted);
            font-size: 11px;
            margin-bottom: 3px;
        }

        .cr-info strong {
            display: block;
            font-size: 13px;
            overflow-wrap: anywhere;
        }

        .cr-foot {
            border-top: 1px solid var(--line);
            padding-top: 15px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
        }

        .cr-money {
            font-size: 19px;
            font-weight: 850;
            letter-spacing: -.4px;
        }

        .cr-notice {
            border: 1px solid #5c4c88;
            background: #24213a;
            border-radius: 10px;
            color: #d9cef8;
            padding: 12px 14px;
            margin: 12px 0 19px;
            font-size: 13px;
        }

        .cr-notice.pending {
            border-color: #6a512b;
            background: #30281e;
            color: #f7d5a3;
        }

        .cr-empty {
            text-align: center;
            padding: 50px 20px;
            border: 1px dashed #384460;
            border-radius: 15px;
            background: var(--surface);
            color: var(--muted);
        }

        .cr-empty h3 {
            color: white;
            margin: 8px 0 5px;
        }

        .cr-empty p {
            margin: 0 0 16px;
        }

        .cr-hidden {
            display: none !important;
        }

        .cr-selected {
            margin-bottom: 30px;
            border-color: #55407f;
            background: linear-gradient(135deg, #1f1b3b, #121a2c);
        }

        .cr-selected .cr-info {
            max-width: 700px;
        }

        .cr-selected .cr-foot {
            justify-content: flex-start;
        }

        @media (max-width: 850px) {
            .cr-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .cr-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 600px) {
            .cr-shell {
                width: min(100% - 28px, 1160px);
            }

            .cr-top-inner {
                align-items: flex-start;
                flex-direction: column;
                justify-content: center;
                padding: 12px 0;
                gap: 7px;
            }

            .cr-nav {
                gap: 0;
            }

            .cr-nav a {
                padding: 7px 9px;
            }

            .cr-main {
                padding-top: 25px;
            }

            .cr-heading {
                align-items: flex-start;
                flex-direction: column;
            }

            .cr-stats {
                gap: 9px;
            }

            .cr-stat {
                padding: 15px;
            }

            .cr-controls {
                flex-wrap: wrap;
            }

            .cr-search {
                flex-basis: 100%;
            }

            .cr-filter {
                flex: 1;
                min-width: 0;
            }

            .cr-results {
                margin-left: auto;
            }

            .cr-foot {
                align-items: flex-start;
                flex-direction: column;
            }

            .cr-foot .cr-btn {
                width: 100%;
            }

            .cr-info {
                gap: 11px;
            }
        }
    </style>
</head>

<body>

<header class="cr-topbar">
    <div class="cr-shell cr-top-inner">

        <a class="cr-logo" href="<%= esc(ctx) %>/catalog">
            <span class="cr-logo-icon">🎬</span>
            <span>Cine<b>Rent</b></span>
        </a>

        <nav class="cr-nav" aria-label="Primary navigation">
            <a href="<%= esc(ctx) %>/catalog">Movies</a>
            <a href="<%= esc(ctx) %>/rentals">My Rentals</a>
            <a href="<%= esc(ctx) %>/payments"
               aria-current="page">Payments</a>
            <a href="<%= esc(ctx) %>/logout">Logout</a>
        </nav>

    </div>
</header>

<main class="cr-shell cr-main">

    <section class="cr-heading">
        <div>
            <p class="cr-eyebrow">Customer dashboard</p>

            <h1>My <span>Payments</span></h1>

            <p class="cr-sub">
                Welcome back, <%= esc(userName) %>.
                Track payments and manage your movie rentals.
            </p>
        </div>

        <a class="cr-btn" href="<%= esc(ctx) %>/catalog">
            + Browse Movies
        </a>
    </section>

    <section class="cr-stats" aria-label="Payment summary">

        <div class="cr-stat">
            <div class="cr-label">Total Payments</div>
            <div class="cr-value"><%= payments.size() %></div>
        </div>

        <div class="cr-stat">
            <div class="cr-label">Paid</div>
            <div class="cr-value cr-green"><%= paid %></div>
        </div>

        <div class="cr-stat">
            <div class="cr-label">Pending</div>
            <div class="cr-value cr-amber"><%= pending %></div>
        </div>

        <div class="cr-stat">
            <div class="cr-label">Other Statuses</div>
            <div class="cr-value"><%= other %></div>
        </div>

    </section>

    <% if (selected != null) { %>

    <section class="cr-card cr-selected"
             aria-label="Selected payment details">

        <div class="cr-cardhead">
            <div>
                <p class="cr-eyebrow">Payment details</p>
                <h2 class="cr-movie">
                    Payment <%= esc(selected.getPaymentId()) %>
                </h2>
            </div>

            <span class="cr-badge <%= kind(selected) %>">
                <%= esc(label(selected)) %>
            </span>
        </div>

        <% if (!message.isBlank()) { %>
        <div class="cr-notice <%= selected.isPending() ? "pending" : "" %>">
            <%= esc(message) %>
        </div>
        <% } %>

        <div class="cr-info">

            <div>
                <small>Movie</small>
                <strong>
                    <%= esc(selectedMovie == null
                            ? selected.getMovieId()
                            : selectedMovie.getTitle()) %>
                </strong>
            </div>

            <div>
                <small>Amount</small>
                <strong>
                    <%= esc(selected.getFormattedAmount()) %>
                </strong>
            </div>

            <div>
                <small>Payment Method</small>
                <strong>
                    <%= esc(selected.getPaymentMethodDisplay()) %>
                </strong>
            </div>

            <div>
                <small>Created</small>
                <strong>
                    <%= esc(selected.getFormattedCreatedAt()) %>
                </strong>
            </div>

            <div>
                <small>Rental Status</small>
                <strong>
                    <%= selected.hasRental()
                            ? "Activated"
                            : "Not activated" %>
                </strong>
            </div>

            <div>
                <small>Rental ID</small>
                <strong>
                    <%= selected.hasRental()
                            ? esc(selected.getRentalId())
                            : "—" %>
                </strong>
            </div>

        </div>

        <div class="cr-foot">

            <% if (selected.isPaid() && selected.hasRental()) { %>

            <a class="cr-btn" href="<%= esc(ctx) %>/rentals">
                View My Rentals
            </a>

            <% } else if (selected.isPaid()) { %>

            <a class="cr-btn"
               href="<%= esc(ctx) %>/rentals">
                Go to Rental Activation
            </a>

            <% } else if (selected.isPending()) { %>

            <a class="cr-btn cr-btn-secondary"
               href="<%= esc(ctx) %>/payments?paymentId=<%= esc(selected.getPaymentId()) %>">
                Refresh Status
            </a>

            <% } else { %>

            <a class="cr-btn cr-btn-secondary"
               href="<%= esc(ctx) %>/catalog">
                Browse Movies
            </a>

            <% } %>

        </div>
    </section>

    <% } %>

    <section aria-label="Payment history">

        <div class="cr-sectionhead">
            <div>
                <h2>Payment History</h2>
                <p>Review all your movie checkout transactions.</p>
            </div>
        </div>

        <div class="cr-controls">

            <input class="cr-search"
                   id="paymentSearch"
                   type="search"
                   placeholder="Search payment ID or movie ID"
                   aria-label="Search payments">

            <select class="cr-filter"
                    id="paymentFilter"
                    aria-label="Filter by status">

                <option value="all">All Payments</option>
                <option value="paid">Paid</option>
                <option value="pending">Pending</option>
                <option value="other">Other</option>

            </select>

            <span class="cr-results" id="paymentCount">
                Showing <%= payments.size() %>
            </span>

        </div>

        <% if (payments.isEmpty()) { %>

        <div class="cr-empty">
            <div style="font-size:28px">🎟️</div>
            <h3>No payments yet</h3>
            <p>
                Your movie purchases will appear here after checkout.
            </p>

            <a class="cr-btn" href="<%= esc(ctx) %>/catalog">
                Explore Movies
            </a>
        </div>

        <% } else { %>

        <div class="cr-grid" id="paymentList">

            <% for (Payment p : payments) { %>

            <article class="cr-card cr-payment"
                     data-status="<%= kind(p) %>"
                     data-search="<%= esc(
                         (p.getPaymentId() + " " + p.getMovieId())
                         .toLowerCase(Locale.ROOT)
                     ) %>">

                <div class="cr-cardhead">

                    <span class="cr-id">
                        Payment #<%= esc(p.getPaymentId()) %>
                    </span>

                    <span class="cr-badge <%= kind(p) %>">
                        <%= esc(label(p)) %>
                    </span>

                </div>

                <h3 class="cr-movie">
                    Movie <%= esc(p.getMovieId()) %>
                </h3>

                <p class="cr-secondary">
                    <%= esc(p.getPaymentMethodDisplay()) %>
                    ·
                    <%= esc(p.getFormattedCreatedAt()) %>
                </p>

                <div class="cr-info">

                    <div>
                        <small>Rental Status</small>
                        <strong>
                            <%= p.hasRental()
                                    ? "Activated"
                                    : (p.isPaid()
                                    ? "Ready to activate"
                                    : "Not activated") %>
                        </strong>
                    </div>

                    <div>
                        <small>Payment Method</small>
                        <strong>
                            <%= esc(p.getPaymentMethodDisplay()) %>
                        </strong>
                    </div>

                </div>

                <div class="cr-foot">

                    <strong class="cr-money">
                        <%= esc(p.getFormattedAmount()) %>
                    </strong>

                    <a class="cr-btn cr-btn-secondary"
                       href="<%= esc(ctx) %>/payments?paymentId=<%= esc(p.getPaymentId()) %>">

                        <%= p.isPaid() && !p.hasRental()
                                ? "Activate / Details"
                                : "View Payment" %>

                    </a>

                </div>

            </article>

            <% } %>

        </div>

        <div class="cr-empty cr-hidden" id="noMatches">
            <h3>No matching payments</h3>
            <p>
                Try changing your search or status filter.
            </p>
        </div>

        <% } %>

    </section>

</main>

<script>
    (function () {

        const search = document.getElementById('paymentSearch');
        const filter = document.getElementById('paymentFilter');
        const count = document.getElementById('paymentCount');
        const empty = document.getElementById('noMatches');

        const cards = Array.from(
            document.querySelectorAll('.cr-payment')
        );

        function update() {

            const query = (search.value || '')
                .toLowerCase()
                .trim();

            const status = filter.value;

            let visible = 0;

            cards.forEach(function(card) {

                const matches =
                    (!query ||
                        (card.dataset.search || '').includes(query))
                    &&
                    (status === 'all' ||
                        card.dataset.status === status);

                card.classList.toggle('cr-hidden', !matches);

                if (matches) visible++;
            });

            count.textContent =
                'Showing ' + visible + ' of ' + cards.length;

            if (empty) {
                empty.classList.toggle(
                    'cr-hidden',
                    visible !== 0
                );
            }
        }

        search.addEventListener('input', update);
        filter.addEventListener('change', update);

        update();

    })();
</script>

</body>
</html>
