<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.model.Movie" %>

<%
    Movie movie =
            (Movie) request.getAttribute("movie");

    boolean isEdit = movie != null;

    String formAction =
            isEdit ? "update" : "add";

    String title =
            isEdit ? movie.getTitle() : "";

    String genre =
            isEdit ? movie.getGenre() : "";

    String releaseYear =
            isEdit
                    ? String.valueOf(movie.getReleaseYear())
                    : "";

    String rentalPrice =
            isEdit
                    ? String.valueOf(movie.getRentalPrice())
                    : "";

    String rating =
            isEdit
                    ? String.valueOf(movie.getRating())
                    : "";

    String availableCopies =
            isEdit
                    ? String.valueOf(movie.getAvailableCopies())
                    : "";

    String description =
            isEdit
                    ? movie.getDescription()
                    : "";
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        <%= isEdit ? "Edit Movie" : "Add Movie" %>
        | CineRent
    </title>

    <style>

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, Helvetica, sans-serif;
            background: #0f172a;
            color: white;
        }

        .container {
            width: 90%;
            max-width: 700px;
            margin: 50px auto;
        }

        .card {
            background: #1e293b;
            padding: 35px;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.25);
        }

        h1 {
            margin-top: 0;
            margin-bottom: 10px;
        }

        .subtitle {
            color: #94a3b8;
            margin-bottom: 25px;
        }

        label {
            display: block;
            margin-top: 17px;
            margin-bottom: 7px;
            font-weight: bold;
        }

        input,
        textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #475569;
            background: #0f172a;
            color: white;
            border-radius: 6px;
            font-size: 15px;
        }

        input:focus,
        textarea:focus {
            outline: none;
            border-color: #3b82f6;
        }

        textarea {
            resize: vertical;
            min-height: 120px;
        }

        .row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .save-button {
            background: #2563eb;
            color: white;
            border: none;
            padding: 13px 22px;
            margin-top: 25px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: bold;
            font-size: 15px;
        }

        .save-button:hover {
            background: #1d4ed8;
        }

        .back-link {
            display: inline-block;
            margin-top: 20px;
            color: #60a5fa;
            text-decoration: none;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .mode-label {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            background: #334155;
            color: #cbd5e1;
            font-size: 13px;
            margin-bottom: 15px;
        }

        @media (max-width: 600px) {

            .row {
                grid-template-columns: 1fr;
            }

            .card {
                padding: 25px;
            }
        }

    </style>

</head>

<body>

<div class="container">

    <div class="card">

        <div class="mode-label">

            <%= isEdit
                    ? "EDIT MODE"
                    : "NEW MOVIE" %>

        </div>

        <h1>

            <%= isEdit
                    ? "✏️ Edit Movie"
                    : "🎬 Add Movie" %>

        </h1>

        <p class="subtitle">

            <%= isEdit
                    ? "Update the selected movie information."
                    : "Add a new movie to the CineRent collection." %>

        </p>


        <form method="post"
              action="<%= request.getContextPath() %>/movies">

            <!-- Determines which servlet action to run -->
            <input type="hidden"
                   name="action"
                   value="<%= formAction %>">


            <%
                if (isEdit) {
            %>

            <input type="hidden"
                   name="movieId"
                   value="<%= movie.getMovieId() %>">

            <%
                }
            %>


            <label>
                Movie Title
            </label>

            <input type="text"
                   name="title"
                   value="<%= title %>"
                   placeholder="Example: Interstellar"
                   required>


            <label>
                Genre
            </label>

            <input type="text"
                   name="genre"
                   value="<%= genre %>"
                   placeholder="Example: Sci-Fi"
                   required>


            <div class="row">

                <div>

                    <label>
                        Release Year
                    </label>

                    <input type="number"
                           name="releaseYear"
                           value="<%= releaseYear %>"
                           min="1900"
                           max="2100"
                           placeholder="2014"
                           required>

                </div>


                <div>

                    <label>
                        Rental Price
                    </label>

                    <input type="number"
                           name="rentalPrice"
                           value="<%= rentalPrice %>"
                           step="0.01"
                           min="0"
                           placeholder="500.00"
                           required>

                </div>

            </div>


            <div class="row">

                <div>

                    <label>
                        Rating
                    </label>

                    <input type="number"
                           name="rating"
                           value="<%= rating %>"
                           step="0.1"
                           min="0"
                           max="5"
                           placeholder="4.8"
                           required>

                </div>


                <div>

                    <label>
                        Available Copies
                    </label>

                    <input type="number"
                           name="availableCopies"
                           value="<%= availableCopies %>"
                           min="0"
                           placeholder="5"
                           required>

                </div>

            </div>


            <label>
                Description
            </label>

            <textarea name="description"
                      placeholder="Enter movie description..."
                      required><%= description %></textarea>


            <button type="submit"
                    class="save-button">

                <%= isEdit
                        ? "Update Movie"
                        : "Add Movie" %>

            </button>

        </form>


        <a class="back-link"
           href="<%= request.getContextPath() %>/movies">

            ← Back to Movie Management

        </a>

    </div>

</div>

</body>

</html>