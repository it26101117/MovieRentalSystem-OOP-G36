<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Rental" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.service.MovieService" %>

<%
    List<Rental> rentals =
            (List<Rental>) request.getAttribute("rentals");

    MovieService movieService =
            (MovieService) request.getAttribute("movieService");
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <title>
        My Rentals | CineRent
    </title>

    <style>

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: #0f172a;
            color: white;
        }

        .container {
            width: 92%;
            max-width: 1100px;
            margin: 50px auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: #1e293b;
        }

        th,
        td {
            padding: 14px;
            border-bottom: 1px solid #334155;
            text-align: left;
        }

        th {
            background: #334155;
        }

        .return-button {
            background: #16a34a;
            border: none;
            color: white;
            padding: 8px 13px;
            border-radius: 5px;
            cursor: pointer;
        }

        a {
            color: #60a5fa;
            text-decoration: none;
        }

        .status-rented {
            color: #facc15;
        }

        .status-returned {
            color: #4ade80;
        }

    </style>

</head>

<body>

<div class="container">

    <h1>
        📀 My Rentals
    </h1>

    <p>
        <a href="<%= request.getContextPath() %>/catalog">
            ← Browse Movies
        </a>
    </p>

    <table>

        <thead>

        <tr>
            <th>Rental ID</th>
            <th>Movie</th>
            <th>Rental Date</th>
            <th>Return Date</th>
            <th>Status</th>
            <th>Action</th>
        </tr>

        </thead>

        <tbody>

        <%
            if (
                    rentals == null
                            ||
                            rentals.isEmpty()
            ) {
        %>

        <tr>

            <td colspan="6">

                You haven't rented any movies yet.

            </td>

        </tr>

        <%
        } else {

            for (Rental rental : rentals) {

                Movie movie =
                        movieService.getMovieById(
                                rental.getMovieId()
                        );

                String movieTitle =
                        movie != null
                                ? movie.getTitle()
                                : rental.getMovieId();
        %>

        <tr>

            <td>
                <%= rental.getRentalId() %>
            </td>

            <td>
                <%= movieTitle %>
            </td>

            <td>
                <%= rental.getRentalDate() %>
            </td>

            <td>

                <%= rental.getReturnDate()
                        == null
                        ||
                        rental.getReturnDate().isEmpty()
                        ? "-"
                        : rental.getReturnDate() %>

            </td>

            <td>

                <span class="<%= "RENTED".equalsIgnoreCase(
                        rental.getStatus()
                )
                        ? "status-rented"
                        : "status-returned" %>">

                    <%= rental.getStatus() %>

                </span>

            </td>

            <td>

                <%
                    if (
                            "RENTED".equalsIgnoreCase(
                                    rental.getStatus()
                            )
                    ) {
                %>

                <form method="post"
                      action="<%= request.getContextPath() %>/rentals">

                    <input type="hidden"
                           name="action"
                           value="return">

                    <input type="hidden"
                           name="rentalId"
                           value="<%= rental.getRentalId() %>">

                    <button type="submit"
                            class="return-button">

                        Return Movie

                    </button>

                </form>

                <%
                } else {
                %>

                Completed

                <%
                    }
                %>

            </td>

        </tr>

        <%
                }
            }
        %>

        </tbody>

    </table>

</div>

</body>

</html>