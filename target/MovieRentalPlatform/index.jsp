<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String userName =
            (String) session.getAttribute(
                    "userName"
            );

    String role =
            (String) session.getAttribute(
                    "role"
            );

    boolean loggedIn =
            userName != null
                    &&
                    role != null;

    boolean isAdmin =
            loggedIn
                    &&
                    "ADMIN".equalsIgnoreCase(
                            role
                    );

    boolean isCustomer =
            loggedIn
                    &&
                    "CUSTOMER".equalsIgnoreCase(
                            role
                    );
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        CineRent | Movie Rental & Review Platform
    </title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">

</head>


<body>


<!-- =========================================================
     NAVIGATION
========================================================= -->

<nav class="navbar">

    <div class="container navbar-inner">


        <a href="<%= request.getContextPath() %>/"
           class="brand">

            <span class="brand-icon">
                🎬
            </span>

            CineRent

        </a>


        <div class="nav-links">


            <%
                if (isCustomer) {
            %>


            <a href="<%= request.getContextPath() %>/catalog">

                Movies

            </a>


            <a href="<%= request.getContextPath() %>/rentals">

                My Rentals

            </a>


            <a href="<%= request.getContextPath() %>/recently-watched">

                Recently Watched

            </a>


            <span class="nav-user">

                Hi,
                <%= userName %>

            </span>


            <a href="<%= request.getContextPath() %>/logout">

                Logout

            </a>


            <%
            } else if (isAdmin) {
            %>


            <a href="<%= request.getContextPath() %>/admin">

                Dashboard

            </a>


            <a href="<%= request.getContextPath() %>/movies">

                Movies

            </a>


            <a href="<%= request.getContextPath() %>/admin/customers">

                Customers

            </a>


            <a href="<%= request.getContextPath() %>/admin/rentals">

                Rentals

            </a>


            <a href="<%= request.getContextPath() %>/admin/reviews">

                Reviews

            </a>


            <a href="<%= request.getContextPath() %>/logout">

                Logout

            </a>


            <%
            } else {
            %>


            <a href="#features">

                Features

            </a>


            <a href="<%= request.getContextPath() %>/login">

                Login

            </a>


            <a href="<%= request.getContextPath() %>/register"
               class="btn btn-primary">

                Create Account

            </a>


            <%
                }
            %>


        </div>


    </div>

</nav>


<!-- =========================================================
     HERO
========================================================= -->

<section class="hero">

    <div class="container hero-grid">


        <div>


            <div class="hero-badge">

                🎥 Movie Rental & Review Platform

            </div>


            <h1>

                Rent.

                <br>

                Watch.

                <br>

                <span>
                    Review.
                </span>

            </h1>


            <p class="hero-description">

                Discover movies, manage your rentals,
                keep track of recently watched titles
                and share your ratings with CineRent.

            </p>


            <div class="hero-actions">


                <%
                    if (isCustomer) {
                %>


                <a href="<%= request.getContextPath() %>/catalog"
                   class="btn btn-primary">

                    Browse Movies →

                </a>


                <a href="<%= request.getContextPath() %>/rentals"
                   class="btn btn-secondary">

                    My Rentals

                </a>


                <%
                } else if (isAdmin) {
                %>


                <a href="<%= request.getContextPath() %>/admin"
                   class="btn btn-primary">

                    Open Admin Dashboard →

                </a>


                <a href="<%= request.getContextPath() %>/movies"
                   class="btn btn-secondary">

                    Manage Movies

                </a>


                <%
                } else {
                %>


                <a href="<%= request.getContextPath() %>/register"
                   class="btn btn-primary">

                    Get Started →

                </a>


                <a href="<%= request.getContextPath() %>/login"
                   class="btn btn-secondary">

                    Sign In

                </a>


                <%
                    }
                %>


            </div>


        </div>


        <!-- =================================================
             HERO MOVIE CARD
        ================================================== -->

        <div class="hero-visual">


            <div class="hero-card">


                <div class="poster-placeholder">

                    🎞️

                </div>


                <div class="hero-card-title">

                    Discover Your Next Movie

                </div>


                <div class="hero-card-meta">

                    Browse • Rent • Return • Review

                </div>


                <div class="hero-card-footer">


                    <span class="badge badge-warning">

                        ⭐ Top Rated

                    </span>


                    <span class="text-muted">

                        CineRent

                    </span>


                </div>


            </div>


        </div>


    </div>

</section>


<!-- =========================================================
     FEATURES
========================================================= -->

<section id="features"
         class="section">

    <div class="container">


        <div class="section-header">


            <h2 class="section-title">

                Everything you need
                for movie rentals.

            </h2>


            <p class="section-description">

                CineRent combines rental management,
                customer reviews and movie discovery
                in one simple platform.

            </p>


        </div>


        <div class="feature-grid">


            <!-- MOVIES -->

            <div class="feature-card">


                <div class="feature-icon">

                    🎬

                </div>


                <h3>

                    Movie Catalogue

                </h3>


                <p>

                    Browse available movies,
                    prices, ratings, genres and
                    available copies.

                </p>


            </div>


            <!-- RENTAL -->

            <div class="feature-card">


                <div class="feature-icon">

                    📀

                </div>


                <h3>

                    Easy Rentals

                </h3>


                <p>

                    Rent and return movies
                    while keeping a complete
                    rental history.

                </p>


            </div>


            <!-- RECENTLY WATCHED -->

            <div class="feature-card">


                <div class="feature-icon">

                    🕘

                </div>


                <h3>

                    Recently Watched

                </h3>


                <p>

                    Keep track of watched movies
                    using CineRent's custom
                    Stack data structure.

                </p>


            </div>


            <!-- REVIEWS -->

            <div class="feature-card">


                <div class="feature-icon">

                    ⭐

                </div>


                <h3>

                    Ratings & Reviews

                </h3>


                <p>

                    Share your experience after
                    completing a movie rental
                    and help other customers.

                </p>


            </div>


        </div>


    </div>

</section>


<!-- =========================================================
     CTA
========================================================= -->

<section class="section">

    <div class="container">


        <div class="card"
             style="
                text-align:center;
                padding:55px 25px;
             ">


            <h2 style="
                font-size:34px;
                margin-top:0;
            ">

                Ready for your next movie?

            </h2>


            <p class="text-muted"
               style="
                    max-width:600px;
                    margin:0 auto 25px;
                    line-height:1.7;
               ">

                Create your CineRent account,
                browse the catalogue and start
                building your movie history.

            </p>


            <%
                if (!loggedIn) {
            %>


            <a href="<%= request.getContextPath() %>/register"
               class="btn btn-primary">

                Create Free Account

            </a>


            <%
            } else if (isCustomer) {
            %>


            <a href="<%= request.getContextPath() %>/catalog"
               class="btn btn-primary">

                Browse Catalogue

            </a>


            <%
            } else {
            %>


            <a href="<%= request.getContextPath() %>/admin"
               class="btn btn-primary">

                Open Dashboard

            </a>


            <%
                }
            %>


        </div>


    </div>

</section>


<!-- =========================================================
     FOOTER
========================================================= -->

<footer class="footer">

    <div class="container footer-inner">


        <div>

            © 2026 CineRent

        </div>


        <div>

            Movie Rental & Review Platform

        </div>


    </div>

</footer>


</body>

</html>