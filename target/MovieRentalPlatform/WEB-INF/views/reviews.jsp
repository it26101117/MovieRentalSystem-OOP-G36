
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx = request.getContextPath();

    Movie movie =
            (Movie) request.getAttribute("movie");

    List<Review> reviews =
            (List<Review>) request.getAttribute("reviews");

    Review userReview =
            (Review) request.getAttribute("userReview");

    boolean canReview = Boolean.TRUE.equals(
            request.getAttribute("canReview")
    );

    String token = (String)
            request.getAttribute("reviewCsrfToken");

    String success = request.getParameter("success");
    String error = request.getParameter("error");

    if (movie == null) {
        response.sendRedirect(ctx + "/catalog");
        return;
    }

    String movieIdEncoded = URLEncoder.encode(
            movie.getMovieId(),
            StandardCharsets.UTF_8
    );

    int reviewCount = reviews == null ? 0 : reviews.size();
%>

<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <title>
        <%= HtmlUtil.escape(movie.getTitle()) %>
        Reviews | CineRent
    </title>

    <style>
        :root {
            --bg: #060914;
            --card: #121b2e;
            --border: #26334b;
            --text: #f8fafc;
            --muted: #94a3b8;
            --accent: #8b5cf6;
            --blue: #60a5fa;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            background:
                    radial-gradient(
                            circle at 85% 4%,
                            rgba(124, 58, 237, .13),
                            transparent 30%
                    ),
                    var(--bg);
            color: var(--text);
            font-family: Inter, "Segoe UI", Arial, sans-serif;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .container {
            max-width: 1450px;
            margin: auto;
            padding: 32px 27px 80px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 32px;
        }

        .page-header h1 {
            font-size: clamp(30px, 4vw, 46px);
            letter-spacing: -1.5px;
            margin: 0 0 15px;
        }

        .page-header p {
            font-size: 13px;
            color: var(--muted);
            margin: 0;
        }

        .back-button {
            padding: 14px 17px;
            border-radius: 11px;
            background: #1d1934;
            border: 1px solid #392f54;
            font-size: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .review-hero {
            display: grid;
            grid-template-columns: 1.65fr 1fr;
            gap: 20px;
            align-items: stretch;
            margin-bottom: 45px;
        }

        .card {
            background: linear-gradient(145deg, #172239, #101729);
            border: 1px solid #26324a;
            border-radius: 22px;
            padding: 22px;
            min-width: 0;
        }

        .movie-layout {
            display: grid;
            grid-template-columns: 250px minmax(0, 1fr);
            gap: 35px;
            align-items: center;
        }

        .poster {
            width: 100%;
            height: 380px;
            object-fit: cover;
            border-radius: 8px;
            background: #1b2740;
        }

        .movie-id {
            display: inline-block;
            padding: 7px 9px;
            border-radius: 7px;
            background: #202d47;
            color: #93c5fd;
            font-size: 10px;
            font-weight: 800;
            margin-bottom: 22px;
        }

        .movie-title {
            margin: 0 0 20px;
            font-size: 38px;
            letter-spacing: -1px;
        }

        .movie-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
            font-size: 12px;
            color: var(--muted);
        }

        .stars {
            color: #facc15;
            font-weight: 800;
        }

        .genre {
            display: inline-block;
            margin-top: 24px;
            padding: 9px 12px;
            border-radius: 20px;
            border: 1px solid #4c3488;
            background: #291f4b;
            color: #c4b5fd;
            font-size: 11px;
            font-weight: 700;
        }

        .movie-description {
            margin-top: 22px;
            color: #b3c4e0;
            font-size: 13px;
            line-height: 1.85;
            max-height: 132px;
            overflow: auto;
        }

        .form-card h2 {
            font-size: 21px;
            margin: 10px 0;
        }

        .form-subtitle {
            font-size: 12px;
            color: var(--muted);
            margin-bottom: 24px;
            line-height: 1.7;
        }

        .form-group {
            margin-bottom: 22px;
        }

        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 750;
            margin-bottom: 10px;
        }

        .input-control {
            width: 100%;
            background: #0e1729;
            border: 1px solid #33435e;
            border-radius: 11px;
            padding: 13px;
            color: white;
            font: inherit;
            font-size: 13px;
            outline: none;
        }

        .input-control:focus {
            border-color: var(--accent);
            box-shadow: 0 0 0 3px rgba(139, 92, 246, .12);
        }

        textarea.input-control {
            min-height: 145px;
            resize: vertical;
            line-height: 1.7;
        }

        .hint {
            color: var(--muted);
            font-size: 11px;
            margin-top: 8px;
        }

        .submit-button {
            width: 100%;
            border: 0;
            padding: 15px;
            border-radius: 11px;
            color: white;
            background: linear-gradient(120deg, #6d28d9, #8b5cf6);
            font-size: 13px;
            font-weight: 800;
            cursor: pointer;
        }

        .submit-button:hover {
            filter: brightness(1.15);
        }

        .delete-button {
            width: 100%;
            background: transparent;
            color: #fca5a5;
            border: 1px solid #7f3647;
            border-radius: 11px;
            padding: 13px;
            margin-top: 12px;
            font-weight: 750;
            cursor: pointer;
        }

        .notice {
            border: 1px solid #29436b;
            background: #192744;
            border-radius: 13px;
            padding: 17px;
            color: #bfdbfe;
            font-size: 12px;
            line-height: 1.8;
        }

        .notice a {
            display: inline-block;
            color: #93c5fd;
            font-weight: 800;
            margin-top: 12px;
        }

        .alert {
            padding: 16px;
            border-radius: 11px;
            font-size: 13px;
            margin-bottom: 20px;
            line-height: 1.6;
        }

        .alert-success {
            background: rgba(34, 197, 94, .11);
            border: 1px solid #246e45;
            color: #86efac;
        }

        .alert-error {
            background: rgba(239, 68, 68, .11);
            border: 1px solid #853c49;
            color: #fecaca;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            gap: 20px;
        }

        .section-heading h2 {
            font-size: 22px;
            margin: 0;
        }

        .count-badge {
            border-radius: 20px;
            background: #201839;
            color: #c4b5fd;
            padding: 9px 13px;
            font-size: 11px;
            font-weight: 800;
        }

        .review-list {
            display: grid;
            gap: 16px;
        }

        .review-item {
            background: #121b2e;
            border: 1px solid #26334b;
            border-radius: 16px;
            padding: 22px;
        }

        .review-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 14px;
        }

        .review-user {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
            font-weight: 750;
        }

        .review-avatar {
            width: 37px;
            height: 37px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            background: #343063;
            color: #ddd6fe;
        }

        .review-date {
            font-size: 12px;
            color: var(--muted);
        }

        .review-comment {
            color: #c4d0e4;
            font-size: 13px;
            line-height: 1.8;
            white-space: pre-wrap;
            overflow-wrap: anywhere;
        }

        .empty {
            text-align: center;
            padding: 45px 20px;
            border: 1px dashed #344360;
            background: #11192c;
            border-radius: 16px;
            color: var(--muted);
        }

        @media(max-width: 1050px) {
            .review-hero {
                grid-template-columns: 1fr;
            }
        }

        @media(max-width: 650px) {
            .container {
                padding: 22px 15px 50px;
            }

            .page-header {
                align-items: flex-start;
                flex-direction: column;
            }

            .movie-layout {
                grid-template-columns: 1fr;
            }

            .poster {
                max-width: 250px;
                height: 360px;
            }

            .movie-title {
                font-size: 30px;
            }

            .card {
                padding: 18px;
            }
        }
    </style>

</head>

<body>

<main class="container">

    <!-- PAGE HEADING -->

    <div class="page-header">

        <div>
            <h1>Movie Reviews</h1>
            <p>
                Read what other customers think and
                share your own movie experience.
            </p>
        </div>

        <a class="back-button"
           href="<%= ctx %>/catalog">
            ← Back to Movies
        </a>

    </div>

    <!-- STATUS MESSAGES -->

    <% if ("saved".equals(success)) { %>
    <div class="alert alert-success">
        ✓ Your review has been saved successfully.
    </div>
    <% } %>

    <% if ("deleted".equals(success)) { %>
    <div class="alert alert-success">
        ✓ Your review has been deleted.
    </div>
    <% } %>

    <% if (error != null) { %>
    <div class="alert alert-error">

        <% if ("noteligible".equals(error)) { %>
        Return this movie before submitting a review.
        <% } else if ("rating".equals(error)) { %>
        Please select a rating from 1 to 5.
        <% } else if ("comment".equals(error)) { %>
        Enter a valid comment (maximum 500 characters).
        <% } else { %>
        Unable to process your review.
        <% } %>

    </div>
    <% } %>

    <div class="review-hero">

        <!-- MOVIE DETAILS -->

        <section class="card">

            <div class="movie-layout">

                <img
                        class="poster"
                        src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(movieIdEncoded) %>"
                        alt="<%= HtmlUtil.escape(movie.getTitle()) %>"
                        onerror="
                                this.onerror=null;
                                this.src='<%= ctx %>/images/posters/default.svg';
                                "
                >

                <div>

                    <span class="movie-id">
                        Movie ID:
                        <%= HtmlUtil.escape(movie.getMovieId()) %>
                    </span>

                    <h2 class="movie-title">
                        <%= HtmlUtil.escape(movie.getTitle()) %>
                    </h2>

                    <div class="movie-meta">

                        <span>
                            <%= movie.getReleaseYear() %>
                        </span>

                        <span>•</span>

                        <span class="stars">
                            ★
                            <%= String.format(
                                    java.util.Locale.US,
                                    "%.1f",
                                    movie.getRating()
                            ) %>
                        </span>

                        <span>•</span>

                        <span>
                            <%= reviewCount %> review(s)
                        </span>

                    </div>

                    <span class="genre">
                        <%= HtmlUtil.escape(movie.getGenre()) %>
                    </span>

                    <p class="movie-description">

                        <%
                            if (movie.getDescription() == null ||
                                    movie.getDescription().isEmpty()) {
                        %>

                        No description available.

                        <% } else { %>

                        <%= HtmlUtil.escape(
                                movie.getDescription()
                        ) %>

                        <% } %>

                    </p>

                </div>

            </div>

        </section>

        <!-- REVIEW FORM -->

        <section class="card form-card">

            <h2>
                <%= userReview == null
                        ? "Write a Review"
                        : "Edit Your Review"
                %>
            </h2>

            <p class="form-subtitle">
                Share your opinion and help other
                customers discover great movies.
            </p>

            <% if (canReview) { %>

            <form
                    method="post"
                    action="<%= ctx %>/reviews"
            >

                <input
                        type="hidden"
                        name="action"
                        value="save"
                >

                <input
                        type="hidden"
                        name="movieId"
                        value="<%= HtmlUtil.escape(movie.getMovieId()) %>"
                >

                <input
                        type="hidden"
                        name="csrfToken"
                        value="<%= HtmlUtil.escape(token) %>"
                >

                <div class="form-group">

                    <label for="rating">
                        Your Rating
                    </label>

                    <select
                            class="input-control"
                            id="rating"
                            name="rating"
                            required
                    >

                        <option value="">
                            Select a rating
                        </option>

                        <% for (int i = 5; i >= 1; i--) { %>

                        <option
                                value="<%= i %>"
                                <%= userReview != null &&
                                        userReview.getRating() == i
                                        ? "selected" : "" %>
                        >
                            <%= i %> Star<%= i == 1 ? "" : "s" %>
                        </option>

                        <% } %>

                    </select>

                </div>

                <div class="form-group">

                    <label for="comment">
                        Your Review
                    </label>

                    <textarea
                            class="input-control"
                            id="comment"
                            name="comment"
                            maxlength="500"
                            required
                            placeholder="What did you think about this movie?"
                    ><%= userReview != null
                            ? HtmlUtil.escape(userReview.getComment())
                            : "" %></textarea>

                    <div class="hint">
                        Maximum 500 characters
                    </div>

                </div>

                <button
                        type="submit"
                        class="submit-button"
                >
                    <%= userReview == null
                            ? "★ Submit Review"
                            : "✓ Update Review"
                    %>
                </button>

            </form>

            <% if (userReview != null) { %>

            <form
                    method="post"
                    action="<%= ctx %>/reviews"
                    onsubmit="return confirm('Delete your review?');"
            >

                <input type="hidden"
                       name="action"
                       value="delete">

                <input type="hidden"
                       name="movieId"
                       value="<%= HtmlUtil.escape(movie.getMovieId()) %>">

                <input type="hidden"
                       name="csrfToken"
                       value="<%= HtmlUtil.escape(token) %>">

                <button
                        type="submit"
                        class="delete-button"
                >
                    Delete My Review
                </button>

            </form>

            <% } %>

            <% } else { %>

            <div class="notice">

                🔒 You need to rent and return
                this movie before submitting a review.

                <div>
                    <a href="<%= ctx %>/catalog">
                        Browse Movies →
                    </a>

                    <a href="<%= ctx %>/rentals"
                       style="margin-left:15px;">
                        My Rentals →
                    </a>
                </div>

            </div>

            <% } %>

        </section>

    </div>

    <!-- CUSTOMER REVIEWS -->

    <section>

        <div class="section-heading">

            <h2>Customer Reviews</h2>

            <span class="count-badge">
                <%= reviewCount %> Reviews
            </span>

        </div>

        <% if (reviews == null || reviews.isEmpty()) { %>

        <div class="empty">

            <h3>No Reviews Yet</h3>

            <p>
                Be the first eligible customer
                to review this movie.
            </p>

        </div>

        <% } else { %>

        <div class="review-list">

            <% for (Review review : reviews) {

                if (review == null) {
                    continue;
                }
            %>

            <article class="review-item">

                <div class="review-top">

                    <div class="review-user">

                            <span class="review-avatar">
                                C
                            </span>

                        <span>
                                Customer
                                <%= HtmlUtil.escape(
                                        review.getUserId()
                                ) %>
                            </span>

                    </div>

                    <span class="review-date">
                            <%= HtmlUtil.escape(
                                    String.valueOf(
                                            review.getReviewDate()
                                    )
                            ) %>
                        </span>

                </div>

                <div class="stars">

                    <% for (int star = 1; star <= 5; star++) { %>

                    <%= star <= review.getRating()
                            ? "★" : "☆" %>

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

</main>

</body>
</html>
