<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    List<Movie> movies = (List<Movie>) request.getAttribute("movies");


    String selectedSort =(String)request.getAttribute("selectedSort");
    String error =request.getParameter("error" );

    String userName =(String)session.getAttribute("userName");

    String role =  (String)session.getAttribute("role" );

    if (  userName == null ||  role == null ) {

        response.sendRedirect( request.getContextPath()  + "/login");

        return;
    }

    if ( !"CUSTOMER".equalsIgnoreCase( role) ) {

        response.sendRedirect(request.getContextPath() + "/admin");

        return;
    }


    int movieCount =movies == null? 0  : movies.size();

%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Movie Catalogue | CineRent
    </title>


    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">

</head>


<body>


<!-- NAVBAR-->

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
                <%= HtmlUtil.escape(
                        userName
                ) %>

            </span>


            <a href="<%= request.getContextPath() %>/logout">

                Logout

            </a>


        </div>


    </div>

</nav>


<!--  MAIN -->

<main>


    <div class="container">


        <!-- PAGE HEADER -->

        <div class="page-header">


            <div>
                <div class="hero-badge">
                    🎥 Customer Catalogue
                </div>
                <h1 class="page-title">
                    Discover your next movie.
                </h1>
                <p class="page-description">

                    Browse available titles,
                    compare ratings and rent
                    your next movie from CineRent.

                </p>


            </div>


            <div class="catalog-summary">

                Showing

                <span class="catalog-count">

                    <%= movieCount %>

                </span>

                movie(s)

            </div>


        </div>


        <!-- ERRORS -->

        <%
            if ( "notfound".equalsIgnoreCase(error )) {

        %>
        <div class="alert alert-danger">
            The selected movie could not be found.
        </div>

        <%
        } else if ( "unavailable" .equalsIgnoreCase( error )) {
                                                                                                         %>
        <div class="alert alert-warning">
            This movie currently has no
            available copies.

        </div>


        <%
        } else if ( "alreadyrented" .equalsIgnoreCase(error) ) {
        %>

        <div class="alert alert-info">
            You already have this movie rented.
            Return it before renting it again.

        </div>

        <%
            }
        %>


        <!-- CATALOG TOOLBAR -->

        <div class="catalog-toolbar">
            <div class="catalog-sort">
                <span class="catalog-sort-label">Sort by:</span>

                <!-- DEFAULT -->
                <a href="<%= request.getContextPath() %>/catalog"
                class="catalog-sort-link
                                <%= selectedSort == null || selectedSort.trim().isEmpty()? "active": "" %>">

                                          Default

                                                         </a>
                <!-- HIGH TO LOW -->

                <a href="<%= request.getContextPath() %>/catalog?sort=rating-desc"
                   class="catalog-sort-link
                   <%= "rating-desc") ? "active": "" %>">

                    ⭐ Highest Rated

                </a>

                <!-- LOW TO HIGH -->

                <a href="<%= request.getContextPath() %>/catalog?sort=rating-asc"
                   class="catalog-sort-link
                   <%= "rating-asc" .equalsIgnoreCase( selectedSort ) ? "active" : "" %>">

                    ⭐ Lowest Rated

                </a>

            </div>

            <a href="<%= request.getContextPath() %>/rentals"
               class="btn btn-secondary">
                📀 View My Rentals
            </a>
        </div>

        <!-- EMPTY STAT -->

        <%
            if ( movies == null  || movies.isEmpty()) {
        %>
        <div class="card empty-state">
            <div class="empty-state-icon">
                🎬
            </div>
            <h3>
                No movies available
            </h3>
            <p>
                The CineRent catalogue is currently empty.
                Please check again later.
            </p>
        </div>

        <%
        } else {
        %>


        <!-- MOVIE GRID -->

        <div class="movie-grid">


            <%
                for (Movie movie :movies) {

                    boolean available =movie.getAvailableCopies()> 0;
            %>
            <article class="movie-card">

                <!-- POSTER -->
                <div class="movie-poster">
                    <span class="movie-id-badge">
                        <%= HtmlUtil.escape(
                                movie.getMovieId()) %>

                    </span>
                    <span class="movie-rating-badge">
                        ⭐
                        <%= movie.getRating() %>
                    </span>
                    🎞️
                </div>


                <!--BODY -->
                <div class="movie-card-body">
                    <h2 class="movie-title">
                        <%= HtmlUtil.escape(
                                movie.getTitle()) %>
                    </h2>

                    <div class="movie-meta">
                        <%= HtmlUtil.escape( movie.getGenre()) %>
                        •
                        <%= movie.getReleaseYear() %>
                    </div>

                    <div class="movie-description">
                        <%= HtmlUtil.escape movie.getDescription()) %>
                    </div>

                    <!--PRICE / AVAILABILITY-->
                    <div class="movie-information">
                        <div class="movie-price">
                            LKR
                            <%= String.format( "%.2f",movie.getRentalPrice() ) %>
                            <small>
                                / rental
                            </small>
                        </div>

                        <div class="movie-availability
                        <%= available  ? "available": "unavailable" %>">
                            <%
                                if (available) {
                            %>

                            ✓
                            <%= movie.getAvailableCopies() %>
                            available

                            <%
                            } else {
                            %>

                            ✕ Unavailable

                            <%
                                }
                            %>
                        </div>
                    </div>

                    <!-- ACTION -->

                    <div class="movie-actions">

                        <!-- REVIEWS -->

                        <a href="<%= request.getContextPath() %>/reviews?movieId=<%= HtmlUtil.escape(movie.getMovieId()) %>"
                           class="btn movie-review-btn">

                            ⭐ Reviews

                        </a>


                        <!-- RENT -->

                        <form method="post"
                              action="<%= request.getContextPath() %>/rentals">


                            <input type="hidden"name="action"value="rent">
                            <input type="hidden"name="movieId"value="<%= HtmlUtil.escape(movie.getMovieId()) %>">
                            <button type="submit" class="btn btn-primary"

                                   <%= available ? "" : "disabled" %>>
                                <%= available  ? "Rent Movie": "Unavailable" %>
                            </button>
                        </form>
                    </div>
                </div>
            </article>
            <%
                }
            %>
        </div>

        <%
            }
        %>
    </div>
</main>


<!--FOOTER -->

<footer class="footer">
    <div class="container footer-inner">
        <div>
            © 2026 CineRent
        </div>
        <div>
            Browse • Rent • Watch • Review
        </div>
    </div>
</footer>
</body>
</html>