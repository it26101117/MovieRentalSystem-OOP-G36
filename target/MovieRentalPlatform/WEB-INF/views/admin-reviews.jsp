<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.model.User" %>
<%@ page import="com.movierental.model.Movie" %>

<%
    String adminName =
            (String) session.getAttribute(
                    "userName"
            );


    String role =
            (String) session.getAttribute(
                    "role"
            );


    if (
            adminName == null
                    ||
                    role == null
                    ||
                    !"ADMIN".equalsIgnoreCase(role)
    ) {

        response.sendRedirect(
                request.getContextPath()
                        + "/login"
        );

        return;
    }


    List<Review> reviews =
            (List<Review>)
                    request.getAttribute(
                            "reviews"
                    );


    Map<String, User> userMap =
            (Map<String, User>)
                    request.getAttribute(
                            "userMap"
                    );


    Map<String, Movie> movieMap =
            (Map<String, Movie>)
                    request.getAttribute(
                            "movieMap"
                    );


    String search =
            (String)
                    request.getAttribute(
                            "search"
                    );


    String selectedRating =
            (String)
                    request.getAttribute(
                            "selectedRating"
                    );


    Integer totalReviewCount =
            (Integer)
                    request.getAttribute(
                            "totalReviewCount"
                    );


    Integer filteredCount =
            (Integer)
                    request.getAttribute(
                            "filteredCount"
                    );


    Integer fiveStarCount =
            (Integer)
                    request.getAttribute(
                            "fiveStarCount"
                    );


    Integer fourStarCount =
            (Integer)
                    request.getAttribute(
                            "fourStarCount"
                    );


    Integer threeStarCount =
            (Integer)
                    request.getAttribute(
                            "threeStarCount"
                    );


    Integer twoStarCount =
            (Integer)
                    request.getAttribute(
                            "twoStarCount"
                    );


    Integer oneStarCount =
            (Integer)
                    request.getAttribute(
                            "oneStarCount"
                    );


    if (search == null) {
        search = "";
    }


    if (selectedRating == null) {
        selectedRating = "all";
    }


    if (totalReviewCount == null) {
        totalReviewCount = 0;
    }


    if (filteredCount == null) {
        filteredCount = 0;
    }


    if (fiveStarCount == null) {
        fiveStarCount = 0;
    }


    if (fourStarCount == null) {
        fourStarCount = 0;
    }


    if (threeStarCount == null) {
        threeStarCount = 0;
    }


    if (twoStarCount == null) {
        twoStarCount = 0;
    }


    if (oneStarCount == null) {
        oneStarCount = 0;
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Review Management | CineRent
    </title>


    <style>

        * {
            box-sizing: border-box;
        }


        body {
            margin: 0;

            font-family:
                    Arial,
                    Helvetica,
                    sans-serif;

            background: #0f172a;

            color: white;
        }


        .container {
            width: 94%;

            max-width: 1400px;

            margin: 40px auto;
        }


        /* HEADER */

        .header {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            margin-bottom: 30px;
        }


        .header h1 {
            margin: 0;
        }


        .subtitle {
            color: #94a3b8;

            margin-top: 8px;
        }


        .nav {
            display: flex;

            gap: 16px;

            flex-wrap: wrap;
        }


        .nav a {
            color: #60a5fa;

            text-decoration: none;
        }


        .nav a:hover {
            text-decoration: underline;
        }


        .logout {
            color: #f87171 !important;
        }


        /* STATISTICS */

        .statistics {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(150px, 1fr)
                    );

            gap: 15px;

            margin-bottom: 28px;
        }


        .stat-card {
            background: #1e293b;

            padding: 20px;

            border-radius: 10px;
        }


        .stat-number {
            font-size: 28px;

            font-weight: bold;

            margin-bottom: 6px;
        }


        .stat-label {
            color: #94a3b8;

            font-size: 13px;
        }


        .stars {
            color: #facc15;
        }


        /* FILTER */

        .filter-box {
            background: #1e293b;

            padding: 20px;

            border-radius: 11px;

            margin-bottom: 25px;
        }


        .filter-form {
            display: flex;

            gap: 10px;

            flex-wrap: wrap;

            align-items: center;
        }


        .search-input {
            flex: 1;

            min-width: 260px;

            background: #0f172a;

            color: white;

            border: 1px solid #475569;

            border-radius: 7px;

            padding: 12px 14px;
        }


        .rating-select {
            min-width: 170px;

            background: #0f172a;

            color: white;

            border: 1px solid #475569;

            border-radius: 7px;

            padding: 12px;
        }


        .filter-button {
            background: #2563eb;

            color: white;

            border: none;

            padding: 12px 20px;

            border-radius: 7px;

            cursor: pointer;

            font-weight: bold;
        }


        .clear-button {
            background: #475569;

            color: white;

            padding: 12px 18px;

            border-radius: 7px;

            text-decoration: none;
        }


        /* TABLE */

        .result-info {
            color: #94a3b8;

            font-size: 14px;

            margin-bottom: 14px;
        }


        .result-info strong {
            color: white;
        }


        .table-wrapper {
            background: #1e293b;

            border-radius: 12px;

            overflow-x: auto;
        }


        table {
            width: 100%;

            min-width: 1150px;

            border-collapse: collapse;
        }


        th {
            background: #172033;

            color: #94a3b8;

            padding: 15px;

            text-align: left;

            text-transform: uppercase;

            font-size: 12px;
        }


        td {
            padding: 16px 15px;

            border-top: 1px solid #334155;

            vertical-align: top;
        }


        tr:hover {
            background: #263449;
        }


        .review-id {
            color: #60a5fa;

            font-weight: bold;
        }


        .movie-title {
            font-weight: bold;
        }


        .sub-text {
            color: #94a3b8;

            font-size: 12px;

            margin-top: 4px;
        }


        .rating {
            color: #facc15;

            font-weight: bold;

            white-space: nowrap;
        }


        .comment {
            color: #cbd5e1;

            line-height: 1.5;

            max-width: 350px;

            word-wrap: break-word;
        }


        /* DELETE */

        .delete-button {
            background: #dc2626;

            color: white;

            border: none;

            padding: 8px 12px;

            border-radius: 6px;

            cursor: pointer;

            font-weight: bold;
        }


        .delete-button:hover {
            background: #b91c1c;
        }


        .empty {
            padding: 45px;

            text-align: center;

            color: #94a3b8;
        }


        @media (max-width: 700px) {

            .header {
                flex-direction: column;

                align-items: flex-start;
            }


            .filter-form {
                flex-direction: column;

                align-items: stretch;
            }


            .search-input {
                min-width: 100%;
            }

        }

    </style>

</head>


<body>

<div class="container">


    <!-- HEADER -->

    <div class="header">

        <div>

            <h1>
                ⭐ Review Management
            </h1>

            <p class="subtitle">
                Monitor customer ratings,
                comments and movie reviews.
            </p>

        </div>


        <div class="nav">

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

            <a href="<%= request.getContextPath() %>/logout"
               class="logout">
                Logout
            </a>

        </div>

    </div>


    <!-- STATISTICS -->

    <div class="statistics">


        <div class="stat-card">

            <div class="stat-number">
                <%= totalReviewCount %>
            </div>

            <div class="stat-label">
                Total Reviews
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-number stars">
                <%= fiveStarCount %>
            </div>

            <div class="stat-label">
                ⭐⭐⭐⭐⭐ Reviews
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-number stars">
                <%= fourStarCount %>
            </div>

            <div class="stat-label">
                ⭐⭐⭐⭐ Reviews
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-number">
                <%= threeStarCount %>
            </div>

            <div class="stat-label">
                ⭐⭐⭐ Reviews
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-number">
                <%= twoStarCount + oneStarCount %>
            </div>

            <div class="stat-label">
                Low Rated Reviews
            </div>

        </div>


    </div>


    <!-- FILTER -->

    <div class="filter-box">

        <form method="get"
              action="<%= request.getContextPath() %>/admin/reviews"
              class="filter-form">


            <input type="text"
                   name="search"
                   class="search-input"
                   value="<%= search %>"
                   placeholder="Search customer, movie, review ID or comment">


            <select name="rating"
                    class="rating-select">


                <option value="all"
                        <%= "all".equalsIgnoreCase(selectedRating)
                                ? "selected"
                                : "" %>>

                    All Ratings

                </option>


                <option value="5"
                        <%= "5".equals(selectedRating)
                                ? "selected"
                                : "" %>>

                    ⭐⭐⭐⭐⭐ 5 Stars

                </option>


                <option value="4"
                        <%= "4".equals(selectedRating)
                                ? "selected"
                                : "" %>>

                    ⭐⭐⭐⭐ 4 Stars

                </option>


                <option value="3"
                        <%= "3".equals(selectedRating)
                                ? "selected"
                                : "" %>>

                    ⭐⭐⭐ 3 Stars

                </option>


                <option value="2"
                        <%= "2".equals(selectedRating)
                                ? "selected"
                                : "" %>>

                    ⭐⭐ 2 Stars

                </option>


                <option value="1"
                        <%= "1".equals(selectedRating)
                                ? "selected"
                                : "" %>>

                    ⭐ 1 Star

                </option>

            </select>


            <button type="submit"
                    class="filter-button">

                Filter

            </button>


            <a href="<%= request.getContextPath() %>/admin/reviews"
               class="clear-button">

                Clear

            </a>

        </form>

    </div>


    <div class="result-info">

        Showing

        <strong>
            <%= filteredCount %>
        </strong>

        review(s).

    </div>


    <!-- REVIEW TABLE -->

    <div class="table-wrapper">


        <%
            if (
                    reviews == null
                            ||
                            reviews.isEmpty()
            ) {
        %>


        <div class="empty">

            <h3>
                No Reviews Found
            </h3>

            <p>
                No reviews match the current
                search or rating filter.
            </p>

        </div>


        <%
        } else {
        %>


        <table>

            <thead>

            <tr>

                <th>Review ID</th>

                <th>Customer</th>

                <th>Movie</th>

                <th>Rating</th>

                <th>Comment</th>

                <th>Date</th>

                <th>Action</th>

            </tr>

            </thead>


            <tbody>


            <%
                for (Review review : reviews) {

                    User customer =
                            userMap != null
                                    ? userMap.get(
                                    review.getUserId()
                            )
                                    : null;


                    Movie movie =
                            movieMap != null
                                    ? movieMap.get(
                                    review.getMovieId()
                            )
                                    : null;
            %>


            <tr>


                <td class="review-id">

                    <%= review.getReviewId() %>

                </td>


                <!-- CUSTOMER -->

                <td>

                    <%
                        if (customer != null) {
                    %>

                    <strong>
                        <%= customer.getName() %>
                    </strong>

                    <div class="sub-text">

                        <%= customer.getUserId() %>

                        •

                        <%= customer.getEmail() %>

                    </div>

                    <%
                    } else {
                    %>

                    Unknown Customer

                    <div class="sub-text">
                        <%= review.getUserId() %>
                    </div>

                    <%
                        }
                    %>

                </td>


                <!-- MOVIE -->

                <td>

                    <%
                        if (movie != null) {
                    %>

                    <div class="movie-title">

                        <%= movie.getTitle() %>

                    </div>

                    <div class="sub-text">

                        <%= movie.getMovieId() %>

                    </div>

                    <%
                    } else {
                    %>

                    Unknown Movie

                    <div class="sub-text">

                        <%= review.getMovieId() %>

                    </div>

                    <%
                        }
                    %>

                </td>


                <!-- RATING -->

                <td>

                    <span class="rating">

                        ⭐
                        <%= review.getRating() %>
                        / 5

                    </span>

                </td>


                <!-- COMMENT -->

                <td>

                    <div class="comment">

                        <%= review.getComment() %>

                    </div>

                </td>


                <!-- DATE -->

                <td>

                    <%= review.getReviewDate() %>

                </td>


                <!-- DELETE -->

                <td>

                    <form method="post"
                          action="<%= request.getContextPath() %>/admin/reviews">


                        <input type="hidden"
                               name="action"
                               value="delete">


                        <input type="hidden"
                               name="reviewId"
                               value="<%= review.getReviewId() %>">


                        <button type="submit"
                                class="delete-button"
                                onclick="return confirm('Are you sure you want to delete this review?');">

                            Delete

                        </button>

                    </form>

                </td>


            </tr>


            <%
                }
            %>


            </tbody>

        </table>


        <%
            }
        %>


    </div>


</div>

</body>

</html>