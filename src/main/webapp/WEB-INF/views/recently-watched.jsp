<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>

<%
    List<Movie> movies = (List<Movie>)request.getAttribute("recentlyWatched");

    Movie latestMovie =(Movie)request.getAttribute("latestMovie");
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Recently Watched | CineRent
    </title>


    <style>

        * {box-sizing: border-box;}

        body {margin: 0;font-family:
                    Arial,
                    Helvetica,
                    sans-serif;

            background: #0f172a;

            color: white;
        }

        .container {width: 92%; max-width: 1100px;  margin: 50px auto;}

        .header {
            display: flex;

            justify-content:
                    space-between;

            align-items: center;

            margin-bottom: 30px;
        }

        .subtitle {
            color: #94a3b8;
        }

        .nav a {
            color: #60a5fa;

            text-decoration: none;

            margin-left: 15px;
        }

        .latest {
            background: #1e293b;

            padding: 25px;

            border-radius: 12px;

            margin-bottom: 30px;

            border-left:
                    5px solid #2563eb;
        }

        .latest-label {
            color: #60a5fa;

            font-size: 13px;

            font-weight: bold;

            text-transform: uppercase;
        }

        .movies {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(230px, 1fr)
                    );

            gap: 20px;
        }

        .movie-card {
            background: #1e293b;

            padding: 25px;

            border-radius: 12px;
        }

        .genre {
            color: #94a3b8;
        }

        .rating {
            color: #facc15;
        }

        .position {
            color: #60a5fa;

            font-size: 13px;

            font-weight: bold;
        }

        .empty {
            background: #1e293b;

            color: #94a3b8;

            padding: 30px;

            text-align: center;

            border-radius: 12px;
        }

    </style>

</head>


<body>

<div class="container">


    <div class="header">

        <div>

            <h1>
                🕘 Recently Watched
            </h1>

            <p class="subtitle">
                Your latest watched movies
                using the CineRent Stack.
            </p>

        </div>


        <div class="nav">

            <a href="<%= request.getContextPath() %>/catalog">
                Browse Movies
            </a>

            <a href="<%= request.getContextPath() %>/rentals">
                My Rentals
            </a>

            <a href="<%= request.getContextPath() %>/logout">
                Logout
            </a>

        </div>

    </div>


    <%
        if (latestMovie != null) {
    %>

    <div class="latest">

        <div class="latest-label">
            Stack Top / Latest Watched
        </div>

        <h2>
            🎬 <%= latestMovie.getTitle() %>
        </h2>

        <p>
            <%= latestMovie.getGenre() %>
            •
            <%= latestMovie.getReleaseYear() %>
        </p>

        <p class="rating">
            ⭐ <%= latestMovie.getRating() %>
        </p>

    </div>

    <%
        }
    %>


    <%
        if (movies == null || movies.isEmpty()) {
    %>

    <div class="empty">

        You haven't watched any movies yet.

        <br><br>

        Rent a movie and return it
        to add it to your recently
        watched Stack.

    </div>

    <%
    } else {
    %>


    <div class="movies">


        <%
            int position = 1;

            for (Movie movie : movies) {
        %>


        <div class="movie-card">

            <div class="position">

                #<%= position %>
                Recently Watched

            </div>


            <h2>
                <%= movie.getTitle() %>
            </h2>


            <p class="genre">

                <%= movie.getGenre() %>

                •

                <%= movie.getReleaseYear() %>

            </p>


            <p class="rating">

                ⭐ <%= movie.getRating() %>

            </p>


            <p>

                <%= movie.getDescription() %>

            </p>

        </div>


        <% position++;}
        %>


    </div>


    <%
        }
    %>


</div>

</body>

</html>