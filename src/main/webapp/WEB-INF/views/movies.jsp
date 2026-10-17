<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>Movie Management | CineRent</title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #0f172a;
            color: #ffffff;
        }

        .container {
            width: 92%;
            max-width: 1200px;
            margin: 50px auto;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        h1 {
            margin: 0;
        }

        p {
            color: #94a3b8;
        }

        .add-button {
            display: inline-block;
            background: #2563eb;
            color: white;
            padding: 12px 20px;
            text-decoration: none;
            border-radius: 7px;
            font-weight: bold;
        }

        .add-button:hover {
            background: #1d4ed8;
        }

        .table-wrapper {
            overflow-x: auto;
            background: #1e293b;
            border-radius: 10px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th,
        td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #334155;
        }

        th {
            background: #334155;
            color: #f8fafc;
        }

        tr:hover {
            background: #273449;
        }

        .edit-button {
            display: inline-block;
            color: #60a5fa;
            text-decoration: none;
            margin-right: 10px;
        }

        .edit-button:hover {
            text-decoration: underline;
        }

        .delete-form {
            display: inline;
        }

        .delete-button {
            background: #dc2626;
            color: white;
            padding: 7px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
        }

        .delete-button:hover {
            background: #b91c1c;
        }

        .empty {
            text-align: center;
            padding: 35px;
            color: #94a3b8;
        }

        .home-link {
            display: inline-block;
            margin-top: 25px;
            color: #60a5fa;
            text-decoration: none;
        }

        .home-link:hover {
            text-decoration: underline;
        }

        .rating {
            color: #facc15;
        }

    </style>

</head>

<body>

<div class="container">

    <div class="header">

        <div>

            <h1>
                🎬 Movie Management
            </h1>

            <p>
                Manage movies available on CineRent.
            </p>

        </div>

        <a class="add-button"
           href="<%= request.getContextPath() %>/movies?action=add">

            + Add Movie

        </a>

    </div>


    <div class="table-wrapper">

        <table>

            <thead>

            <tr>

                <th>ID</th>
                <th>Movie</th>
                <th>Genre</th>
                <th>Year</th>
                <th>Price</th>
                <th>Rating</th>
                <th>Copies</th>
                <th>Actions</th>

            </tr>

            </thead>


            <tbody>

            <%

                List<Movie> movies =
                        (List<Movie>) request.getAttribute("movies");

                if (movies == null || movies.isEmpty()) {

            %>

            <tr>

                <td colspan="8"
                    class="empty">

                    No movies available.
                    Add your first movie.

                </td>

            </tr>

            <%

            } else {

                for (Movie movie : movies) {

            %>

            <tr>

                <td>
                    <%= movie.getMovieId() %>
                </td>

                <td>
                    <%= movie.getTitle() %>
                </td>

                <td>
                    <%= movie.getGenre() %>
                </td>

                <td>
                    <%= movie.getReleaseYear() %>
                </td>

                <td>
                    LKR <%= movie.getRentalPrice() %>
                </td>

                <td class="rating">
                    ⭐ <%= movie.getRating() %>
                </td>

                <td>
                    <%= movie.getAvailableCopies() %>
                </td>

                <td>

                    <a class="edit-button"
                       href="<%= request.getContextPath() %>/movies?action=edit&id=<%= movie.getMovieId() %>">

                        Edit

                    </a>


                    <form class="delete-form"
                          method="post"
                          action="<%= request.getContextPath() %>/movies">

                        <input type="hidden"
                               name="action"
                               value="delete">

                        <input type="hidden"
                               name="movieId"
                               value="<%= movie.getMovieId() %>">

                        <button type="submit"
                                class="delete-button"
                                onclick="return confirm('Are you sure you want to delete this movie?');">

                            Delete

                        </button>

                    </form>

                </td>

            </tr>

            <%

                    }
                }

            %>

            </tbody>

        </table>

    </div>


    <a class="home-link"
       href="<%= request.getContextPath() %>/">

        ← Back to Home

    </a>

</div>

</body>

</html>