<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%@ page import="com.movierental.model.Review" %>
<%@ page import="com.movierental.model.User" %>
<%@ page import="com.movierental.model.Movie" %>

<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx =
            request.getContextPath();


    // =========================================================
    // DATA
    // =========================================================

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


    Integer totalReviewCountObject =
            (Integer)
                    request.getAttribute(
                            "totalReviewCount"
                    );


    Integer filteredCountObject =
            (Integer)
                    request.getAttribute(
                            "filteredCount"
                    );


    Integer fiveStarCountObject =
            (Integer)
                    request.getAttribute(
                            "fiveStarCount"
                    );


    Integer fourStarCountObject =
            (Integer)
                    request.getAttribute(
                            "fourStarCount"
                    );


    Integer threeStarCountObject =
            (Integer)
                    request.getAttribute(
                            "threeStarCount"
                    );


    Integer twoStarCountObject =
            (Integer)
                    request.getAttribute(
                            "twoStarCount"
                    );


    Integer oneStarCountObject =
            (Integer)
                    request.getAttribute(
                            "oneStarCount"
                    );


    // =========================================================
    // DEFAULT VALUES
    // =========================================================

    if (search == null) {
        search = "";
    }


    if (
            selectedRating == null
                    ||
                    selectedRating.trim().isEmpty()
    ) {

        selectedRating =
                "all";
    }


    int totalReviewCount =
            totalReviewCountObject == null
                    ? 0
                    : totalReviewCountObject;


    int filteredCount =
            filteredCountObject == null
                    ? 0
                    : filteredCountObject;


    int fiveStarCount =
            fiveStarCountObject == null
                    ? 0
                    : fiveStarCountObject;


    int fourStarCount =
            fourStarCountObject == null
                    ? 0
                    : fourStarCountObject;


    int threeStarCount =
            threeStarCountObject == null
                    ? 0
                    : threeStarCountObject;


    int twoStarCount =
            twoStarCountObject == null
                    ? 0
                    : twoStarCountObject;


    int oneStarCount =
            oneStarCountObject == null
                    ? 0
                    : oneStarCountObject;


    int lowRatingCount =
            oneStarCount
                    +
                    twoStarCount;


    double averageRating =
            0.0;


    if (totalReviewCount > 0) {

        averageRating =
                (
                        (fiveStarCount * 5.0)
                                +
                                (fourStarCount * 4.0)
                                +
                                (threeStarCount * 3.0)
                                +
                                (twoStarCount * 2.0)
                                +
                                oneStarCount
                )
                        /
                        totalReviewCount;
    }
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
        Review Management | CineRent
    </title>


    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <style>

        /* =====================================================
           PAGE
        ====================================================== */

        body {
            background:
                    #050811;

            color:
                    #ffffff;
        }


        .admin-reviews-page {
            min-height:
                    calc(100vh - 70px);

            padding:
                    42px
                    0
                    75px;

            background:

                    radial-gradient(
                            circle at 78% 3%,
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.14
                            ),
                            transparent 27%
                    ),

                    radial-gradient(
                            circle at 10% 55%,
                            rgba(
                                    37,
                                    99,
                                    235,
                                    0.07
                            ),
                            transparent 24%
                    );
        }


        .admin-reviews-container {
            width:
                    92%;

            max-width:
                    1450px;

            margin:
                    0 auto;
        }


        /* =====================================================
           HEADER
        ====================================================== */

        .admin-reviews-header {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    flex-end;

            gap:
                    25px;

            margin-bottom:
                    30px;
        }


        .admin-reviews-badge {
            display:
                    inline-flex;

            align-items:
                    center;

            gap:
                    7px;

            padding:
                    7px
                    11px;

            margin-bottom:
                    12px;

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

            letter-spacing:
                    0.7px;
        }


        .admin-reviews-title {
            margin: 0;

            font-size:
                    clamp(
                            34px,
                            4vw,
                            48px
                    );

            letter-spacing:
                    -1.7px;
        }


        .admin-reviews-description {
            margin:
                    9px
                    0
                    0;

            color:
                    #94a3b8;

            line-height:
                    1.7;

            font-size:
                    14px;
        }


        .dashboard-button {
            min-height:
                    44px;

            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            gap:
                    7px;

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

            transition:
                    0.2s ease;
        }


        .dashboard-button:hover {
            transform:
                    translateY(-2px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.32
                    );
        }


        /* =====================================================
           STATS
        ====================================================== */

        .review-stat-grid {
            display:
                    grid;

            grid-template-columns:
                    repeat(
                            6,
                            minmax(
                                    0,
                                    1fr
                            )
                    );

            gap:
                    14px;

            margin-bottom:
                    28px;
        }


        .review-stat-card {
            position:
                    relative;

            overflow:
                    hidden;

            min-height:
                    145px;

            padding:
                    19px;

            border-radius:
                    17px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.74
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.10
                    );

            transition:
                    transform
                    0.2s ease,
                    border-color
                    0.2s ease;
        }


        .review-stat-card:hover {
            transform:
                    translateY(-3px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.28
                    );
        }


        .review-stat-card::after {
            content: "";

            position:
                    absolute;

            width:
                    95px;

            height:
                    95px;

            right:
                    -45px;

            bottom:
                    -50px;

            border-radius:
                    50%;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.11
                    );
        }


        .review-stat-icon {
            margin-bottom:
                    12px;

            font-size:
                    20px;
        }


        .review-stat-value {
            margin-bottom:
                    5px;

            font-size:
                    25px;

            font-weight:
                    850;
        }


        .review-stat-label {
            color:
                    #64748b;

            font-size:
                    10px;

            font-weight:
                    650;
        }


        .stat-purple {
            color:
                    #a78bfa;
        }


        .stat-yellow {
            color:
                    #facc15;
        }


        .stat-green {
            color:
                    #4ade80;
        }


        .stat-blue {
            color:
                    #60a5fa;
        }


        .stat-orange {
            color:
                    #fb923c;
        }


        .stat-red {
            color:
                    #fb7185;
        }


        /* =====================================================
           FILTER PANEL
        ====================================================== */

        .review-filter-panel {
            margin-bottom:
                    25px;

            padding:
                    20px;

            border-radius:
                    18px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.64
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


        .filter-header {
            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    space-between;

            gap:
                    15px;

            margin-bottom:
                    16px;
        }


        .filter-header h3 {
            margin: 0;

            font-size:
                    15px;
        }


        .filter-result-count {
            padding:
                    5px
                    9px;

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
                    9px;

            font-weight:
                    800;
        }


        .review-filter-form {
            display:
                    grid;

            grid-template-columns:
                    minmax(
                            0,
                            2fr
                    )
                    minmax(
                            180px,
                            0.7fr
                    )
                    auto
                    auto;

            gap:
                    11px;

            align-items:
                    center;
        }


        .search-wrapper {
            position:
                    relative;
        }


        .search-icon {
            position:
                    absolute;

            left:
                    14px;

            top:
                    50%;

            transform:
                    translateY(-50%);

            pointer-events:
                    none;

            color:
                    #64748b;
        }


        .review-search,
        .review-select {
            width:
                    100%;

            min-height:
                    44px;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.16
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
                            0.78
                    );

            color:
                    #ffffff;

            font-family:
                    inherit;
        }


        .review-search {
            padding:
                    0
                    14px
                    0
                    41px;
        }


        .review-select {
            padding:
                    0
                    12px;
        }


        .review-search:focus,
        .review-select:focus {
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
                            0.09
                    );
        }


        .filter-button,
        .reset-button {
            min-height:
                    44px;

            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            padding:
                    0
                    17px;

            border-radius:
                    10px;

            cursor:
                    pointer;

            font-family:
                    inherit;

            font-size:
                    11px;

            font-weight:
                    800;

            text-decoration:
                    none;
        }


        .filter-button {
            border:
                    0;

            color:
                    #ffffff;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6
                    );

            box-shadow:
                    0
                    10px
                    25px
                    rgba(
                            124,
                            58,
                            237,
                            0.18
                    );
        }


        .reset-button {
            color:
                    #cbd5e1;

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
                            0.08
                    );
        }


        /* =====================================================
           TABLE
        ====================================================== */

        .review-table-wrapper {
            overflow-x:
                    auto;

            border-radius:
                    18px;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.10
                    );

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.66
                    );
        }


        .review-table {
            width:
                    100%;

            min-width:
                    1150px;

            border-collapse:
                    collapse;
        }


        .review-table th {
            padding:
                    14px
                    16px;

            text-align:
                    left;

            background:
                    rgba(
                            51,
                            65,
                            85,
                            0.62
                    );

            color:
                    #94a3b8;

            font-size:
                    9px;

            font-weight:
                    800;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.7px;

            white-space:
                    nowrap;
        }


        .review-table td {
            padding:
                    16px;

            vertical-align:
                    middle;

            border-bottom:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.08
                    );
        }


        .review-table tbody tr {
            transition:
                    background
                    0.2s ease;
        }


        .review-table tbody tr:hover {
            background:
                    rgba(
                            51,
                            65,
                            85,
                            0.25
                    );
        }


        .review-table tbody tr:last-child td {
            border-bottom:
                    none;
        }


        /* =====================================================
           CUSTOMER
        ====================================================== */

        .customer-cell {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    11px;

            min-width:
                    180px;
        }


        .customer-avatar {
            width:
                    39px;

            height:
                    39px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            flex-shrink:
                    0;

            border-radius:
                    50%;

            color:
                    #ffffff;

            background:
                    linear-gradient(
                            135deg,
                            #7c3aed,
                            #3b82f6
                    );

            font-size:
                    12px;

            font-weight:
                    850;
        }


        .customer-name {
            margin-bottom:
                    4px;

            color:
                    #ffffff;

            font-size:
                    12px;

            font-weight:
                    750;
        }


        .customer-meta {
            color:
                    #64748b;

            font-size:
                    9px;

            line-height:
                    1.5;
        }


        /* =====================================================
           MOVIE
        ====================================================== */

        .movie-cell {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    11px;

            min-width:
                    195px;
        }


        .movie-poster-small {
            width:
                    45px;

            height:
                    66px;

            flex-shrink:
                    0;

            overflow:
                    hidden;

            border-radius:
                    8px;

            background:
                    #111827;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.07
                    );
        }


        .movie-poster-small img {
            width:
                    100%;

            height:
                    100%;

            display:
                    block;

            object-fit:
                    cover;
        }


        .movie-name {
            margin-bottom:
                    4px;

            font-size:
                    12px;

            font-weight:
                    750;
        }


        .movie-id {
            color:
                    #64748b;

            font-size:
                    9px;
        }


        /* =====================================================
           REVIEW DETAILS
        ====================================================== */

        .rating-stars {
            color:
                    #facc15;

            letter-spacing:
                    1px;

            white-space:
                    nowrap;

            font-size:
                    13px;
        }


        .rating-number {
            margin-top:
                    4px;

            color:
                    #94a3b8;

            font-size:
                    9px;
        }


        .review-comment-cell {
            max-width:
                    320px;

            color:
                    #cbd5e1;

            font-size:
                    11px;

            line-height:
                    1.65;
        }


        .review-date {
            color:
                    #94a3b8;

            font-size:
                    10px;

            white-space:
                    nowrap;
        }


        .review-id {
            display:
                    inline-flex;

            margin-top:
                    5px;

            padding:
                    3px
                    6px;

            border-radius:
                    6px;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.04
                    );

            color:
                    #64748b;

            font-size:
                    8px;
        }


        /* =====================================================
           DELETE
        ====================================================== */

        .delete-review-form {
            margin: 0;
        }


        .delete-review-button {
            min-height:
                    35px;

            padding:
                    0
                    12px;

            border-radius:
                    8px;

            border:
                    1px solid
                    rgba(
                            239,
                            68,
                            68,
                            0.22
                    );

            color:
                    #fca5a5;

            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.08
                    );

            cursor:
                    pointer;

            font-family:
                    inherit;

            font-size:
                    10px;

            font-weight:
                    800;

            transition:
                    0.2s ease;
        }


        .delete-review-button:hover {
            color:
                    #ffffff;

            background:
                    #dc2626;
        }


        /* =====================================================
           EMPTY
        ====================================================== */

        .review-empty {
            padding:
                    60px
                    20px
            !important;

            text-align:
                    center;

            color:
                    #94a3b8;
        }


        .review-empty-icon {
            margin-bottom:
                    10px;

            font-size:
                    40px;
        }


        /* =====================================================
           SUMMARY
        ====================================================== */

        .review-summary {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    12px;

            margin-top:
                    20px;

            padding:
                    15px
                    17px;

            border-radius:
                    13px;

            color:
                    #94a3b8;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.05
                    );

            border:
                    1px solid
                    rgba(
                            59,
                            130,
                            246,
                            0.12
                    );

            font-size:
                    11px;
        }


        .summary-icon {
            width:
                    35px;

            height:
                    35px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            flex-shrink:
                    0;

            border-radius:
                    9px;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.10
                    );
        }


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (
        max-width: 1200px
        ) {

            .review-stat-grid {
                grid-template-columns:
                        repeat(
                                3,
                                1fr
                        );
            }

        }


        @media (
        max-width: 800px
        ) {

            .review-filter-form {
                grid-template-columns:
                        1fr
                        1fr;
            }


            .review-search-wrapper {
                grid-column:
                        1 / -1;
            }

        }


        @media (
        max-width: 650px
        ) {

            .admin-reviews-header {
                flex-direction:
                        column;

                align-items:
                        flex-start;
            }


            .dashboard-button {
                width:
                        100%;
            }


            .review-stat-grid {
                grid-template-columns:
                        1fr
                        1fr;
            }


            .review-filter-form {
                grid-template-columns:
                        1fr;
            }


            .review-filter-form > * {
                width:
                        100%;
            }


            .review-search-wrapper {
                grid-column:
                        auto;
            }

        }


        @media (
        max-width: 430px
        ) {

            .review-stat-grid {
                grid-template-columns:
                        1fr;
            }

        }

    </style>

</head>


<body>


<!-- =========================================================
     ADMIN NAVIGATION
========================================================= -->

<jsp:include
        page="/WEB-INF/views/partials/admin-nav.jsp"
/>


<!-- =========================================================
     PAGE
========================================================= -->

<main class="admin-reviews-page">


    <div class="admin-reviews-container">


        <!-- =====================================================
             HEADER
        ====================================================== -->

        <section class="admin-reviews-header">


            <div>


                <div class="admin-reviews-badge">

                    ⭐ Review Administration

                </div>


                <h1 class="admin-reviews-title">

                    Reviews

                </h1>


                <p class="admin-reviews-description">

                    Monitor customer feedback,
                    search reviews, filter ratings
                    and manage inappropriate content.

                </p>


            </div>


            <a
                    href="<%= ctx %>/admin"
                    class="dashboard-button"
            >

                ← Dashboard

            </a>


        </section>


        <!-- =====================================================
             REVIEW STATISTICS
        ====================================================== -->

        <section class="review-stat-grid">


            <!-- TOTAL -->

            <div class="review-stat-card">


                <div class="review-stat-icon">

                    💬

                </div>


                <div class="review-stat-value stat-purple">

                    <%= totalReviewCount %>

                </div>


                <div class="review-stat-label">

                    Total Reviews

                </div>


            </div>


            <!-- AVERAGE -->

            <div class="review-stat-card">


                <div class="review-stat-icon">

                    ⭐

                </div>


                <div class="review-stat-value stat-yellow">

                    <%= String.format(
                            "%.1f",
                            averageRating
                    ) %>

                </div>


                <div class="review-stat-label">

                    Average Rating

                </div>


            </div>


            <!-- FIVE STAR -->

            <div class="review-stat-card">


                <div class="review-stat-icon">

                    🌟

                </div>


                <div class="review-stat-value stat-green">

                    <%= fiveStarCount %>

                </div>


                <div class="review-stat-label">

                    5 Star Reviews

                </div>


            </div>


            <!-- FOUR STAR -->

            <div class="review-stat-card">


                <div class="review-stat-icon">

                    ⭐

                </div>


                <div class="review-stat-value stat-blue">

                    <%= fourStarCount %>

                </div>


                <div class="review-stat-label">

                    4 Star Reviews

                </div>


            </div>


            <!-- THREE STAR -->

            <div class="review-stat-card">


                <div class="review-stat-icon">

                    ⭐

                </div>


                <div class="review-stat-value stat-orange">

                    <%= threeStarCount %>

                </div>


                <div class="review-stat-label">

                    3 Star Reviews

                </div>


            </div>


            <!-- LOW RATINGS -->

            <div class="review-stat-card">


                <div class="review-stat-icon">

                    ⚠️

                </div>


                <div class="review-stat-value stat-red">

                    <%= lowRatingCount %>

                </div>


                <div class="review-stat-label">

                    1–2 Star Reviews

                </div>


            </div>


        </section>


        <!-- =====================================================
             SEARCH + FILTER
        ====================================================== -->

        <section class="review-filter-panel">


            <div class="filter-header">


                <h3>

                    Search & Filter Reviews

                </h3>


                <span class="filter-result-count">

                    <%= filteredCount %>
                    result<%= filteredCount == 1
                        ? ""
                        : "s" %>

                </span>


            </div>


            <form
                    method="get"
                    action="<%= ctx %>/admin/reviews"
                    class="review-filter-form"
            >


                <!-- SEARCH -->

                <div class="search-wrapper review-search-wrapper">


                    <span class="search-icon">

                        🔍

                    </span>


                    <input
                            type="search"
                            name="search"
                            class="review-search"
                            placeholder="Search customer, movie, review ID or comment..."
                            value="<%= HtmlUtil.escape(
                                    search
                            ) %>"
                            autocomplete="off"
                    >


                </div>


                <!-- RATING -->

                <select
                        name="rating"
                        class="review-select"
                >


                    <option
                            value="all"
                            <%= "all".equalsIgnoreCase(
                                    selectedRating
                            )
                                    ? "selected"
                                    : "" %>
                    >

                        All Ratings

                    </option>


                    <option
                            value="5"
                            <%= "5".equals(
                                    selectedRating
                            )
                                    ? "selected"
                                    : "" %>
                    >

                        ★★★★★ 5 Stars

                    </option>


                    <option
                            value="4"
                            <%= "4".equals(
                                    selectedRating
                            )
                                    ? "selected"
                                    : "" %>
                    >

                        ★★★★☆ 4 Stars

                    </option>


                    <option
                            value="3"
                            <%= "3".equals(
                                    selectedRating
                            )
                                    ? "selected"
                                    : "" %>
                    >

                        ★★★☆☆ 3 Stars

                    </option>


                    <option
                            value="2"
                            <%= "2".equals(
                                    selectedRating
                            )
                                    ? "selected"
                                    : "" %>
                    >

                        ★★☆☆☆ 2 Stars

                    </option>


                    <option
                            value="1"
                            <%= "1".equals(
                                    selectedRating
                            )
                                    ? "selected"
                                    : "" %>
                    >

                        ★☆☆☆☆ 1 Star

                    </option>


                </select>


                <!-- FILTER -->

                <button
                        type="submit"
                        class="filter-button"
                >

                    Filter

                </button>


                <!-- RESET -->

                <a
                        href="<%= ctx %>/admin/reviews"
                        class="reset-button"
                >

                    Reset

                </a>


            </form>


        </section>


        <!-- =====================================================
             REVIEW TABLE
        ====================================================== -->

        <section class="review-table-wrapper">


            <table class="review-table">


                <thead>


                <tr>

                    <th>
                        Customer
                    </th>

                    <th>
                        Movie
                    </th>

                    <th>
                        Rating
                    </th>

                    <th>
                        Comment
                    </th>

                    <th>
                        Date
                    </th>

                    <th>
                        Action
                    </th>

                </tr>


                </thead>


                <tbody>


                <%
                    if (
                            reviews == null
                                    ||
                                    reviews.isEmpty()
                    ) {
                %>


                <!-- =================================================
                     EMPTY
                ================================================== -->

                <tr>


                    <td
                            colspan="6"
                            class="review-empty"
                    >


                        <div class="review-empty-icon">

                            🔍

                        </div>


                        <strong>

                            No reviews found.

                        </strong>


                        <div
                                style="
                                    margin-top:7px;
                                "
                        >

                            Try changing your
                            search or rating filter.

                        </div>


                    </td>


                </tr>


                <%
                } else {


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


                        String customerName =
                                user != null
                                        &&
                                        user.getName() != null
                                        &&
                                        !user.getName()
                                                .trim()
                                                .isEmpty()
                                        ? user.getName()
                                        : review.getUserId();


                        String customerEmail =
                                user != null
                                        &&
                                        user.getEmail() != null
                                        ? user.getEmail()
                                        : "";


                        String customerInitial =
                                "C";


                        if (
                                customerName != null
                                        &&
                                        !customerName
                                                .trim()
                                                .isEmpty()
                        ) {

                            customerInitial =
                                    customerName
                                            .trim()
                                            .substring(
                                                    0,
                                                    1
                                            )
                                            .toUpperCase();
                        }


                        String movieTitle =
                                movie != null
                                        &&
                                        movie.getTitle() != null
                                        ? movie.getTitle()
                                        : review.getMovieId();


                        String movieId =
                                review.getMovieId() == null
                                        ? ""
                                        : review.getMovieId();
                %>


                <!-- =================================================
                     REVIEW ROW
                ================================================== -->

                <tr>


                    <!-- =============================================
                         CUSTOMER
                    ============================================== -->

                    <td>


                        <div class="customer-cell">


                            <div class="customer-avatar">

                                <%= HtmlUtil.escape(
                                        customerInitial
                                ) %>

                            </div>


                            <div>


                                <div class="customer-name">

                                    <%= HtmlUtil.escape(
                                            customerName
                                    ) %>

                                </div>


                                <div class="customer-meta">

                                    ID:
                                    <%= HtmlUtil.escape(
                                            review.getUserId()
                                    ) %>


                                    <%
                                        if (
                                                customerEmail != null
                                                        &&
                                                        !customerEmail
                                                                .trim()
                                                                .isEmpty()
                                        ) {
                                    %>

                                    <br>

                                    <%= HtmlUtil.escape(
                                            customerEmail
                                    ) %>

                                    <%
                                        }
                                    %>


                                </div>


                            </div>


                        </div>


                    </td>


                    <!-- =============================================
                         MOVIE
                    ============================================== -->

                    <td>


                        <div class="movie-cell">


                            <div class="movie-poster-small">


                                <img
                                        src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(
                                                movieId
                                        ) %>"

                                        alt="<%= HtmlUtil.escape(
                                                movieTitle
                                        ) %>"

                                        loading="lazy"

                                        onerror="
                                                this.onerror=null;
                                                this.src='<%= ctx %>/images/posters/default.svg';
                                                "
                                >


                            </div>


                            <div>


                                <div class="movie-name">

                                    <%= HtmlUtil.escape(
                                            movieTitle
                                    ) %>

                                </div>


                                <div class="movie-id">

                                    ID:
                                    <%= HtmlUtil.escape(
                                            movieId
                                    ) %>

                                </div>


                            </div>


                        </div>


                    </td>


                    <!-- =============================================
                         RATING
                    ============================================== -->

                    <td>


                        <div class="rating-stars">


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


                        <div class="rating-number">

                            <%= review.getRating() %>
                            / 5

                        </div>


                    </td>


                    <!-- =============================================
                         COMMENT
                    ============================================== -->

                    <td>


                        <div class="review-comment-cell">

                            <%
                                if (
                                        review.getComment()
                                                == null
                                                ||
                                                review.getComment()
                                                        .trim()
                                                        .isEmpty()
                                ) {
                            %>

                            <span
                                    style="
                                        color:#64748b;
                                    "
                            >

                                No comment

                            </span>

                            <%
                            } else {
                            %>

                            <%= HtmlUtil.escape(
                                    review.getComment()
                            ) %>

                            <%
                                }
                            %>


                        </div>


                    </td>


                    <!-- =============================================
                         DATE
                    ============================================== -->

                    <td>


                        <div class="review-date">

                            <%= HtmlUtil.escape(
                                    review.getReviewDate()
                            ) %>

                        </div>


                        <div class="review-id">

                            <%= HtmlUtil.escape(
                                    review.getReviewId()
                            ) %>

                        </div>


                    </td>


                    <!-- =============================================
                         ACTION
                    ============================================== -->

                    <td>


                        <form
                                method="post"
                                action="<%= ctx %>/admin/reviews"
                                class="delete-review-form"
                                data-confirm="Are you sure you want to delete this customer review?"
                        >


                            <input
                                    type="hidden"
                                    name="action"
                                    value="delete"
                            >


                            <input
                                    type="hidden"
                                    name="reviewId"
                                    value="<%= HtmlUtil.escape(
                                            review.getReviewId()
                                    ) %>"
                            >


                            <button
                                    type="submit"
                                    class="delete-review-button"
                            >

                                🗑 Delete

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


        </section>


        <!-- =====================================================
             INFO
        ====================================================== -->

        <div class="review-summary">


            <div class="summary-icon">

                💡

            </div>


            <div>

                Showing

                <strong>
                    <%= filteredCount %>
                </strong>

                of

                <strong>
                    <%= totalReviewCount %>
                </strong>

                customer reviews.

                Deleting a review will also allow
                CineRent to recalculate that movie's
                average rating.

            </div>


        </div>


    </div>


</main>


<!-- =========================================================
     FOOTER
========================================================= -->

<jsp:include
        page="/WEB-INF/views/partials/footer.jsp"
/>


<script
        src="<%= ctx %>/js/app.js"
></script>


</body>

</html>