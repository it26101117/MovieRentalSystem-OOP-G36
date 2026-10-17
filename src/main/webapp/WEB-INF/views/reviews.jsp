<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    Movie movie =
            (Movie)
                    request.getAttribute(
                            "movie"
                    );

    List<Review> reviews =
            (List<Review>)
                    request.getAttribute(
                            "reviews"
                    );

    Review userReview =
            (Review)
                    request.getAttribute(
                            "userReview"
                    );

    Boolean canReviewObject =
            (Boolean)
                    request.getAttribute(
                            "canReview"
                    );

    boolean canReview =
            Boolean.TRUE.equals(
                    canReviewObject
            );

    String ctx =
            request.getContextPath();

    String success =
            request.getParameter(
                    "success"
            );

    String error =
            request.getParameter(
                    "error"
            );
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
        Reviews | CineRent
    </title>

    <link
        rel="stylesheet"
        href="<%= ctx %>/css/style.css"
    >

</head>


<body>


<jsp:include
    page="/WEB-INF/views/partials/customer-nav.jsp"
/>


<main class="page">

    <div class="container">


        <div class="page-header">

            <div>

                <h1 class="page-title">
                    Reviews
                </h1>

                <p class="page-description">
                    Read and share your thoughts.
                </p>

            </div>

        </div>


        <% if ("saved".equals(success)) { %>

        <div
            class="alert alert-success"
            data-auto-hide
        >
            Your review has been saved.
        </div>

        <% } %>


        <% if ("deleted".equals(success)) { %>

        <div
            class="alert alert-success"
            data-auto-hide
        >
            Your review has been deleted.
        </div>

        <% } %>


        <% if (error != null) { %>

        <div class="alert alert-danger">
            Unable to save the review.
            Please check your rating and comment.
        </div>

        <% } %>


        <div class="review-hero">


            <section
                class="card review-movie-card"
            >

                <div class="review-movie-layout">


                    <img
                        class="review-poster"
                        src="<%= ctx %>/images/posters/<%= movie.getMovieId() %>.jpg"
                        alt="<%= HtmlUtil.escape(movie.getTitle()) %>"
                        onerror="
                            this.onerror=null;
                            this.src='<%= ctx %>/images/posters/default.svg';
                        "
                    >


                    <div>

                        <h2>
                            <%= HtmlUtil.escape(
                                    movie.getTitle()
                            ) %>
                        </h2>

                        <div class="movie-meta">

                            <%= movie.getReleaseYear() %>

                            ·

                            <span class="stars">
                                ★
                                <%= String.format(
                                        "%.1f",
                                        movie.getRating()
                                ) %>
                            </span>

                        </div>


                        <p>
                            <%= HtmlUtil.escape(
                                    movie.getDescription()
                            ) %>
                        </p>


                        <span class="badge badge-primary">
                            <%= HtmlUtil.escape(
                                    movie.getGenre()
                            ) %>
                        </span>

                    </div>

                </div>

            </section>


            <section
                class="card review-form-card"
            >

                <h3>
                    Write a Review
                </h3>


                <% if (canReview) { %>


                <form
                    action="<%= ctx %>/reviews"
                    method="post"
                >

                    <input
                        type="hidden"
                        name="action"
                        value="save"
                    >

                    <input
                        type="hidden"
                        name="movieId"
                        value="<%= movie.getMovieId() %>"
                    >


                    <div class="form-group">

                        <label class="form-label">
                            Rating
                        </label>

                        <select
                            class="form-control"
                            name="rating"
                            required
                        >

                            <option value="">
                                Select rating
                            </option>

                            <% for (
                                    int i = 5;
                                    i >= 1;
                                    i--
                            ) { %>

                            <option
                                value="<%= i %>"
                                <%= userReview != null
                                        &&
                                        userReview.getRating() == i
                                        ? "selected"
                                        : "" %>
                            >
                                <%= i %>
                                Star<%= i > 1 ? "s" : "" %>
                            </option>

                            <% } %>

                        </select>

                    </div>


                    <div class="form-group">

                        <label class="form-label">
                            Your Review
                        </label>

                        <textarea
                            class="form-control"
                            name="comment"
                            maxlength="500"
                            required
                            placeholder="Share your thoughts about this movie..."
                        ><%= userReview != null
                                ? HtmlUtil.escape(
                                        userReview.getComment()
                                )
                                : "" %></textarea>

                    </div>


                    <button
                        class="btn btn-primary btn-full"
                        type="submit"
                    >
                        <%= userReview == null
                                ? "Submit Review"
                                : "Update Review" %>
                    </button>

                </form>


                <% if (userReview != null) { %>


                <form
                    action="<%= ctx %>/reviews"
                    method="post"
                    data-confirm="Delete your review?"
                    style="margin-top:9px;"
                >

                    <input
                        type="hidden"
                        name="action"
                        value="delete"
                    >

                    <input
                        type="hidden"
                        name="movieId"
                        value="<%= movie.getMovieId() %>"
                    >

                    <button
                        class="btn btn-outline-danger btn-full"
                        type="submit"
                    >
                        Delete Review
                    </button>

                </form>


                <% } %>


                <% } else { %>


                <div class="alert alert-info">

                    Rent and return this movie before
                    submitting a review.

                </div>


                <% } %>


            </section>

        </div>


        <section>

            <h3 class="content-section-title">
                Customer Reviews
            </h3>


            <% if (
                    reviews == null
                    ||
                    reviews.isEmpty()
            ) { %>


            <div class="card empty-state">

                <p>
                    No customer reviews yet.
                </p>

            </div>


            <% } else { %>


            <div class="review-list">


                <% for (
                        Review review : reviews
                ) { %>


                <article class="review-card">


                    <div class="review-header">


                        <div class="review-user">

                            <span class="avatar">
                                C
                            </span>

                            Customer
                            <%= HtmlUtil.escape(
                                    review.getUserId()
                            ) %>

                        </div>


                        <span class="review-date">
                            <%= review.getReviewDate() %>
                        </span>

                    </div>


                    <div class="stars">

                        <% for (
                                int star = 1;
                                star <= 5;
                                star++
                        ) { %>

                            <%= star <= review.getRating()
                                    ? "★"
                                    : "☆" %>

                        <% } %>

                    </div>


                    <p class="review-comment">

                        <%= HtmlUtil.escape(
                                review.getComment()
                        ) %>

                    </p>

                </article>


                <% } %>


            </div>


            <% } %>

        </section>

    </div>

</main>


<script
    src="<%= ctx %>/js/app.js"
    defer
></script>


</body>

</html>