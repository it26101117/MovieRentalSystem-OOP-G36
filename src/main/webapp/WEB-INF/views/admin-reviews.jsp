<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.model.User" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
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

    String ctx =
            request.getContextPath();
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1"
    >

    <title>
        Reviews | CineRent Admin
    </title>

    <link
        rel="stylesheet"
        href="<%= ctx %>/css/style.css"
    >

</head>


<body>


<jsp:include
    page="/WEB-INF/views/partials/admin-nav.jsp"
/>


<main class="page">

    <div class="container">


        <div class="page-header">

            <div>

                <h1 class="page-title">
                    Reviews
                </h1>

                <p class="page-description">
                    Manage customer reviews.
                </p>

            </div>

        </div>


        <div class="review-stats">


            <div class="review-stat">

                <div class="review-stat-label">
                    Total Reviews
                </div>

                <div class="review-stat-value">
                    <%= totalReviewCount == null
                            ? 0
                            : totalReviewCount %>
                </div>

            </div>


            <div class="review-stat">

                <div class="review-stat-label">
                    ★★★★★
                </div>

                <div class="review-stat-value">
                    <%= fiveStarCount == null
                            ? 0
                            : fiveStarCount %>
                </div>

            </div>


            <div class="review-stat">

                <div class="review-stat-label">
                    ★★★★
                </div>

                <div class="review-stat-value">
                    <%= fourStarCount == null
                            ? 0
                            : fourStarCount %>
                </div>

            </div>


            <div class="review-stat">

                <div class="review-stat-label">
                    ★★★
                </div>

                <div class="review-stat-value">
                    <%= threeStarCount == null
                            ? 0
                            : threeStarCount %>
                </div>

            </div>


            <div class="review-stat">

                <div class="review-stat-label">
                    ★★
                </div>

                <div class="review-stat-value">
                    <%= twoStarCount == null
                            ? 0
                            : twoStarCount %>
                </div>

            </div>


            <div class="review-stat">

                <div class="review-stat-label">
                    ★
                </div>

                <div class="review-stat-value">
                    <%= oneStarCount == null
                            ? 0
                            : oneStarCount %>
                </div>

            </div>

        </div>


        <form
            action="<%= ctx %>/admin/reviews"
            method="get"
            class="admin-toolbar"
        >


            <div class="search-box">

                <span class="search-icon">
                    ⌕
                </span>

                <input
                    class="form-control"
                    type="search"
                    name="search"
                    value="<%= HtmlUtil.escape(search) %>"
                    placeholder="Search reviews..."
                >

            </div>


            <select
                class="form-control review-rating-select"
                name="rating"
            >

                <option
                    value="all"
                    <%= "all".equals(selectedRating)
                            ? "selected"
                            : "" %>
                >
                    All Ratings
                </option>

                <% for (
                        int i = 5;
                        i >= 1;
                        i--
                ) { %>

                <option
                    value="<%= i %>"
                    <%= String.valueOf(i)
                            .equals(selectedRating)
                            ? "selected"
                            : "" %>
                >
                    <%= i %> Stars
                </option>

                <% } %>

            </select>


            <button
                class="btn btn-primary"
                type="submit"
            >
                Filter
            </button>

        </form>


        <div class="table-wrapper">

            <table>

                <thead>

                <tr>
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
                    if (reviews != null) {

                        for (
                                Review review : reviews
                        ) {

                            User user =
                                    userMap == null
                                            ? null
                                            : userMap.get(
                                                review.getUserId()
                                            );

                            Movie movie =
                                    movieMap == null
                                            ? null
                                            : movieMap.get(
                                                review.getMovieId()
                                            );
                %>


                <tr>

                    <td>

                        <div class="table-title">

                            <%= user != null
                                    ? HtmlUtil.escape(
                                            user.getName()
                                    )
                                    : review.getUserId()
                            %>

                        </div>

                    </td>


                    <td>

                        <%= movie != null
                                ? HtmlUtil.escape(
                                        movie.getTitle()
                                )
                                : review.getMovieId()
                        %>

                    </td>


                    <td class="stars">

                        <% for (
                                int star = 1;
                                star <= 5;
                                star++
                        ) { %>

                            <%= star <= review.getRating()
                                    ? "★"
                                    : "☆" %>

                        <% } %>

                    </td>


                    <td>

                        <%= HtmlUtil.escape(
                                review.getComment()
                        ) %>

                    </td>


                    <td>
                        <%= review.getReviewDate() %>
                    </td>


                    <td>

                        <form
                            action="<%= ctx %>/admin/reviews"
                            method="post"
                            data-confirm="Delete this review?"
                        >

                            <input
                                type="hidden"
                                name="action"
                                value="delete"
                            >

                            <input
                                type="hidden"
                                name="reviewId"
                                value="<%= review.getReviewId() %>"
                            >

                            <button
                                class="btn btn-danger btn-sm"
                                type="submit"
                            >
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

    </div>

</main>


<script
    src="<%= ctx %>/js/app.js"
    defer
></script>


</body>

</html>