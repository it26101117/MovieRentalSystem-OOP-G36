
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx = request.getContextPath();

    List<Movie> movies =
            (List<Movie>) request.getAttribute("movies");

    String userName =
            (String) session.getAttribute("userName");

    String role =
            (String) session.getAttribute("role");

    Object userId =
            session.getAttribute("userId");

    if (userName == null || role == null || userId == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    if (!"CUSTOMER".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/admin");
        return;
    }

    int movieCount = movies == null ? 0 : movies.size();
    int availableCount = 0;

    if (movies != null) {
        for (Movie m : movies) {
            if (m != null && m.getAvailableCopies() > 0) {
                availableCount++;
            }
        }
    }

    String initial = userName.trim().isEmpty()
            ? "U"
            : userName.trim().substring(0, 1).toUpperCase();

    String error = request.getParameter("error");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Movie Catalogue | CineRent</title>

    <style>
        :root {
            --bg: #060a16;
            --surface: #101829;
            --surface2: #151f34;
            --border: #25314a;
            --text: #f8fafc;
            --muted: #94a3b8;
            --accent: #8b5cf6;
            --blue: #3b82f6;
            --green: #4ade80;
            --radius: 16px;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Inter, "Segoe UI", Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        button, input {
            font: inherit;
        }

        button {
            cursor: pointer;
        }

        [hidden] {
            display: none !important;
        }

        /* NAVIGATION */

        .navbar {
            position: sticky;
            top: 0;
            z-index: 100;
            background: rgba(6, 10, 22, 0.96);
            border-bottom: 1px solid var(--border);
            backdrop-filter: blur(16px);
        }

        .nav-inner {
            max-width: 1450px;
            padding: 18px 26px;
            margin: auto;
            display: flex;
            align-items: center;
            gap: 24px;
        }

        .brand {
            font-size: 23px;
            font-weight: 800;
            letter-spacing: -0.7px;
        }

        .brand span {
            color: #a78bfa;
        }

        .nav-links {
            margin-left: auto;
            display: flex;
            align-items: center;
            gap: 22px;
        }

        .nav-links a {
            color: var(--muted);
            font-size: 13px;
            font-weight: 600;
        }

        .nav-links a:hover,
        .nav-links a.active {
            color: white;
        }

        .avatar {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, #7c3aed, #2563eb);
            border-radius: 50%;
            font-weight: 700;
        }

        /* MAIN */

        .container {
            max-width: 1450px;
            margin: auto;
            padding: 34px 26px 80px;
        }

        .hero {
            padding: 36px;
            border-radius: 22px;
            border: 1px solid var(--border);
            background:
                    radial-gradient(
                            circle at 85% 15%,
                            rgba(124, 58, 237, .27),
                            transparent 40%
                    ),
                    linear-gradient(135deg, #19253d, #0e1424);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 25px;
            margin-bottom: 26px;
        }

        .eyebrow {
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1px;
            text-transform: uppercase;
            color: #c4b5fd;
            margin-bottom: 12px;
        }

        .hero h1 {
            font-size: clamp(30px, 4vw, 48px);
            margin: 0 0 12px;
            letter-spacing: -1.5px;
        }

        .hero h1 span {
            color: #a78bfa;
        }

        .hero p {
            margin: 0;
            color: var(--muted);
            max-width: 600px;
            line-height: 1.7;
            font-size: 14px;
        }

        .stats {
            display: flex;
            gap: 12px;
        }

        .stat {
            min-width: 125px;
            padding: 20px;
            background: rgba(10, 17, 32, .75);
            border: 1px solid var(--border);
            border-radius: 14px;
        }

        .stat strong {
            display: block;
            font-size: 28px;
            color: #c4b5fd;
        }

        .stat span {
            font-size: 11px;
            color: var(--muted);
        }

        /* PAYMENT NOTICE */

        .payment-notice {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
            padding: 18px 22px;
            margin-bottom: 22px;
            border: 1px solid #483477;
            background: rgba(124, 58, 237, .10);
            border-radius: var(--radius);
        }

        .payment-notice strong {
            color: #ddd6fe;
        }

        .payment-notice p {
            font-size: 12px;
            color: var(--muted);
            line-height: 1.6;
            margin: 6px 0 0;
        }

        .payment-notice a {
            flex-shrink: 0;
            padding: 10px 15px;
            border: 1px solid #644b9c;
            border-radius: 9px;
            font-size: 12px;
            color: white;
        }

        /* SEARCH AND SORT BAR */

        .catalog-controls {
            background: #101829;
            border: 1px solid #202c43;
            padding: 16px;
            border-radius: 17px;
            display: flex;
            align-items: center;
            gap: 16px;
            flex-wrap: wrap;
            margin-bottom: 28px;
        }

        .search-box {
            display: flex;
            align-items: center;
            flex: 1 1 300px;
            max-width: 440px;
            min-width: 0;
            gap: 10px;
            background: #0d1525;
            border: 1px solid #27324a;
            border-radius: 11px;
            padding: 0 14px;
            height: 46px;
            transition: .2s;
        }

        .search-box:focus-within {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(139, 92, 246, .12);
        }

        .search-icon {
            font-size: 16px;
        }

        .search-box input {
            width: 100%;
            height: 100%;
            background: transparent;
            border: none;
            outline: none;
            color: white;
            font-size: 13px;
        }

        .search-box input::placeholder {
            color: #78869d;
        }

        .clear-search {
            border: none;
            background: transparent;
            color: #94a3b8;
            font-size: 18px;
            padding: 5px;
        }

        .sort-group {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            gap: 8px;
        }

        .sort-label {
            text-transform: uppercase;
            color: #8495b4;
            font-size: 10px;
            font-weight: 800;
            margin-right: 4px;
        }

        .sort-btn {
            color: #b8c8e4;
            background: #172033;
            border: 1px solid #29364c;
            border-radius: 9px;
            padding: 12px 14px;
            font-size: 11px;
            font-weight: 700;
            transition: .2s;
        }

        .sort-btn:hover {
            border-color: var(--accent);
            color: white;
        }

        .sort-btn.active {
            background: #291d47;
            border-color: #6545ad;
            color: white;
        }

        .shortcuts {
            display: flex;
            gap: 9px;
            margin-left: auto;
        }

        .shortcut {
            padding: 13px 16px;
            border-radius: 10px;
            background: linear-gradient(135deg, #7025d7, #8b5cf6);
            color: white;
            font-size: 11px;
            font-weight: 800;
            white-space: nowrap;
        }

        .shortcut.secondary {
            background: #211b40;
            border: 1px solid #54417d;
        }

        /* RESULTS HEADER */

        .results-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 12px;
            margin-bottom: 20px;
        }

        .results-header h2 {
            margin: 0;
            font-size: 23px;
            letter-spacing: -.5px;
        }

        .result-count {
            font-size: 12px;
            color: var(--muted);
        }

        .result-count strong {
            color: #c4b5fd;
        }

        /* MOVIE GRID */

        .movie-grid {
            display: grid;
            grid-template-columns:
                repeat(auto-fill, minmax(240px, 1fr));
            gap: 22px;
        }

        .movie-card {
            background: #111a2d;
            border: 1px solid #24324a;
            border-radius: 17px;
            overflow: hidden;
            transition: transform .2s, border-color .2s;
            min-width: 0;
        }

        .movie-card:hover {
            transform: translateY(-4px);
            border-color: #7153bd;
        }

        .poster-area {
            position: relative;
            height: 300px;
            background: #19243a;
            overflow: hidden;
        }

        .poster-area img {
            width: 100%;
            height: 100%;
            display: block;
            object-fit: cover;
        }

        .poster-area::after {
            content: "";
            position: absolute;
            inset: 0;
            background: linear-gradient(
                    transparent 55%,
                    rgba(6, 10, 22, .55)
            );
            pointer-events: none;
        }

        .rating {
            position: absolute;
            top: 14px;
            right: 14px;
            z-index: 1;
            background: rgba(8, 12, 22, .85);
            border: 1px solid rgba(255, 255, 255, .12);
            border-radius: 8px;
            padding: 8px 11px;
            color: #facc15;
            font-size: 12px;
            font-weight: 800;
        }

        .movie-body {
            padding: 20px;
        }

        .movie-body h3 {
            font-size: 18px;
            margin: 0 0 12px;
            overflow-wrap: anywhere;
        }

        .movie-meta {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 9px;
            color: var(--muted);
            font-size: 12px;
            margin-bottom: 13px;
        }

        .genre {
            background: rgba(139, 92, 246, .13);
            color: #c4b5fd;
            padding: 5px 9px;
            border-radius: 6px;
        }

        .movie-description {
            font-size: 12px;
            line-height: 1.65;
            color: #9aa9c0;
            height: 60px;
            overflow: hidden;
            margin-bottom: 18px;
        }

        .card-bottom {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            border-top: 1px solid var(--border);
            padding-top: 17px;
        }

        .price-label {
            display: block;
            font-size: 10px;
            color: var(--muted);
            margin-bottom: 5px;
        }

        .price {
            font-size: 17px;
            font-weight: 800;
        }

        .availability {
            font-size: 10px;
            font-weight: 750;
            padding: 7px 8px;
            border-radius: 8px;
            color: #86efac;
            background: rgba(34, 197, 94, .11);
        }

        .availability.unavailable {
            background: rgba(239, 68, 68, .12);
            color: #fca5a5;
        }

        .card-actions {
            display: flex;
            gap: 9px;
            margin-top: 18px;
        }

        .card-actions a,
        .disabled-action {
            text-align: center;
            padding: 12px 8px;
            border-radius: 9px;
            font-size: 11px;
            font-weight: 800;
        }

        .review-action {
            flex: 1;
            background: #202c43;
            color: #e2e8f0;
        }

        .rent-action {
            flex: 1.5;
            background: linear-gradient(135deg, #6d28d9, #8b5cf6);
            color: white;
        }

        .disabled-action {
            flex: 1.5;
            color: #94a3b8;
            background: #253046;
            cursor: not-allowed;
        }

        /* EMPTY STATES */

        .empty-state {
            text-align: center;
            padding: 70px 20px;
            border: 1px dashed #34415b;
            border-radius: 16px;
            color: var(--muted);
            background: rgba(18, 27, 45, .55);
        }

        .empty-state .emoji {
            font-size: 40px;
            margin-bottom: 15px;
        }

        .empty-state h3 {
            color: white;
            margin: 0 0 10px;
        }

        .empty-state p {
            font-size: 13px;
        }

        .reset-btn {
            background: #7c3aed;
            color: white;
            border: none;
            padding: 12px 18px;
            border-radius: 9px;
            margin-top: 12px;
        }

        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 10px;
            border: 1px solid #854545;
            background: rgba(239, 68, 68, .1);
            color: #fecaca;
            font-size: 13px;
        }

        .alert.info {
            border-color: #34578c;
            background: rgba(59, 130, 246, .1);
            color: #bfdbfe;
        }

        .footer {
            text-align: center;
            padding: 25px;
            border-top: 1px solid var(--border);
            color: var(--muted);
            font-size: 12px;
        }

        /* RESPONSIVE */

        @media(max-width: 1050px) {
            .hero {
                flex-direction: column;
                align-items: flex-start;
            }

            .shortcuts {
                margin-left: 0;
            }
        }

        @media(max-width: 700px) {
            .nav-inner {
                flex-wrap: wrap;
                gap: 14px;
            }

            .nav-links {
                order: 3;
                width: 100%;
                overflow-x: auto;
                margin-left: 0;
            }

            .container {
                padding: 22px 15px 50px;
            }

            .hero {
                padding: 25px;
            }

            .stats {
                width: 100%;
            }

            .stat {
                min-width: 0;
                flex: 1;
            }

            .catalog-controls {
                flex-direction: column;
                align-items: stretch;
            }

            .search-box {
                max-width: none;
                flex: none;
                width: 100%;
            }

            .shortcuts {
                width: 100%;
            }

            .shortcut {
                flex: 1;
                text-align: center;
            }

            .movie-grid {
                grid-template-columns:
                    repeat(auto-fill, minmax(210px, 1fr));
            }

            .payment-notice {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>

<body>

<!-- NAVBAR -->

<header class="navbar">
    <div class="nav-inner">

        <a href="<%= ctx %>/catalog" class="brand">
            🎬 Cine<span>Rent</span>
        </a>

        <nav class="nav-links">
            <a href="<%= ctx %>/catalog" class="active">
                Browse Movies
            </a>

            <a href="<%= ctx %>/rentals">
                My Rentals
            </a>

            <a href="<%= ctx %>/payments">
                My Payments
            </a>

            <a href="<%= ctx %>/logout">
                Logout
            </a>
        </nav>

        <div class="avatar"
             title="<%= HtmlUtil.escape(userName) %>">
            <%= HtmlUtil.escape(initial) %>
        </div>

    </div>
</header>

<main class="container">

    <!-- HERO -->

    <section class="hero">

        <div>
            <div class="eyebrow">
                Premium Movie Rental Experience
            </div>

            <h1>
                Explore <span>Movies</span>
            </h1>

            <p>
                Discover your next favourite movie.
                Search, explore reviews, rent movies
                and manage your payments with CineRent.
            </p>
        </div>

        <div class="stats">

            <div class="stat">
                <strong><%= movieCount %></strong>
                <span>Total Movies</span>
            </div>

            <div class="stat">
                <strong><%= availableCount %></strong>
                <span>Available Now</span>
            </div>

        </div>

    </section>

    <!-- ERRORS -->

    <% if (error != null) { %>

    <div class="alert <%= (
            "alreadyrented".equalsIgnoreCase(error) ||
            "alreadyactive".equalsIgnoreCase(error) ||
            "paymentpending".equalsIgnoreCase(error)
        ) ? "info" : "" %>" role="alert">

        <%
            if ("notfound".equalsIgnoreCase(error)) {
        %>
        Movie not found.
        <%
        } else if ("unavailable".equalsIgnoreCase(error)) {
        %>
        This movie is currently unavailable.
        <%
        } else if ("alreadyrented".equalsIgnoreCase(error)
                || "alreadyactive".equalsIgnoreCase(error)) {
        %>
        You already have an active rental for this movie.
        <%
        } else if ("paymentrequired".equalsIgnoreCase(error)) {
        %>
        Please complete payment before renting.
        <%
        } else if ("paymentpending".equalsIgnoreCase(error)) {
        %>
        Your bank transfer is awaiting approval.
        <%
        } else if ("paymentfailed".equalsIgnoreCase(error)) {
        %>
        Payment failed. Please try again.
        <%
        } else {
        %>
        Unable to complete the requested action.
        <%
            }
        %>

    </div>

    <% } %>

    <!-- PAYMENT NOTICE -->

    <div class="payment-notice">

        <div>
            <strong>💳 Secure Movie Checkout</strong>
            <p>
                Select a movie and continue to checkout.
                Demo Card payments are simulated.
                Bank Transfers require administrator approval.
            </p>
        </div>

        <a href="<%= ctx %>/payments">
            View My Payments
        </a>

    </div>

    <!-- SEARCH AND SORT -->

    <section class="catalog-controls">

        <div class="search-box">

            <span class="search-icon">🔍</span>

            <input
                    type="search"
                    id="catalogSearch"
                    placeholder="Search movie title, genre or year..."
                    aria-label="Search movies"
                    autocomplete="off"
            >

            <button
                    type="button"
                    class="clear-search"
                    id="clearSearch"
                    aria-label="Clear search"
                    hidden
            >
                ×
            </button>

        </div>

        <div class="sort-group">

            <span class="sort-label">
                Sort By
            </span>

            <button
                    type="button"
                    class="sort-btn active"
                    data-sort="default">
                Default
            </button>

            <button
                    type="button"
                    class="sort-btn"
                    data-sort="rating-desc">
                Highest Rated
            </button>

            <button
                    type="button"
                    class="sort-btn"
                    data-sort="rating-asc">
                Lowest Rated
            </button>

        </div>

        <div class="shortcuts">

            <a href="<%= ctx %>/rentals" class="shortcut">
                ▶ My Rentals
            </a>

            <a href="<%= ctx %>/payments"
               class="shortcut secondary">
                💳 My Payments
            </a>

        </div>

    </section>

    <!-- RESULTS -->

    <div class="results-header">

        <h2>Available Movies</h2>

        <div class="result-count" aria-live="polite">
            Showing
            <strong id="catalogResultCount">
                <%= movieCount %>
            </strong>
            of
            <strong><%= movieCount %></strong>
            movies
        </div>

    </div>

    <!-- MOVIES -->

    <section class="movie-grid" id="movieGrid">

        <% if (movies != null) {

            int index = 0;

            for (Movie movie : movies) {

                if (movie == null) {
                    continue;
                }

                boolean available =
                        movie.getAvailableCopies() > 0;

                boolean validPrice =
                        Double.isFinite(movie.getRentalPrice())
                                && movie.getRentalPrice() > 0;

                boolean canCheckout =
                        available && validPrice;

                String encodedMovieId = URLEncoder.encode(
                        movie.getMovieId(),
                        StandardCharsets.UTF_8
                );

                double rating = movie.getRating();

                if (!Double.isFinite(rating)) {
                    rating = 0;
                }
        %>

        <article
                class="movie-card"
                data-catalog-card
                data-index="<%= index++ %>"
                data-rating="<%= rating %>"
                data-title="<%= HtmlUtil.escape(
                String.valueOf(movie.getTitle())
            ) %>"
                data-genre="<%= HtmlUtil.escape(
                String.valueOf(movie.getGenre())
            ) %>"
                data-year="<%= movie.getReleaseYear() %>"
                data-id="<%= HtmlUtil.escape(
                movie.getMovieId()
            ) %>"
        >

            <!-- POSTER -->

            <div class="poster-area">

                <img
                        src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(encodedMovieId) %>"
                        alt="<%= HtmlUtil.escape(movie.getTitle()) %>"
                        loading="lazy"
                        onerror="
                                this.onerror=null;
                                this.src='<%= ctx %>/images/posters/default.svg';
                                "
                >

                <div class="rating">
                    ⭐ <%= String.format(
                        java.util.Locale.US, "%.1f", rating
                ) %>
                </div>

            </div>

            <!-- DETAILS -->

            <div class="movie-body">

                <h3>
                    <%= HtmlUtil.escape(movie.getTitle()) %>
                </h3>

                <div class="movie-meta">

                    <span class="genre">
                        <%= HtmlUtil.escape(movie.getGenre()) %>
                    </span>

                    <span>
                        📅 <%= movie.getReleaseYear() %>
                    </span>

                </div>

                <div class="movie-description">

                    <%
                        String description =
                                movie.getDescription();

                        if (description == null ||
                                description.trim().isEmpty()) {
                    %>

                    No description available for this movie.

                    <% } else { %>

                    <%= HtmlUtil.escape(description) %>

                    <% } %>

                </div>

                <div class="card-bottom">

                    <div>

                        <span class="price-label">
                            Rental Price
                        </span>

                        <div class="price">
                            LKR <%= String.format(
                                java.util.Locale.US,
                                "%.2f",
                                movie.getRentalPrice()
                        ) %>
                        </div>

                    </div>

                    <span class="availability
                        <%= available ? "" : "unavailable" %>">

                        <%= available
                                ? "✓ " + movie.getAvailableCopies()
                                + " available"
                                : "✕ Unavailable"
                        %>

                    </span>

                </div>

                <!-- ACTIONS -->

                <div class="card-actions">

                    <a
                            href="<%= ctx %>/reviews?movieId=<%= HtmlUtil.escape(encodedMovieId) %>"
                            class="review-action"
                    >
                        ⭐ Reviews
                    </a>

                    <% if (canCheckout) { %>

                    <a
                            href="<%= ctx %>/checkout?movieId=<%= HtmlUtil.escape(encodedMovieId) %>"
                            class="rent-action"
                    >
                        💳 Rent &amp; Pay
                    </a>

                    <% } else { %>

                    <span class="disabled-action">
                            <%= available
                                    ? "Price Unavailable"
                                    : "Unavailable"
                            %>
                        </span>

                    <% } %>

                </div>

            </div>

        </article>

        <%
                }
            } %>

    </section>

    <!-- NO SEARCH RESULTS -->

    <div
            id="catalogSearchEmpty"
            class="empty-state"
            hidden
    >

        <div class="emoji">🔎</div>

        <h3>No Movies Found</h3>

        <p>
            No movies match your search.
            Try another title, genre, or year.
        </p>

        <button
                type="button"
                class="reset-btn"
                id="resetSearch"
        >
            Clear Search
        </button>

    </div>

    <!-- NO MOVIES IN DATABASE -->

    <% if (movieCount == 0) { %>

    <div class="empty-state">

        <div class="emoji">🎬</div>

        <h3>No Movies Available</h3>

        <p>
            The movie catalogue is currently empty.
        </p>

    </div>

    <% } %>

</main>

<footer class="footer">
    © 2026 CineRent • Movie Rental &amp; Review Platform
</footer>

<!-- LIVE SEARCH AND SORT SCRIPT -->

<script>
    document.addEventListener("DOMContentLoaded", function () {

        "use strict";

        const searchInput =
            document.getElementById("catalogSearch");

        const clearButton =
            document.getElementById("clearSearch");

        const resetButton =
            document.getElementById("resetSearch");

        const movieGrid =
            document.getElementById("movieGrid");

        const resultCount =
            document.getElementById("catalogResultCount");

        const emptyMessage =
            document.getElementById("catalogSearchEmpty");

        const sortButtons =
            document.querySelectorAll(".sort-btn[data-sort]");

        if (!searchInput || !movieGrid) {
            console.error("Catalog search elements not found.");
            return;
        }

        const movieCards = Array.from(
            movieGrid.querySelectorAll("[data-catalog-card]")
        );

        let currentSort = "default";

        // Normalize text for case-insensitive searches.
        function normalize(value) {
            return String(value || "")
                .toLocaleLowerCase()
                .trim()
                .replace(/\s+/g, " ");
        }

        // Search titles, genres, release years and IDs.
        function matchesSearch(card, query) {

            if (query === "") {
                return true;
            }

            const movieData = [
                card.dataset.title,
                card.dataset.genre,
                card.dataset.year,
                card.dataset.id
            ].map(normalize).join(" ");

            return movieData.includes(query);
        }

        // Apply the current sorting order.
        function sortMovies() {

            const cards = [...movieCards];

            cards.sort(function (a, b) {

                const ratingA =
                    Number.parseFloat(a.dataset.rating) || 0;

                const ratingB =
                    Number.parseFloat(b.dataset.rating) || 0;

                const indexA =
                    Number.parseInt(a.dataset.index, 10) || 0;

                const indexB =
                    Number.parseInt(b.dataset.index, 10) || 0;

                if (currentSort === "rating-desc") {
                    return (ratingB - ratingA)
                        || (indexA - indexB);
                }

                if (currentSort === "rating-asc") {
                    return (ratingA - ratingB)
                        || (indexA - indexB);
                }

                return indexA - indexB;
            });

            // Reorder existing DOM elements.
            cards.forEach(function (card) {
                movieGrid.appendChild(card);
            });
        }

        // Filter movie cards using the search text.
        function filterMovies() {

            const query = normalize(searchInput.value);
            let visibleCount = 0;

            movieCards.forEach(function (card) {

                const matched = matchesSearch(card, query);

                card.hidden = !matched;

                // Remove conflicting inline display values.
                card.style.removeProperty("display");

                if (matched) {
                    visibleCount++;
                }
            });

            if (resultCount) {
                resultCount.textContent = visibleCount;
            }

            if (emptyMessage) {
                emptyMessage.hidden =
                    visibleCount !== 0 || movieCards.length === 0;
            }

            if (clearButton) {
                clearButton.hidden = searchInput.value === "";
            }
        }

        // Run both operations together.
        function updateCatalogue() {
            sortMovies();
            filterMovies();
        }

        // LIVE SEARCH
        searchInput.addEventListener("input", function () {
            filterMovies();
        });

        // SORT BUTTON EVENTS
        sortButtons.forEach(function (button) {

            button.addEventListener("click", function () {

                currentSort = button.dataset.sort;

                sortButtons.forEach(function (btn) {
                    btn.classList.remove("active");
                    btn.setAttribute("aria-pressed", "false");
                });

                button.classList.add("active");
                button.setAttribute("aria-pressed", "true");

                updateCatalogue();
            });
        });

        // CLEAR SEARCH
        function clearSearch() {
            searchInput.value = "";
            filterMovies();
            searchInput.focus();
        }

        if (clearButton) {
            clearButton.addEventListener("click", clearSearch);
        }

        if (resetButton) {
            resetButton.addEventListener("click", clearSearch);
        }

        // INITIALIZE
        sortButtons.forEach(function (button) {
            button.setAttribute(
                "aria-pressed",
                String(button.dataset.sort === currentSort)
            );
        });

        updateCatalogue();

        console.log(
            "CineRent catalogue initialized:",
            movieCards.length,
            "movies"
        );

    });
</script>

</body>
</html>
