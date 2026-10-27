<<<<<<< HEAD

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Rental" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.service.MovieService" %>
<%@ page import="com.movierental.util.HtmlUtil" %>
<%
    String ctx = request.getContextPath();
    List<Rental> rentals = (List<Rental>) request.getAttribute("rentals");
    MovieService movieService = (MovieService) request.getAttribute("movieService");
    String userName = (String) session.getAttribute("userName");
    String role = (String) session.getAttribute("role");


    // SECURITY

    if (userName == null || role == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }

    if (!"CUSTOMER".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/admin");
        return;
    }


    // COUNTS

    int totalRentalCount = 0;
    int activeRentalCount = 0;
    int returnedRentalCount = 0;

    if (rentals != null) {
        totalRentalCount = rentals.size();

        for (Rental rental : rentals) {
            if ("RENTED".equalsIgnoreCase(rental.getStatus())) {
                activeRentalCount++;
            } else if ("RETURNED".equalsIgnoreCase(rental.getStatus())) {
                returnedRentalCount++;
            }
        }
    }


    // USER INITIAL

    String userInitial = "U";

    if (userName != null && !userName.trim().isEmpty()) {
        userInitial = userName.trim().substring(0, 1).toUpperCase();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Rentals | CineRent</title>
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>

        /*
           PAGE
         */
        body {
            background: #050811;
            color: #ffffff;
        }

        .rentals-page {
            min-height: calc(100vh - 80px);
            padding: 45px 0 80px;
            background:
                radial-gradient(circle at 75% 5%, rgba(124, 58, 237, 0.16), transparent 28%),
                radial-gradient(circle at 10% 60%, rgba(37, 99, 235, 0.08), transparent 24%);
        }

        .rentals-container {
            width: 92%;
            max-width: 1380px;
            margin: 0 auto;
        }

        /*
           NAVIGATION
         */
        .customer-navbar {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: rgba(4, 7, 14, 0.88);
            border-bottom: 1px solid rgba(255, 255, 255, 0.06);
            backdrop-filter: blur(18px);
        }

        .customer-navbar-inner {
            width: 92%;
            max-width: 1380px;
            min-height: 76px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            gap: 25px;
        }

        .customer-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #ffffff;
            text-decoration: none;
            font-size: 20px;
            font-weight: 850;
            letter-spacing: -0.5px;
        }

        .customer-brand-icon {
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 13px;
            background: linear-gradient(135deg, #6d28d9, #8b5cf6);
            box-shadow: 0 8px 25px rgba(124, 58, 237, 0.30);
        }

        .customer-nav-links {
            display: flex;
            align-items: center;
            gap: 6px;
            margin-left: auto;
        }

        .customer-nav-link {
            padding: 9px 12px;
            border-radius: 9px;
            color: #94a3b8;
            text-decoration: none;
            font-size: 12px;
            font-weight: 700;
            transition: 0.2s ease;
        }

        .customer-nav-link:hover,
        .customer-nav-link.active {
            color: #ffffff;
            background: rgba(255, 255, 255, 0.06);
        }

        .customer-profile {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-left: 10px;
        }

        .customer-avatar {
            width: 37px;
            height: 37px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: linear-gradient(135deg, #8b5cf6, #3b82f6);
            font-size: 13px;
            font-weight: 800;
        }

        .customer-profile-name {
            max-width: 130px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            font-size: 12px;
            font-weight: 700;
        }

        .customer-logout {
            padding: 8px 12px;
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.10);
            color: #cbd5e1;
            background: rgba(255, 255, 255, 0.04);
            text-decoration: none;
            font-size: 11px;
            font-weight: 700;
        }

        .customer-logout:hover {
            color: #fca5a5;
            border-color: rgba(239, 68, 68, 0.30);
        }

        /*
           HEADER
         */
        .rentals-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 25px;
            margin-bottom: 28px;
        }

        .rentals-badge {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            margin-bottom: 13px;
            padding: 7px 11px;
            border-radius: 999px;
            color: #c4b5fd;
            background: rgba(124, 58, 237, 0.10);
            border: 1px solid rgba(139, 92, 246, 0.22);
            font-size: 10px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.6px;
        }

        .rentals-title {
            margin: 0;
            font-size: clamp(32px, 4vw, 48px);
            letter-spacing: -1.7px;
        }

        .rentals-description {
            margin: 9px 0 0;
            color: #94a3b8;
            line-height: 1.7;
            font-size: 14px;
        }

        .browse-button {
            min-height: 45px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 7px;
            padding: 0 17px;
            border-radius: 10px;
            color: #ffffff;
            text-decoration: none;
            font-size: 12px;
            font-weight: 750;
            background: linear-gradient(135deg, #6d28d9, #8b5cf6);
            box-shadow: 0 12px 30px rgba(124, 58, 237, 0.22);
            transition: 0.2s ease;
        }

        .browse-button:hover {
            transform: translateY(-2px);
        }

        /*
           STATISTICS
         */
        .rental-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 28px;
        }

        .rental-stat-card {
            position: relative;
            overflow: hidden;
            padding: 21px;
            border-radius: 17px;
            background: rgba(23, 33, 54, 0.76);
            border: 1px solid rgba(148, 163, 184, 0.10);
        }

        .rental-stat-card::after {
            content: "";
            position: absolute;
            width: 100px;
            height: 100px;
            right: -45px;
            bottom: -50px;
            border-radius: 50%;
            background: rgba(124, 58, 237, 0.12);
        }

        .rental-stat-icon {
            margin-bottom: 15px;
            font-size: 22px;
        }

        .rental-stat-value {
            margin-bottom: 5px;
            font-size: 27px;
            font-weight: 850;
        }

        .rental-stat-label {
            color: #94a3b8;
            font-size: 11px;
        }

        .total-stat {
            color: #a78bfa;
        }

        .active-stat {
            color: #facc15;
        }

        .returned-stat {
            color: #4ade80;
        }

        /*  SECTION HEADER */


        .rental-section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 15px;
            margin: 35px 0 17px;
        }

        .rental-section-header h2 {
            margin: 0;
            font-size: 21px;
        }

        .rental-section-header p {
            margin: 5px 0 0;
            color: #64748b;
            font-size: 12px;
        }

        /*  RENTAL CARDS */


        .rental-list {
            display: grid;
            gap: 15px;
        }

        .rental-card {
            display: grid;
            grid-template-columns: 90px minmax(190px, 1.2fr) repeat(3, minmax(125px, 0.7fr)) minmax(140px, 0.8fr);
            gap: 18px;
            align-items: center;
            padding: 17px;
            border-radius: 18px;
            background: rgba(23, 33, 54, 0.72);
            border: 1px solid rgba(148, 163, 184, 0.10);
            transition: transform 0.22s ease, border-color 0.22s ease;
        }

        .rental-card:hover {
            transform: translateY(-2px);
            border-color: rgba(139, 92, 246, 0.28);
        }

        /*  POSTER  */

        .rental-poster {
            width: 72px;
            height: 105px;
            overflow: hidden;
            border-radius: 11px;
            background: #111827;
            border: 1px solid rgba(255, 255, 255, 0.07);
            box-shadow: 0 8px 22px rgba(0, 0, 0, 0.26);
        }

        .rental-poster img {
            width: 100%;
            height: 100%;
            display: block;
            object-fit: cover;
        }

        /*  MOVIE */

        .rental-movie-name {
            margin-bottom: 6px;
            font-size: 16px;
            font-weight: 800;
        }

        .rental-movie-meta {
            color: #64748b;
            font-size: 11px;
            line-height: 1.7;
        }

        .rental-id {
            display: inline-flex;
            margin-top: 8px;
            padding: 4px 7px;
            border-radius: 7px;
            background: rgba(255, 255, 255, 0.04);
            color: #94a3b8;
            font-size: 10px;
        }

        /* DETAIL CELL */


        .rental-detail-label {
            display: block;
            margin-bottom: 6px;
            color: #64748b;
            font-size: 9px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.7px;
        }

        .rental-detail-value {
            color: #e2e8f0;
            font-size: 12px;
            font-weight: 650;
        }

        /* STATUS */


        .rental-status {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 7px 10px;
            border-radius: 999px;
            font-size: 10px;
            font-weight: 800;
        }

        .rental-status.active {
            color: #fde68a;
            background: rgba(234, 179, 8, 0.10);
            border: 1px solid rgba(234, 179, 8, 0.20);
        }

        .rental-status.returned {
            color: #86efac;
            background: rgba(34, 197, 94, 0.10);
            border: 1px solid rgba(34, 197, 94, 0.20);
        }

        .status-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            background: currentColor;
        }

        /* ACTIONS */
        .rental-actions {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .rental-actions form {
            margin: 0;
        }

        .rental-action-button {
            width: 100%;
            min-height: 38px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            padding: 0 12px;
            border: 0;
            border-radius: 9px;
            cursor: pointer;
            text-decoration: none;
            font-size: 11px;
            font-weight: 750;
        }

        .return-button {
            color: #ffffff;
            background: linear-gradient(135deg, #7c3aed, #8b5cf6);
        }

        .review-button {
            color: #fef3c7;
            border: 1px solid rgba(234, 179, 8, 0.20);
            background: rgba(234, 179, 8, 0.08);
        }

        .completed-button {
            color: #86efac;
            background: rgba(34, 197, 94, 0.07);
            border: 1px solid rgba(34, 197, 94, 0.16);
        }

        /*  EMPTY */

        .rentals-empty {
            padding: 65px 25px;
            text-align: center;
            border-radius: 20px;
            border: 1px solid rgba(148, 163, 184, 0.10);
            background: rgba(23, 33, 54, 0.55);
        }

        .rentals-empty-icon {
            margin-bottom: 14px;
            font-size: 44px;
        }

        .rentals-empty h3 {
            margin: 0 0 9px;
            font-size: 20px;
        }

        .rentals-empty p {
            margin: 0 auto 20px;
            max-width: 420px;
            color: #94a3b8;
            font-size: 13px;
            line-height: 1.7;
        }

        /*  INFO BANNER */

        .rental-info-banner {
            display: flex;
            align-items: center;
            gap: 13px;
            margin-top: 28px;
            padding: 17px;
            border-radius: 14px;
            background: rgba(59, 130, 246, 0.06);
            border: 1px solid rgba(59, 130, 246, 0.14);
            color: #94a3b8;
            font-size: 12px;
            line-height: 1.6;
        }

        .rental-info-icon {
            width: 36px;
            height: 36px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            border-radius: 10px;
            background: rgba(59, 130, 246, 0.10);
        }

        /* FOOTER */

        .rentals-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.06);
            background: #04070e;
        }

        .rentals-footer-inner {
            width: 92%;
            max-width: 1380px;
            min-height: 75px;
            margin: 0 auto;
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: #475569;
            font-size: 10px;
        }

        /* RESPONSIVE */

        @media (max-width: 1100px) {
            .rental-card {
                grid-template-columns: 80px minmax(180px, 1fr) repeat(2, minmax(110px, 0.7fr)) minmax(130px, 0.7fr);
            }

            .return-date-column {
                display: none;
            }
        }

        @media (max-width: 850px) {
            .customer-nav-links {
                display: none;
            }

            .rental-stats {
                grid-template-columns: 1fr 1fr 1fr;
            }

            .rental-card {
                grid-template-columns: 75px 1fr 130px;
            }

            .rental-date-column,
            .return-date-column {
                display: none;
            }
        }

        @media (max-width: 650px) {
            .customer-profile-name {
                display: none;
            }

            .rentals-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .browse-button {
                width: 100%;
            }

            .rental-stats {
                grid-template-columns: 1fr;
            }

            .rental-card {
                grid-template-columns: 70px 1fr;
                gap: 14px;
            }

            .rental-status-column,
            .rental-actions {
                grid-column: 1 / -1;
            }

            .rental-actions {
                flex-direction: row;
            }

            .rental-actions > * {
                flex: 1;
            }

            .rentals-footer-inner {
                flex-direction: column;
                justify-content: center;
                gap: 5px;
                padding: 15px 0;
            }
        }
    </style>
</head>
<body>
<!-- NAVBAR-->

<header class="customer-navbar">
    <div class="customer-navbar-inner">
        <!-- BRAND -->
        <a href="<%= ctx %>/" class="customer-brand">
            <span class="customer-brand-icon">
                🎬
            </span>
            CineRent
        </a>

        <!-- NAVIGATION -->
        <nav class="customer-nav-links">
            <a href="<%= ctx %>/" class="customer-nav-link">
                Home
            </a>
            <a href="<%= ctx %>/catalog" class="customer-nav-link">
                Movies
            </a>
            <a href="<%= ctx %>/rentals" class="customer-nav-link active">
                My Rentals
            </a>
            <a href="<%= ctx %>/recently-watched" class="customer-nav-link">
                Recently Watched
            </a>
        </nav>

        <!-- USER -->
        <div class="customer-profile">
            <div class="customer-avatar">
                <%= HtmlUtil.escape(userInitial) %>
            </div>
            <span class="customer-profile-name">
                <%= HtmlUtil.escape(userName) %>
            </span>
            <a href="<%= ctx %>/logout" class="customer-logout">
                Logout
            </a>
        </div>
    </div>
</header>

<!--PAGE -->

<main class="rentals-page">
    <div class="rentals-container">
        <!-- HEADER -->

        <section class="rentals-header">
            <div>
                <div class="rentals-badge">
                    📀 Rental Library
                </div>
                <h1 class="rentals-title">
                    My Rentals
                </h1>
                <p class="rentals-description">
                    Manage your active rentals,
                    return movies and revisit titles
                    you've already watched.
                </p>
            </div>
            <a href="<%= ctx %>/catalog" class="browse-button">
                🎬 Browse More Movies
                <span>
                    →
                </span>
            </a>
        </section>

        <!--  STATS -->

        <section class="rental-stats">
            <!-- TOTAL -->
            <div class="rental-stat-card">
                <div class="rental-stat-icon">
                    🎞️
                </div>
                <div class="rental-stat-value total-stat">
                    <%= totalRentalCount %>
                </div>
                <div class="rental-stat-label">
                    Total Rentals
                </div>
            </div>

            <!-- ACTIVE -->
            <div class="rental-stat-card">
                <div class="rental-stat-icon">
                    ▶️
                </div>
                <div class="rental-stat-value active-stat">
                    <%= activeRentalCount %>
                </div>
                <div class="rental-stat-label">
                    Currently Rented
                </div>
            </div>

            <!-- RETURNED -->
            <div class="rental-stat-card">
                <div class="rental-stat-icon">
                    ✓
                </div>
                <div class="rental-stat-value returned-stat">
                    <%= returnedRentalCount %>
                </div>
                <div class="rental-stat-label">
                    Completed Rentals
                </div>
            </div>
        </section>

        <!--  LIST HEADER-->

        <div class="rental-section-header">
            <div>
                <h2>
                    Rental History
                </h2>
                <p>
                    Your active and completed
                    CineRent rentals.
                </p>
            </div>
        </div>

        <!--  EMPTY STATE -->

        <%
            if (rentals == null || rentals.isEmpty()) {
        %>
        <section class="rentals-empty">
            <div class="rentals-empty-icon">
                🎬
            </div>
            <h3>
                You haven't rented any movies yet.
            </h3>
            <p>
                Start exploring the CineRent catalogue
                and rent a movie you would like to watch.
            </p>
            <a href="<%= ctx %>/catalog" class="browse-button">
                Browse Movies
            </a>
        </section>
        <%
        } else {
        %>
        <!--  RENTAL LIST -->

        <section class="rental-list">
            <%
                for (Rental rental : rentals) {
                    Movie movie = null;

                    if (movieService != null && rental.getMovieId() != null) {
                        movie = movieService.getMovieById(rental.getMovieId());
                    }

                    boolean active = "RENTED".equalsIgnoreCase(rental.getStatus());
                    boolean returned = "RETURNED".equalsIgnoreCase(rental.getStatus());

                    String movieTitle = movie != null && movie.getTitle() != null
                            ? movie.getTitle()
                            : rental.getMovieId();

                    String movieGenre = movie != null && movie.getGenre() != null
                            ? movie.getGenre()
                            : "Movie";
            %>
            <article class="rental-card">

                <!--  POSTER -->

                <div class="rental-poster">
                    <img
                        src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(rental.getMovieId()) %>"
                        alt="<%= HtmlUtil.escape(movieTitle) %>"
                        loading="lazy"
                        onerror="this.onerror=null; this.src='<%= ctx %>/images/posters/default.svg';"
                    >
                </div>

                <!--  MOVIE -->

                <div>
                    <div class="rental-movie-name">
                        <%= HtmlUtil.escape(movieTitle) %>
                    </div>
                    <div class="rental-movie-meta">
                        <%= HtmlUtil.escape(movieGenre) %>
                        <%
                            if (movie != null) {
                        %>
                        •
                        <%= movie.getReleaseYear() %>
                        <%
                            }
                        %>
                    </div>
                    <span class="rental-id">
                        Rental:
                        <%= HtmlUtil.escape(rental.getRentalId()) %>
                    </span>
                </div>

                <!-- RENTAL DATE -->

                <div class="rental-date-column">
                    <span class="rental-detail-label">
                        Rental Date
                    </span>
                    <span class="rental-detail-value">
                        <%= HtmlUtil.escape(rental.getRentalDate()) %>
                    </span>
                </div>

                <!-- RETURN DATE -->

                <div class="return-date-column">
                    <span class="rental-detail-label">
                        Return Date
                    </span>
                    <span class="rental-detail-value">
                        <%
                            if (rental.getReturnDate() == null
                                    || rental.getReturnDate().trim().isEmpty()) {
                        %>
                        Not returned yet
                        <%
                        } else {
                        %>
                        <%= HtmlUtil.escape(rental.getReturnDate()) %>
                        <%
                            }
                        %>
                    </span>
                </div>

                <!--  STATUS -->

                <div class="rental-status-column">
                    <span class="rental-detail-label">
                        Status
                    </span>
                    <%
                        if (active) {
                    %>
                    <span class="rental-status active">
                        <span class="status-dot"></span>
                        RENTED
                    </span>
                    <%
                    } else {
                    %>
                    <span class="rental-status returned">
                        <span class="status-dot"></span>
                        RETURNED
                    </span>
                    <%
                        }
                    %>
                </div>

                <!--  ACTIONS -->

                <div class="rental-actions">
                    <%
                        if (active) {
                    %>
                    <!-- RETURN MOVIE -->
                    <form
                        method="post"
                        action="<%= ctx %>/rentals"
                        onsubmit="return confirm('Are you sure you want to return this movie?');"
                    >
                        <input type="hidden" name="action" value="return">
                        <input
                            type="hidden"
                            name="rentalId"
                            value="<%= HtmlUtil.escape(rental.getRentalId()) %>"
                        >
                        <button type="submit" class="rental-action-button return-button">
                            ↩ Return Movie
                        </button>
                    </form>
                    <%
                    } else if (returned) {
                    %>
                    <!-- REVIEW -->
                    <a
                        href="<%= ctx %>/reviews?movieId=<%= HtmlUtil.escape(rental.getMovieId()) %>"
                        class="rental-action-button review-button"
                    >
                        ⭐ Review Movie
                    </a>
                    <span class="rental-action-button completed-button">
                        ✓ Completed
                    </span>
                    <%
                        }
                    %>
                </div>
            </article>
            <%
                }
            %>
        </section>
        <%
            }
        %>

        <!-- INFO -->

        <div class="rental-info-banner">
            <div class="rental-info-icon">
                💡
            </div>
            <div>
                After returning a movie,
                it will automatically appear in
                <strong>Recently Watched</strong>
                and you will be able to leave a
                rating and review.
            </div>
        </div>
    </div>
</main>

<!-- FOOTER -->

<footer class="rentals-footer">
    <div class="rentals-footer-inner">
        <div>
            © 2026 CineRent
        </div>
        <div>
            Browse • Rent • Watch • Review
        </div>
    </div>
</footer>

<script src="<%= ctx %>/js/app.js" defer></script>
</body>
</html>

>>>>>>> origin/main
