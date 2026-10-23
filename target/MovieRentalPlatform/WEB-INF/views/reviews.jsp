<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx = request.getContextPath();
    Movie movie =(Movie)request.getAttribute(  "movie"  );

    List<Review> reviews = (List<Review>)  request.getAttribute(  "reviews" );


     Review userReview =(Review) request.getAttribute(  "userReview"  );

    Boolean canReviewObject =  (Boolean) request.getAttribute( "canReview"  );

    boolean canReview =Boolean.TRUE.equals( canReviewObject  );

      String userName = (String) session.getAttribute( "userName"    );


    String role =  (String) session.getAttribute("role"  );

    String success = request.getParameter( "success" );

    String error =request.getParameter( "error" );



    if ( userName == null  || role == null ) {

        response.sendRedirect( ctx + "/login");



        return;
    }


    if (
            !"CUSTOMER".equalsIgnoreCase(
                    role
            )
    ) {

        response.sendRedirect(
                ctx + "/admin"
        );

        return;
    }




    if (movie == null) {

        response.sendRedirect(
                ctx + "/catalog?error=notfound"
        );

        return;
    }



    String userInitial =
            "U";


    if (
            userName != null
                    &&
                    !userName.trim().isEmpty()
    ) {

        userInitial =
                userName
                        .trim()
                        .substring(
                                0,
                                1
                        )
                        .toUpperCase();
    }




    int reviewCount =
            reviews == null
                    ? 0
                    : reviews.size();
%>


<!DOCTYPE html>

<html lang="en">


<head>

    <meta charset="UTF-8">

    <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
    >

    <title>
        Reviews | CineRent
    </title>


    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <style>



        body {
            margin: 0;

            background:
                    #050811;

            color:
                    #ffffff;
        }


        .reviews-page {
            min-height:
                    calc(100vh - 75px);

            padding:
                    45px
                    0
                    80px;

            background:

                    radial-gradient(
                            circle at 80% 10%,
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.16
                            ),
                            transparent 30%
                    ),

                    radial-gradient(
                            circle at 8% 55%,
                            rgba(
                                    37,
                                    99,
                                    235,
                                    0.08
                            ),
                            transparent 25%
                    );
        }


        .reviews-container {
            width:
                    92%;

            max-width:
                    1380px;

            margin:
                    0 auto;
        }



        .customer-navbar {
            position:
                    sticky;

            top: 0;

            z-index:
                    1000;

            background:
                    rgba(
                            4,
                            7,
                            14,
                            0.90
                    );

            border-bottom:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );

            backdrop-filter:
                    blur(18px);
        }


        .customer-navbar-inner {
            width:
                    92%;

            max-width:
                    1380px;

            min-height:
                    76px;

            margin:
                    0 auto;

            display:
                    flex;

            align-items:
                    center;

            gap:
                    25px;
        }


        .customer-brand {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    10px;

            color:
                    #ffffff;

            text-decoration:
                    none;

            font-size:
                    20px;

            font-weight:
                    850;
        }


        .customer-brand-icon {
            width:
                    40px;

            height:
                    40px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            border-radius:
                    13px;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6
                    );

            box-shadow:
                    0
                    8px
                    25px
                    rgba(
                            124,
                            58,
                            237,
                            0.30
                    );
        }


        .customer-nav-links {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    6px;

            margin-left:
                    auto;
        }


        .customer-nav-link {
            padding:
                    9px
                    12px;

            border-radius:
                    9px;

            color:
                    #94a3b8;

            text-decoration:
                    none;

            font-size:
                    12px;

            font-weight:
                    700;

            transition:
                    0.2s ease;
        }


        .customer-nav-link:hover {
            color:
                    #ffffff;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );
        }


        .customer-profile {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    10px;

            margin-left:
                    10px;
        }


        .customer-avatar {
            width:
                    37px;

            height:
                    37px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            border-radius:
                    50%;

            background:
                    linear-gradient(
                            135deg,
                            #8b5cf6,
                            #3b82f6
                    );

            font-size:
                    13px;

            font-weight:
                    800;
        }


        .customer-profile-name {
            max-width:
                    130px;

            overflow:
                    hidden;

            text-overflow:
                    ellipsis;

            white-space:
                    nowrap;

            font-size:
                    12px;

            font-weight:
                    700;
        }


        .customer-logout {
            padding:
                    8px
                    12px;

            border-radius:
                    8px;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.10
                    );

            color:
                    #cbd5e1;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.04
                    );

            text-decoration:
                    none;

            font-size:
                    11px;

            font-weight:
                    700;
        }




        .reviews-header {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    flex-end;

            gap:
                    25px;

            margin-bottom:
                    28px;
        }


        .reviews-badge {
            display:
                    inline-flex;

            align-items:
                    center;

            gap:
                    7px;

            margin-bottom:
                    13px;

            padding:
                    7px
                    11px;

            border-radius:
                    999px;

            color:
                    #c4b5fd;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.10
                    );

            border:
                    1px solid
                    rgba(
                            139,
                            92,
                            246,
                            0.22
                    );

            font-size:
                    10px;

            font-weight:
                    800;

            text-transform:
                    uppercase;
        }


        .reviews-title {
            margin: 0;

            font-size:
                    clamp(
                            34px,
                            4vw,
                            48px
                    );

            letter-spacing:
                    -1.5px;
        }


        .reviews-description {
            margin:
                    9px
                    0
                    0;

            color:
                    #94a3b8;

            font-size:
                    14px;

            line-height:
                    1.7;
        }


        .back-button {
            min-height:
                    43px;

            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            padding:
                    0
                    16px;

            border-radius:
                    10px;

            color:
                    #e2e8f0;

            text-decoration:
                    none;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.04
                    );

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.09
                    );

            font-size:
                    11px;

            font-weight:
                    750;
        }


        /* =====================================================
           ALERTS
        ====================================================== */

        .review-alert {
            margin-bottom:
                    18px;

            padding:
                    14px
                    16px;

            border-radius:
                    12px;

            font-size:
                    12px;

            line-height:
                    1.6;
        }


        .review-alert.success {
            color:
                    #86efac;

            background:
                    rgba(
                            34,
                            197,
                            94,
                            0.08
                    );

            border:
                    1px solid
                    rgba(
                            34,
                            197,
                            94,
                            0.18
                    );
        }


        .review-alert.error {
            color:
                    #fca5a5;

            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.08
                    );

            border:
                    1px solid
                    rgba(
                            239,
                            68,
                            68,
                            0.18
                    );
        }


        .review-alert.info {
            color:
                    #93c5fd;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.07
                    );

            border:
                    1px solid
                    rgba(
                            59,
                            130,
                            246,
                            0.16
                    );
        }




        .review-hero {
            display:
                    grid;

            grid-template-columns:
                    minmax(
                            0,
                            1.25fr
                    )
                    minmax(
                            330px,
                            0.75fr
                    );

            gap:
                    20px;

            margin-bottom:
                    45px;
        }



        .review-movie-card {
            overflow:
                    hidden;

            display:
                    grid;

            grid-template-columns:
                    250px
                    minmax(
                            0,
                            1fr
                    );

            min-height:
                    380px;

            border-radius:
                    22px;

            background:
                    linear-gradient(
                            135deg,
                            rgba(
                                    27,
                                    39,
                                    65,
                                    0.92
                            ),
                            rgba(
                                    15,
                                    23,
                                    42,
                                    0.78
                            )
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.11
                    );
        }


        .review-poster-wrapper {
            position:
                    relative;

            min-height:
                    380px;

            overflow:
                    hidden;
        }


        .review-poster {
            width:
                    100%;

            height:
                    100%;

            display:
                    block;

            object-fit:
                    cover;
        }


        .review-poster-wrapper::after {
            content: "";

            position:
                    absolute;

            inset: 0;

            background:
                    linear-gradient(
                            to right,
                            transparent 55%,
                            rgba(
                                    24,
                                    35,
                                    57,
                                    0.95
                            )
                    );
        }


        .review-movie-content {
            display:
                    flex;

            flex-direction:
                    column;

            justify-content:
                    center;

            padding:
                    35px;
        }


        .movie-id {
            width:
                    fit-content;

            margin-bottom:
                    14px;

            padding:
                    5px
                    8px;

            border-radius:
                    7px;

            color:
                    #94a3b8;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.05
                    );

            font-size:
                    9px;

            font-weight:
                    700;
        }


        .review-movie-title {
            margin:
                    0
                    0
                    10px;

            font-size:
                    clamp(
                            27px,
                            3vw,
                            40px
                    );

            letter-spacing:
                    -1px;
        }


        .movie-meta {
            display:
                    flex;

            align-items:
                    center;

            flex-wrap:
                    wrap;

            gap:
                    8px;

            color:
                    #94a3b8;

            font-size:
                    12px;
        }


        .movie-rating {
            color:
                    #facc15;

            font-weight:
                    750;
        }


        .genre-badge {
            display:
                    inline-flex;

            width:
                    fit-content;

            margin-top:
                    16px;

            padding:
                    6px
                    10px;

            border-radius:
                    999px;

            color:
                    #c4b5fd;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.12
                    );

            border:
                    1px solid
                    rgba(
                            139,
                            92,
                            246,
                            0.20
                    );

            font-size:
                    10px;

            font-weight:
                    700;
        }


        .movie-description {
            max-width:
                    650px;

            margin:
                    19px
                    0
                    0;

            color:
                    #a1adbe;

            line-height:
                    1.75;

            font-size:
                    13px;
        }




        .review-form-card {
            padding:
                    28px;

            border-radius:
                    22px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.75
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.10
                    );
        }


        .review-form-card h2 {
            margin:
                    0
                    0
                    7px;

            font-size:
                    20px;
        }


        .review-form-description {
            margin:
                    0
                    0
                    22px;

            color:
                    #64748b;

            font-size:
                    11px;

            line-height:
                    1.6;
        }


        .review-form-group {
            margin-bottom:
                    17px;
        }


        .review-form-group label {
            display:
                    block;

            margin-bottom:
                    8px;

            color:
                    #cbd5e1;

            font-size:
                    11px;

            font-weight:
                    750;
        }


        .review-control {
            width:
                    100%;

            padding:
                    12px
                    13px;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.18
                    );

            border-radius:
                    10px;

            outline:
                    none;

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.82
                    );

            color:
                    #ffffff;

            font-family:
                    inherit;
        }


        .review-control:focus {
            border-color:
                    #8b5cf6;

            box-shadow:
                    0
                    0
                    0
                    3px
                    rgba(
                            139,
                            92,
                            246,
                            0.10
                    );
        }


        textarea.review-control {
            min-height:
                    130px;

            resize:
                    vertical;
        }


        .review-submit {
            width:
                    100%;

            min-height:
                    43px;

            border:
                    0;

            border-radius:
                    10px;

            cursor:
                    pointer;

            color:
                    #ffffff;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6
                    );

            font-size:
                    11px;

            font-weight:
                    800;
        }


        .review-delete {
            width:
                    100%;

            min-height:
                    41px;

            margin-top:
                    9px;

            border-radius:
                    10px;

            cursor:
                    pointer;

            color:
                    #fca5a5;

            border:
                    1px solid
                    rgba(
                            239,
                            68,
                            68,
                            0.20
                    );

            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.07
                    );

            font-size:
                    11px;

            font-weight:
                    750;
        }



        .reviews-section-header {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap:
                    20px;

            margin-bottom:
                    18px;
        }


        .reviews-section-header h2 {
            margin: 0;

            font-size:
                    22px;
        }


        .review-count {
            padding:
                    6px
                    10px;

            border-radius:
                    999px;

            color:
                    #c4b5fd;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.10
                    );

            font-size:
                    10px;

            font-weight:
                    750;
        }


        .review-list {
            display:
                    grid;

            grid-template-columns:
                    repeat(
                            2,
                            minmax(
                                    0,
                                    1fr
                            )
                    );

            gap:
                    15px;
        }


        .review-card {
            padding:
                    21px;

            border-radius:
                    17px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.68
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.09
                    );

            transition:
                    transform
                    0.2s ease,
                    border-color
                    0.2s ease;
        }


        .review-card:hover {
            transform:
                    translateY(-2px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.24
                    );
        }


        .review-card-header {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap:
                    15px;

            margin-bottom:
                    15px;
        }


        .review-user {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    10px;
        }


        .review-avatar {
            width:
                    36px;

            height:
                    36px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            border-radius:
                    50%;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.14
                    );

            color:
                    #c4b5fd;

            font-size:
                    11px;

            font-weight:
                    800;
        }


        .review-user-name {
            color:
                    #e2e8f0;

            font-size:
                    11px;

            font-weight:
                    750;
        }


        .review-date {
            color:
                    #64748b;

            font-size:
                    9px;
        }


        .review-stars {
            margin-bottom:
                    11px;

            color:
                    #facc15;

            letter-spacing:
                    2px;

            font-size:
                    16px;
        }


        .review-comment {
            margin: 0;

            color:
                    #aab4c3;

            line-height:
                    1.7;

            font-size:
                    12px;
        }


        .review-empty {
            padding:
                    55px
                    20px;

            text-align:
                    center;

            border-radius:
                    18px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.60
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.09
                    );

            color:
                    #94a3b8;
        }




        .reviews-footer {
            border-top:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );

            background:
                    #04070e;
        }


        .reviews-footer-inner {
            width:
                    92%;

            max-width:
                    1380px;

            min-height:
                    75px;

            margin:
                    0 auto;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    space-between;

            color:
                    #475569;

            font-size:
                    10px;
        }



        @media (
        max-width: 1050px
        ) {

            .review-hero {
                grid-template-columns:
                        1fr;
            }

        }


        @media (
        max-width: 800px
        ) {

            .customer-nav-links {
                display:
                        none;
            }


            .review-movie-card {
                grid-template-columns:
                        190px
                        1fr;
            }


            .review-list {
                grid-template-columns:
                        1fr;
            }

        }


        @media (
        max-width: 650px
        ) {

            .customer-profile-name {
                display:
                        none;
            }


            .reviews-header {
                flex-direction:
                        column;

                align-items:
                        flex-start;
            }


            .back-button {
                width:
                        100%;
            }


            .review-movie-card {
                grid-template-columns:
                        1fr;
            }


            .review-poster-wrapper {
                min-height:
                        350px;

                max-height:
                        450px;
            }


            .review-poster-wrapper::after {
                background:
                        linear-gradient(
                                to top,
                                rgba(
                                        24,
                                        35,
                                        57,
                                        0.96
                                ),
                                transparent 60%
                        );
            }


            .review-movie-content {
                padding:
                        24px;
            }

        }

    </style>

</head>


<body>


<!-- =========================================================
     CUSTOMER NAV
========================================================= -->

<header class="customer-navbar">


    <div class="customer-navbar-inner">


        <a
                href="<%= ctx %>/"
                class="customer-brand"
        >


            <span class="customer-brand-icon">

                🎬

            </span>


            CineRent

        </a>


        <nav class="customer-nav-links">


            <a
                    href="<%= ctx %>/"
                    class="customer-nav-link"
            >

                Home

            </a>


            <a
                    href="<%= ctx %>/catalog"
                    class="customer-nav-link"
            >

                Movies

            </a>


            <a
                    href="<%= ctx %>/rentals"
                    class="customer-nav-link"
            >

                My Rentals

            </a>


            <a
                    href="<%= ctx %>/recently-watched"
                    class="customer-nav-link"
            >

                Recently Watched

            </a>


        </nav>


        <div class="customer-profile">


            <div class="customer-avatar">

                <%= HtmlUtil.escape(
                        userInitial
                ) %>

            </div>


            <span class="customer-profile-name">

                <%= HtmlUtil.escape(
                        userName
                ) %>

            </span>


            <a
                    href="<%= ctx %>/logout"
                    class="customer-logout"
            >

                Logout

            </a>


        </div>


    </div>


</header>


<!-- =========================================================
     MAIN
========================================================= -->

<main class="reviews-page">


    <div class="reviews-container">


        <!-- =====================================================
             HEADER
        ====================================================== -->

        <section class="reviews-header">


            <div>


                <div class="reviews-badge">

                    ⭐ CineRent Reviews

                </div>


                <h1 class="reviews-title">

                    Movie Reviews

                </h1>


                <p class="reviews-description">

                    Read what other customers think
                    and share your own movie experience.

                </p>


            </div>


            <a
                    href="<%= ctx %>/catalog"
                    class="back-button"
            >

                ← Back to Movies

            </a>


        </section>


        <!-- =====================================================
             SUCCESS
        ====================================================== -->

        <%
            if (
                    "saved".equalsIgnoreCase(
                            success
                    )
            ) {
        %>


        <div
                class="review-alert success"
                data-auto-hide
        >

            ✓ Your review has been saved successfully.

        </div>


        <%
            }

            if (
                    "deleted".equalsIgnoreCase(
                            success
                    )
            ) {
        %>


        <div
                class="review-alert success"
                data-auto-hide
        >

            ✓ Your review has been deleted.

        </div>


        <%
            }
        %>


        <!-- =====================================================
             ERRORS
        ====================================================== -->

        <%
            if (
                    "noteligible".equalsIgnoreCase(
                            error
                    )
            ) {
        %>


        <div class="review-alert info">

            You need to rent and return this movie
            before submitting a review.

        </div>


        <%
        } else if (
                "rating".equalsIgnoreCase(
                        error
                )
        ) {
        %>


        <div class="review-alert error">

            Please select a rating between
            1 and 5 stars.

        </div>


        <%
        } else if (
                "comment".equalsIgnoreCase(
                        error
                )
        ) {
        %>


        <div class="review-alert error">

            Please enter your review comment.

        </div>


        <%
        } else if (
                "commentlength".equalsIgnoreCase(
                        error
                )
        ) {
        %>


        <div class="review-alert error">

            Your review must be
            500 characters or fewer.

        </div>


        <%
            }
        %>


        <!-- =====================================================
             MOVIE + REVIEW FORM
        ====================================================== -->

        <section class="review-hero">


            <!-- =================================================
                 MOVIE
            ================================================== -->

            <article class="review-movie-card">


                <div class="review-poster-wrapper">


                    <img
                            class="review-poster"

                            src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(
                                    movie.getMovieId()
                            ) %>"

                            alt="<%= HtmlUtil.escape(
                                    movie.getTitle()
                            ) %>"

                            onerror="
                                    this.onerror=null;
                                    this.src='<%= ctx %>/images/posters/default.svg';
                                    "
                    >


                </div>


                <div class="review-movie-content">


                    <span class="movie-id">

                        Movie ID:
                        <%= HtmlUtil.escape(
                                movie.getMovieId()
                        ) %>

                    </span>


                    <h2 class="review-movie-title">

                        <%= HtmlUtil.escape(
                                movie.getTitle()
                        ) %>

                    </h2>


                    <div class="movie-meta">


                        <span>

                            <%= movie.getReleaseYear() %>

                        </span>


                        <span>
                            •
                        </span>


                        <span class="movie-rating">

                            ⭐

                            <%= String.format(
                                    "%.1f",
                                    movie.getRating()
                            ) %>

                        </span>


                        <span>
                            •
                        </span>


                        <span>

                            <%= reviewCount %>
                            review(s)

                        </span>


                    </div>


                    <span class="genre-badge">

                        <%= HtmlUtil.escape(
                                movie.getGenre()
                        ) %>

                    </span>


                    <p class="movie-description">

                        <%
                            if (
                                    movie.getDescription()
                                            == null
                                            ||
                                            movie.getDescription()
                                                    .trim()
                                                    .isEmpty()
                            ) {
                        %>

                        No description available
                        for this movie.

                        <%
                        } else {
                        %>

                        <%= HtmlUtil.escape(
                                movie.getDescription()
                        ) %>

                        <%
                            }
                        %>

                    </p>


                </div>


            </article>


            <!-- =================================================
                 REVIEW FORM
            ================================================== -->

            <aside class="review-form-card">


                <h2>

                    <%= userReview == null
                            ? "Write a Review"
                            : "Your Review" %>

                </h2>


                <p class="review-form-description">

                    <%= canReview
                            ? "Share your rating and thoughts about this movie."
                            : "Reviews become available after you return the movie." %>

                </p>


                <%
                    if (canReview) {
                %>


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
                            value="<%= HtmlUtil.escape(
                                    movie.getMovieId()
                            ) %>"
                    >


                    <div class="review-form-group">


                        <label for="rating">

                            Rating

                        </label>


                        <select
                                id="rating"
                                class="review-control"
                                name="rating"
                                required
                        >


                            <option value="">

                                Select your rating

                            </option>


                            <%
                                for (
                                        int i = 5;
                                        i >= 1;
                                        i--
                                ) {
                            %>


                            <option
                                    value="<%= i %>"

                                    <%= userReview != null
                                            &&
                                            userReview.getRating()
                                                    == i
                                            ? "selected"
                                            : "" %>
                            >

                                <%= i %>

                                Star<%= i > 1
                                    ? "s"
                                    : "" %>

                                <%= i == 5
                                        ? " ★★★★★"
                                        : i == 4
                                        ? " ★★★★☆"
                                        : i == 3
                                        ? " ★★★☆☆"
                                        : i == 2
                                        ? " ★★☆☆☆"
                                        : " ★☆☆☆☆" %>

                            </option>


                            <%
                                }
                            %>


                        </select>


                    </div>


                    <div class="review-form-group">


                        <label for="comment">

                            Your Review

                        </label>


                        <textarea
                                id="comment"
                                class="review-control"
                                name="comment"
                                maxlength="500"
                                required
                                placeholder="What did you think about this movie?"
                        ><%= userReview != null
                                ? HtmlUtil.escape(
                                userReview.getComment()
                        )
                                : "" %></textarea>


                    </div>


                    <button
                            type="submit"
                            class="review-submit"
                    >

                        <%= userReview == null
                                ? "⭐ Submit Review"
                                : "✓ Update Review" %>

                    </button>


                </form>


                <!-- DELETE EXISTING REVIEW -->

                <%
                    if (
                            userReview != null
                    ) {
                %>


                <form
                        action="<%= ctx %>/reviews"
                        method="post"
                        data-confirm="Are you sure you want to delete your review?"
                >


                    <input
                            type="hidden"
                            name="action"
                            value="delete"
                    >


                    <input
                            type="hidden"
                            name="movieId"
                            value="<%= HtmlUtil.escape(
                                    movie.getMovieId()
                            ) %>"
                    >


                    <button
                            type="submit"
                            class="review-delete"
                    >

                        🗑 Delete My Review

                    </button>


                </form>


                <%
                    }
                %>


                <%
                } else {
                %>


                <div class="review-alert info">

                    📀 Rent and return this movie
                    before submitting a review.

                    <div
                            style="
                                margin-top:12px;
                            "
                    >

                        <a
                                href="<%= ctx %>/catalog"
                                style="
                                    color:#93c5fd;
                                    font-weight:700;
                                    text-decoration:none;
                                "
                        >

                            Browse Movies →

                        </a>

                    </div>

                </div>


                <%
                    }
                %>


            </aside>


        </section>


        <!-- =====================================================
             CUSTOMER REVIEWS
        ====================================================== -->

        <section>


            <div class="reviews-section-header">


                <h2>

                    Customer Reviews

                </h2>


                <span class="review-count">

                    <%= reviewCount %>
                    Review<%= reviewCount == 1
                        ? ""
                        : "s" %>

                </span>


            </div>


            <%
                if (
                        reviews == null
                                ||
                                reviews.isEmpty()
                ) {
            %>


            <div class="review-empty">


                <div
                        style="
                            font-size:38px;
                            margin-bottom:10px;
                        "
                >

                    ⭐

                </div>


                <strong>

                    No customer reviews yet.

                </strong>


                <div
                        style="
                            margin-top:7px;
                        "
                >

                    Be the first customer to share
                    your experience after returning
                    this movie.

                </div>


            </div>


            <%
            } else {
            %>


            <div class="review-list">


                <%
                    for (
                            Review review : reviews
                    ) {
                %>


                <article class="review-card">


                    <div class="review-card-header">


                        <div class="review-user">


                            <div class="review-avatar">

                                C

                            </div>


                            <div>


                                <div class="review-user-name">

                                    Customer
                                    <%= HtmlUtil.escape(
                                            review.getUserId()
                                    ) %>

                                </div>


                                <div class="review-date">

                                    <%= HtmlUtil.escape(
                                            review.getReviewDate()
                                    ) %>

                                </div>


                            </div>


                        </div>


                    </div>


                    <div class="review-stars">


                        <%
                            for (
                                    int star = 1;
                                    star <= 5;
                                    star++
                            ) {
                        %>


                        <%= star
                                <=
                                review.getRating()
                                ? "★"
                                : "☆" %>


                        <%
                            }
                        %>


                    </div>


                    <p class="review-comment">

                        <%= HtmlUtil.escape(
                                review.getComment()
                        ) %>

                    </p>


                </article>


                <%
                    }
                %>


            </div>


            <%
                }
            %>


        </section>


    </div>


</main>


<!-- =========================================================
     FOOTER
========================================================= -->

<footer class="reviews-footer">


    <div class="reviews-footer-inner">


        <div>

            © 2026 CineRent

        </div>


        <div>

            Browse • Rent • Watch • Review

        </div>


    </div>


</footer>


<script
        src="<%= ctx %>/js/app.js"
></script>


</body>

</html>