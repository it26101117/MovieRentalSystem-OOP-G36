<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    // =========================================================
    // SESSION / ACCESS CHECK
    // =========================================================

    String userName =
            (String) session.getAttribute(
                    "userName"
            );


    String role =
            (String) session.getAttribute(
                    "role"
            );


    String loggedUserId =
            (String) session.getAttribute(
                    "userId"
            );


    if (
            userName == null
                    ||
                    role == null
                    ||
                    loggedUserId == null
                    ||
                    !"CUSTOMER".equalsIgnoreCase(role)
    ) {

        response.sendRedirect(
                request.getContextPath()
                        + "/login"
        );

        return;
    }


    // =========================================================
    // GET DATA FROM SERVLET
    // =========================================================

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
            canReviewObject != null
                    &&
                    canReviewObject;


    // =========================================================
    // URL MESSAGES
    // =========================================================

    String error =
            request.getParameter(
                    "error"
            );


    String success =
            request.getParameter(
                    "success"
            );


    // =========================================================
    // SAFETY CHECK
    // =========================================================

    if (movie == null) {

        response.sendRedirect(
                request.getContextPath()
                        + "/catalog"
        );

        return;
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Reviews | CineRent
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


        /* =====================================================
           CONTAINER
        ====================================================== */

        .container {
            width: 92%;

            max-width: 1050px;

            margin: 45px auto;
        }


        /* =====================================================
           TOP NAVIGATION
        ====================================================== */

        .top-nav {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            margin-bottom: 25px;

            flex-wrap: wrap;
        }


        .nav-links {
            display: flex;

            gap: 16px;

            flex-wrap: wrap;
        }


        .nav-links a,
        .back {
            color: #60a5fa;

            text-decoration: none;

            font-weight: bold;

            font-size: 14px;
        }


        .nav-links a:hover,
        .back:hover {
            text-decoration: underline;
        }


        .logout {
            color: #f87171 !important;
        }


        /* =====================================================
           MOVIE HEADER
        ====================================================== */

        .movie-header {
            background: #1e293b;

            padding: 26px;

            border-radius: 12px;

            margin-bottom: 25px;

            box-shadow:
                    0 8px 25px
                    rgba(0, 0, 0, 0.18);
        }


        .movie-header h1 {
            margin-top: 0;

            margin-bottom: 10px;
        }


        .movie-meta {
            color: #94a3b8;

            margin-bottom: 12px;
        }


        .movie-rating {
            color: #facc15;

            font-weight: bold;

            font-size: 18px;

            margin-bottom: 10px;
        }


        .movie-description {
            color: #cbd5e1;

            line-height: 1.6;
        }


        /* =====================================================
           MESSAGES
        ====================================================== */

        .message {
            padding: 14px 18px;

            border-radius: 8px;

            margin-bottom: 20px;

            line-height: 1.5;
        }


        .error-message {
            background: #7f1d1d;

            color: #fecaca;
        }


        .success-message {
            background: #14532d;

            color: #86efac;
        }


        .info-message {
            background: #1e3a5f;

            color: #bfdbfe;
        }


        /* =====================================================
           REVIEW FORM
        ====================================================== */

        .review-form-box {
            background: #1e293b;

            padding: 26px;

            border-radius: 12px;

            margin-bottom: 35px;
        }


        .review-form-box h2 {
            margin-top: 0;

            margin-bottom: 5px;
        }


        .form-description {
            color: #94a3b8;

            margin-top: 0;

            margin-bottom: 20px;

            font-size: 14px;
        }


        label {
            display: block;

            margin-top: 15px;

            margin-bottom: 7px;

            font-weight: bold;
        }


        select,
        textarea {
            width: 100%;

            padding: 12px;

            background: #0f172a;

            color: white;

            border: 1px solid #475569;

            border-radius: 7px;

            font-size: 14px;
        }


        select:focus,
        textarea:focus {
            outline: none;

            border-color: #3b82f6;
        }


        textarea {
            min-height: 130px;

            resize: vertical;
        }


        .character-info {
            color: #64748b;

            font-size: 12px;

            margin-top: 6px;
        }


        /* =====================================================
           BUTTONS
        ====================================================== */

        .button {
            margin-top: 20px;

            background: #2563eb;

            color: white;

            padding: 11px 20px;

            border: none;

            border-radius: 7px;

            cursor: pointer;

            font-size: 14px;

            font-weight: bold;
        }


        .button:hover {
            background: #1d4ed8;
        }


        .delete-button {
            margin-top: 12px;

            background: #dc2626;

            color: white;

            padding: 10px 16px;

            border: none;

            border-radius: 7px;

            cursor: pointer;

            font-weight: bold;
        }


        .delete-button:hover {
            background: #b91c1c;
        }


        /* =====================================================
           CUSTOMER REVIEWS
        ====================================================== */

        .reviews-heading {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 15px;

            margin-bottom: 18px;
        }


        .reviews-heading h2 {
            margin: 0;
        }


        .review-count {
            background: #334155;

            color: #cbd5e1;

            padding: 6px 10px;

            border-radius: 20px;

            font-size: 12px;
        }


        .review {
            background: #1e293b;

            padding: 22px;

            border-radius: 10px;

            margin-bottom: 15px;

            border:
                    1px solid transparent;
        }


        .review:hover {
            border-color: #334155;
        }


        .review-top {
            display: flex;

            justify-content: space-between;

            gap: 15px;

            align-items: center;

            margin-bottom: 12px;

            flex-wrap: wrap;
        }


        .review-rating {
            color: #facc15;

            font-weight: bold;
        }


        .review-comment {
            color: #cbd5e1;

            line-height: 1.6;

            word-wrap: break-word;

            white-space: pre-wrap;
        }


        .date {
            color: #64748b;

            font-size: 13px;
        }


        .your-review {
            display: inline-block;

            background: #1e3a8a;

            color: #bfdbfe;

            padding: 4px 8px;

            border-radius: 20px;

            font-size: 11px;

            margin-left: 8px;
        }


        /* =====================================================
           EMPTY STATE
        ====================================================== */

        .empty {
            background: #1e293b;

            padding: 35px;

            border-radius: 10px;

            text-align: center;

            color: #94a3b8;
        }


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (max-width: 700px) {

            .top-nav {
                flex-direction: column;

                align-items: flex-start;
            }


            .review-top {
                align-items: flex-start;
            }

        }

    </style>

</head>


<body>

<div class="container">


    <!-- =====================================================
         TOP NAVIGATION
    ====================================================== -->

    <div class="top-nav">


        <a class="back"
           href="<%= request.getContextPath() %>/catalog">

            ← Back to Catalogue

        </a>


        <div class="nav-links">


            <a href="<%= request.getContextPath() %>/rentals">

                My Rentals

            </a>


            <a href="<%= request.getContextPath() %>/recently-watched">

                Recently Watched

            </a>


            <a href="<%= request.getContextPath() %>/logout"
               class="logout">

                Logout

            </a>


        </div>


    </div>


    <!-- =====================================================
         MOVIE INFORMATION
    ====================================================== -->

    <div class="movie-header">


        <h1>

            🎬

            <%= HtmlUtil.escape(
                    movie.getTitle()
            ) %>

        </h1>


        <div class="movie-meta">

            <%= HtmlUtil.escape(
                    movie.getGenre()
            ) %>

            •

            <%= movie.getReleaseYear() %>

            •

            Movie ID:

            <%= HtmlUtil.escape(
                    movie.getMovieId()
            ) %>

        </div>


        <div class="movie-rating">

            ⭐
            <%= movie.getRating() %>
            / 5

        </div>


        <div class="movie-description">

            <%= HtmlUtil.escape(
                    movie.getDescription()
            ) %>

        </div>


    </div>


    <!-- =====================================================
         ERROR MESSAGES
    ====================================================== -->

    <%
        if (
                "noteligible"
                        .equalsIgnoreCase(
                                error
                        )
        ) {
    %>


    <div class="message error-message">

        You can only review this movie after
        renting and returning it.

    </div>


    <%
    } else if (
            "rating"
                    .equalsIgnoreCase(
                            error
                    )
    ) {
    %>


    <div class="message error-message">

        Please select a valid rating
        between 1 and 5.

    </div>


    <%
    } else if (
            "comment"
                    .equalsIgnoreCase(
                            error
                    )
    ) {
    %>


    <div class="message error-message">

        Please enter a review comment.

    </div>


    <%
    } else if (
            "commentlength"
                    .equalsIgnoreCase(
                            error
                    )
    ) {
    %>


    <div class="message error-message">

        Your review comment must be
        500 characters or fewer.

    </div>


    <%
        }
    %>


    <!-- =====================================================
         SUCCESS MESSAGES
    ====================================================== -->

    <%
        if (
                "saved"
                        .equalsIgnoreCase(
                                success
                        )
        ) {
    %>


    <div class="message success-message">

        ✓ Your review has been saved successfully.

    </div>


    <%
    } else if (
            "deleted"
                    .equalsIgnoreCase(
                            success
                    )
    ) {
    %>


    <div class="message success-message">

        ✓ Your review has been deleted successfully.

    </div>


    <%
        }
    %>


    <!-- =====================================================
         REVIEW ELIGIBILITY
    ====================================================== -->

    <%
        if (canReview) {
    %>


    <!-- =====================================================
         REVIEW FORM
    ====================================================== -->

    <div class="review-form-box">


        <h2>

            <%= userReview == null
                    ? "Write Your Review"
                    : "Update Your Review" %>

        </h2>


        <p class="form-description">

            You have completed a rental for this
            movie, so you can share your rating
            and experience.

        </p>


        <!-- =================================================
             ADD / UPDATE REVIEW
        ================================================== -->

        <form method="post"
              action="<%= request.getContextPath() %>/reviews">


            <input type="hidden"
                   name="action"
                   value="save">


            <input type="hidden"
                   name="movieId"
                   value="<%= HtmlUtil.escape(
                           movie.getMovieId()
                   ) %>">


            <!-- =============================================
                 RATING
            ============================================== -->

            <label for="rating">

                Rating

            </label>


            <select id="rating"
                    name="rating"
                    required>


                <option value="">

                    Select Rating

                </option>


                <option value="5"
                        <%= userReview != null
                                &&
                                userReview.getRating() == 5
                                ? "selected"
                                : "" %>>

                    ⭐⭐⭐⭐⭐
                    5 - Excellent

                </option>


                <option value="4"
                        <%= userReview != null
                                &&
                                userReview.getRating() == 4
                                ? "selected"
                                : "" %>>

                    ⭐⭐⭐⭐
                    4 - Very Good

                </option>


                <option value="3"
                        <%= userReview != null
                                &&
                                userReview.getRating() == 3
                                ? "selected"
                                : "" %>>

                    ⭐⭐⭐
                    3 - Good

                </option>


                <option value="2"
                        <%= userReview != null
                                &&
                                userReview.getRating() == 2
                                ? "selected"
                                : "" %>>

                    ⭐⭐
                    2 - Poor

                </option>


                <option value="1"
                        <%= userReview != null
                                &&
                                userReview.getRating() == 1
                                ? "selected"
                                : "" %>>

                    ⭐
                    1 - Very Poor

                </option>


            </select>


            <!-- =============================================
                 COMMENT
            ============================================== -->

            <label for="comment">

                Review Comment

            </label>


            <textarea id="comment"
                      name="comment"
                      maxlength="500"
                      required
                      placeholder="Write your opinion about this movie..."><%= userReview == null
                    ? ""
                    : HtmlUtil.escape(
                    userReview.getComment()
            ) %></textarea>


            <div class="character-info">

                Maximum 500 characters.

            </div>


            <button type="submit"
                    class="button">

                <%= userReview == null
                        ? "Submit Review"
                        : "Update Review" %>

            </button>


        </form>


        <!-- =================================================
             DELETE USER'S OWN REVIEW
        ================================================== -->

        <%
            if (userReview != null) {
        %>


        <form method="post"
              action="<%= request.getContextPath() %>/reviews">


            <input type="hidden"
                   name="action"
                   value="delete">


            <input type="hidden"
                   name="movieId"
                   value="<%= HtmlUtil.escape(
                           movie.getMovieId()
                   ) %>">


            <button type="submit"
                    class="delete-button"
                    onclick="return confirm('Are you sure you want to delete your review?');">

                Delete My Review

            </button>


        </form>


        <%
            }
        %>


    </div>


    <%
    } else {
    %>


    <!-- =====================================================
         NOT ELIGIBLE
    ====================================================== -->

    <div class="message info-message">

        🔒 You can read customer reviews
        for this movie, but you cannot
        write a review yet.

        <br><br>

        Rent and return this movie first.

        After the rental status becomes

        <strong>
            RETURNED
        </strong>,

        the review form will automatically
        become available.

    </div>


    <%
        }
    %>


    <!-- =====================================================
         CUSTOMER REVIEWS HEADING
    ====================================================== -->

    <div class="reviews-heading">


        <h2>

            Customer Reviews

        </h2>


        <div class="review-count">

            <%= reviews == null
                    ? 0
                    : reviews.size() %>

            Review(s)

        </div>


    </div>


    <!-- =====================================================
         CUSTOMER REVIEWS
    ====================================================== -->

    <%
        if (
                reviews == null
                        ||
                        reviews.isEmpty()
        ) {
    %>


    <div class="empty">


        <h3>

            No Reviews Yet

        </h3>


        <p>

            No customer has reviewed
            this movie yet.

        </p>


    </div>


    <%
    } else {

        for (Review review : reviews) {


            boolean ownReview =
                    loggedUserId.equals(
                            review.getUserId()
                    );
    %>


    <div class="review">


        <!-- REVIEW HEADER -->

        <div class="review-top">


            <div>


                <span class="review-rating">

                    ⭐
                    <%= review.getRating() %>
                    / 5

                </span>


                <%
                    if (ownReview) {
                %>


                <span class="your-review">

                    YOUR REVIEW

                </span>


                <%
                    }
                %>


            </div>


            <div class="date">

                <%= HtmlUtil.escape(
                        review.getReviewDate()
                ) %>

            </div>


        </div>


        <!-- REVIEW COMMENT -->

        <div class="review-comment">

            <%= HtmlUtil.escape(
                    review.getComment()
            ) %>

        </div>


        <!-- CUSTOMER -->

        <div class="date"
             style="margin-top: 12px;">

            Customer ID:

            <%= HtmlUtil.escape(
                    review.getUserId()
            ) %>

        </div>


    </div>


    <%
            }
        }
    %>


</div>

</body>

</html>