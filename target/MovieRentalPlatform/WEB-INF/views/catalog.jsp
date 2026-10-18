<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx =
            request.getContextPath();


    List<Movie> movies =
            (List<Movie>)
                    request.getAttribute(
                            "movies"
                    );


    String selectedSort =
            (String)
                    request.getAttribute(
                            "selectedSort"
                    );


    String error =
            request.getParameter(
                    "error"
            );


    String userName =
            (String)
                    session.getAttribute(
                            "userName"
                    );


    String role =
            (String)
                    session.getAttribute(
                            "role"
                    );


    // =========================================================
    // SECURITY
    // =========================================================

    if (
            userName == null
                    ||
                    role == null
    ) {

        response.sendRedirect(
                ctx + "/login"
        );

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


    if (selectedSort == null) {

        selectedSort = "";
    }


    // =========================================================
    // COUNTS
    // =========================================================

    int movieCount =
            movies == null
                    ? 0
                    : movies.size();


    int availableMovieCount =
            0;


    if (movies != null) {

        for (Movie movie : movies) {

            if (
                    movie.getAvailableCopies()
                            > 0
            ) {

                availableMovieCount++;
            }
        }
    }


    // =========================================================
    // USER INITIAL
    // =========================================================

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
        Movie Catalogue | CineRent
    </title>


    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <style>

        /* =====================================================
           ROOT
        ====================================================== */

        body {
            margin: 0;

            background:
                    #050811;

            color:
                    #ffffff;
        }


        .catalog-page {
            min-height:
                    calc(100vh - 76px);

            padding:
                    46px
                    0
                    80px;

            background:

                    radial-gradient(
                            circle at 78% 4%,
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.16
                            ),
                            transparent 29%
                    ),

                    radial-gradient(
                            circle at 8% 50%,
                            rgba(
                                    37,
                                    99,
                                    235,
                                    0.08
                            ),
                            transparent 24%
                    ),

                    #050811;
        }


        .catalog-container {
            width:
                    92%;

            max-width:
                    1450px;

            margin:
                    0 auto;
        }


        /* =====================================================
           NAVBAR
        ====================================================== */

        .catalog-navbar {
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


        .catalog-navbar-inner {
            width:
                    92%;

            max-width:
                    1450px;

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


        .catalog-brand {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    11px;

            color:
                    #ffffff;

            text-decoration:
                    none;

            font-size:
                    21px;

            font-weight:
                    850;

            letter-spacing:
                    -0.5px;
        }


        .catalog-brand-icon {
            width:
                    41px;

            height:
                    41px;

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

            font-weight:
                    900;
        }


        .catalog-nav-links {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    6px;

            margin-left:
                    auto;
        }


        .catalog-nav-link {
            position:
                    relative;

            padding:
                    10px
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


        .catalog-nav-link:hover {
            color:
                    #ffffff;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.05
                    );
        }


        .catalog-nav-link.active {
            color:
                    #ffffff;
        }


        .catalog-nav-link.active::after {
            content: "";

            position:
                    absolute;

            left:
                    12px;

            right:
                    12px;

            bottom:
                    -15px;

            height:
                    2px;

            border-radius:
                    999px;

            background:
                    linear-gradient(
                            90deg,
                            #7c3aed,
                            #a78bfa
                    );
        }


        /* =====================================================
           USER
        ====================================================== */

        .catalog-profile {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    10px;

            margin-left:
                    10px;
        }


        .catalog-avatar {
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


        .catalog-user-name {
            max-width:
                    135px;

            overflow:
                    hidden;

            text-overflow:
                    ellipsis;

            white-space:
                    nowrap;

            color:
                    #cbd5e1;

            font-size:
                    11px;
        }


        .catalog-logout {
            padding:
                    8px
                    12px;

            border-radius:
                    8px;

            color:
                    #cbd5e1;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.10
                    );

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
                    10px;

            font-weight:
                    750;
        }


        /* =====================================================
           HERO
        ====================================================== */

        .catalog-hero {
            position:
                    relative;

            overflow:
                    hidden;

            display:
                    grid;

            grid-template-columns:
                    minmax(
                            0,
                            1fr
                    )
                    auto;

            gap:
                    35px;

            align-items:
                    center;

            margin-bottom:
                    30px;

            padding:
                    35px;

            border-radius:
                    24px;

            background:

                    radial-gradient(
                            circle at 85% 30%,
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.22
                            ),
                            transparent 32%
                    ),

                    linear-gradient(
                            135deg,
                            rgba(
                                    23,
                                    33,
                                    54,
                                    0.88
                            ),
                            rgba(
                                    10,
                                    15,
                                    27,
                                    0.82
                            )
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


        .catalog-hero-badge {
            display:
                    inline-flex;

            align-items:
                    center;

            gap:
                    7px;

            margin-bottom:
                    14px;

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
                    9px;

            font-weight:
                    800;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.7px;
        }


        .catalog-title {
            margin: 0;

            max-width:
                    750px;

            font-size:
                    clamp(
                            38px,
                            5vw,
                            58px
                    );

            line-height:
                    1.05;

            letter-spacing:
                    -2.2px;
        }


        .catalog-title span {
            color:
                    transparent;

            background:
                    linear-gradient(
                            90deg,
                            #a78bfa,
                            #60a5fa
                    );

            -webkit-background-clip:
                    text;

            background-clip:
                    text;
        }


        .catalog-description {
            max-width:
                    700px;

            margin:
                    13px
                    0
                    0;

            color:
                    #94a3b8;

            line-height:
                    1.75;

            font-size:
                    13px;
        }


        /* =====================================================
           HERO STATS
        ====================================================== */

        .catalog-hero-stats {
            display:
                    grid;

            grid-template-columns:
                    repeat(
                            2,
                            145px
                    );

            gap:
                    12px;
        }


        .catalog-stat {
            padding:
                    18px;

            border-radius:
                    15px;

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.65
                    );

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.07
                    );
        }


        .catalog-stat-number {
            display:
                    block;

            margin-bottom:
                    5px;

            color:
                    #a78bfa;

            font-size:
                    26px;

            font-weight:
                    850;
        }


        .catalog-stat.available
        .catalog-stat-number {
            color:
                    #4ade80;
        }


        .catalog-stat-label {
            color:
                    #64748b;

            font-size:
                    9px;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.6px;
        }


        /* =====================================================
           ALERT
        ====================================================== */

        .catalog-alert {
            margin-bottom:
                    18px;

            padding:
                    13px
                    15px;

            border-radius:
                    11px;

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

            font-size:
                    11px;
        }


        .catalog-alert.info {
            color:
                    #93c5fd;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.07
                    );

            border-color:
                    rgba(
                            59,
                            130,
                            246,
                            0.15
                    );
        }


        /* =====================================================
           CONTROLS
        ====================================================== */

        .catalog-controls {
            display:
                    grid;

            grid-template-columns:
                    minmax(
                            260px,
                            1.2fr
                    )
                    minmax(
                            0,
                            2fr
                    )
                    auto;

            gap:
                    15px;

            align-items:
                    center;

            margin-bottom:
                    27px;

            padding:
                    16px;

            border-radius:
                    17px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.58
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.09
                    );
        }


        /* =====================================================
           SEARCH
        ====================================================== */

        .catalog-search-wrapper {
            position:
                    relative;
        }


        .catalog-search-icon {
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

            font-size:
                    13px;
        }


        .catalog-search {
            width:
                    100%;

            min-height:
                    43px;

            padding:
                    0
                    14px
                    0
                    41px;

            border-radius:
                    10px;

            outline:
                    none;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.15
                    );

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.74
                    );

            color:
                    #ffffff;

            font-family:
                    inherit;
        }


        .catalog-search:focus {
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


        /* =====================================================
           SORT
        ====================================================== */

        .catalog-sort-group {
            display:
                    flex;

            align-items:
                    center;

            flex-wrap:
                    wrap;

            gap:
                    8px;
        }


        .catalog-sort-label {
            margin-right:
                    3px;

            color:
                    #64748b;

            font-size:
                    9px;

            font-weight:
                    750;

            text-transform:
                    uppercase;
        }


        .catalog-sort-link {
            min-height:
                    37px;

            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            gap:
                    5px;

            padding:
                    0
                    12px;

            border-radius:
                    9px;

            text-decoration:
                    none;

            color:
                    #94a3b8;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.03
                    );

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.07
                    );

            font-size:
                    10px;

            font-weight:
                    700;

            transition:
                    0.2s ease;
        }


        .catalog-sort-link:hover {
            color:
                    #ffffff;

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.30
                    );
        }


        .catalog-sort-link.active {
            color:
                    #ffffff;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.15
                    );

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.32
                    );
        }


        /* =====================================================
           RENTALS BUTTON
        ====================================================== */

        .my-rentals-button {
            min-height:
                    43px;

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
                    15px;

            border-radius:
                    10px;

            color:
                    #ffffff;

            text-decoration:
                    none;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6
                    );

            font-size:
                    10px;

            font-weight:
                    800;

            white-space:
                    nowrap;
        }


        /* =====================================================
           RESULTS HEADER
        ====================================================== */

        .catalog-results-header {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap:
                    15px;

            margin:
                    0
                    0
                    18px;
        }


        .catalog-results-header h2 {
            margin: 0;

            font-size:
                    20px;
        }


        .catalog-result-count {
            color:
                    #64748b;

            font-size:
                    10px;
        }


        .catalog-result-count strong {
            color:
                    #c4b5fd;
        }


        /* =====================================================
           MOVIE GRID
        ====================================================== */

        .catalog-movie-grid {
            display:
                    grid;

            grid-template-columns:
                    repeat(
                            auto-fill,
                            minmax(
                                    250px,
                                    1fr
                            )
                    );

            gap:
                    22px;
        }


        /* =====================================================
           MOVIE CARD
        ====================================================== */

        .catalog-movie-card {
            position:
                    relative;

            overflow:
                    hidden;

            display:
                    flex;

            flex-direction:
                    column;

            min-width:
                    0;

            border-radius:
                    19px;

            background:
                    rgba(
                            16,
                            24,
                            40,
                            0.78
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.10
                    );

            box-shadow:
                    0
                    15px
                    40px
                    rgba(
                            0,
                            0,
                            0,
                            0.16
                    );

            transition:
                    transform
                    0.25s ease,
                    border-color
                    0.25s ease,
                    box-shadow
                    0.25s ease;
        }


        .catalog-movie-card:hover {
            transform:
                    translateY(-6px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.32
                    );

            box-shadow:
                    0
                    25px
                    55px
                    rgba(
                            0,
                            0,
                            0,
                            0.28
                    );
        }


        /* =====================================================
           POSTER
        ====================================================== */

        .catalog-poster-wrapper {
            position:
                    relative;

            width:
                    100%;

            aspect-ratio:
                    2 / 3;

            overflow:
                    hidden;

            background:
                    #111827;
        }


        .catalog-poster {
            width:
                    100%;

            height:
                    100%;

            display:
                    block;

            object-fit:
                    cover;

            transition:
                    transform
                    0.35s ease;
        }


        .catalog-movie-card:hover
        .catalog-poster {
            transform:
                    scale(1.045);
        }


        .catalog-poster-overlay {
            position:
                    absolute;

            inset: 0;

            background:
                    linear-gradient(
                            to top,
                            rgba(
                                    5,
                                    8,
                                    17,
                                    0.85
                            ),
                            transparent 45%
                    );
        }


        .movie-id-badge {
            position:
                    absolute;

            z-index:
                    3;

            left:
                    12px;

            top:
                    12px;

            padding:
                    6px
                    9px;

            border-radius:
                    8px;

            color:
                    #ffffff;

            background:
                    rgba(
                            0,
                            0,
                            0,
                            0.68
                    );

            font-size:
                    9px;

            font-weight:
                    800;

            backdrop-filter:
                    blur(8px);
        }


        .movie-rating-badge {
            position:
                    absolute;

            z-index:
                    3;

            right:
                    12px;

            top:
                    12px;

            padding:
                    6px
                    9px;

            border-radius:
                    8px;

            color:
                    #facc15;

            background:
                    rgba(
                            0,
                            0,
                            0,
                            0.68
                    );

            font-size:
                    9px;

            font-weight:
                    800;

            backdrop-filter:
                    blur(8px);
        }


        /* =====================================================
           BODY
        ====================================================== */

        .catalog-card-body {
            display:
                    flex;

            flex-direction:
                    column;

            flex:
                    1;

            padding:
                    19px;
        }


        .catalog-movie-title {
            margin:
                    0
                    0
                    7px;

            color:
                    #ffffff;

            font-size:
                    17px;

            font-weight:
                    850;

            letter-spacing:
                    -0.3px;
        }


        .catalog-movie-meta {
            display:
                    flex;

            align-items:
                    center;

            flex-wrap:
                    wrap;

            gap:
                    6px;

            color:
                    #64748b;

            font-size:
                    10px;
        }


        .genre-pill {
            padding:
                    4px
                    7px;

            border-radius:
                    999px;

            color:
                    #c4b5fd;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.09
                    );
        }


        .catalog-movie-description {
            min-height:
                    61px;

            margin:
                    15px
                    0
                    0;

            color:
                    #94a3b8;

            font-size:
                    11px;

            line-height:
                    1.65;

            display:
                    -webkit-box;

            -webkit-box-orient:
                    vertical;

            -webkit-line-clamp:
                    3;

            overflow:
                    hidden;
        }


        /* =====================================================
           PRICE / STOCK
        ====================================================== */

        .catalog-card-info {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    flex-end;

            gap:
                    12px;

            margin-top:
                    auto;

            padding-top:
                    17px;

            border-top:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.08
                    );
        }


        .catalog-price-label {
            margin-bottom:
                    3px;

            color:
                    #64748b;

            font-size:
                    8px;

            text-transform:
                    uppercase;
        }


        .catalog-price {
            color:
                    #ffffff;

            font-size:
                    14px;

            font-weight:
                    850;
        }


        .catalog-price small {
            color:
                    #64748b;

            font-size:
                    8px;

            font-weight:
                    500;
        }


        .availability-pill {
            display:
                    inline-flex;

            align-items:
                    center;

            gap:
                    5px;

            padding:
                    6px
                    8px;

            border-radius:
                    999px;

            font-size:
                    8px;

            font-weight:
                    800;
        }


        .availability-pill.available {
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


        .availability-pill.unavailable {
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


        /* =====================================================
           ACTIONS
        ====================================================== */

        .catalog-card-actions {
            display:
                    grid;

            grid-template-columns:
                    1fr
                    1fr;

            gap:
                    9px;

            margin-top:
                    17px;
        }


        .catalog-card-actions form {
            margin: 0;
        }


        .catalog-action-button {
            width:
                    100%;

            min-height:
                    39px;

            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            gap:
                    6px;

            border-radius:
                    9px;

            text-decoration:
                    none;

            border:
                    none;

            font-family:
                    inherit;

            font-size:
                    10px;

            font-weight:
                    800;

            cursor:
                    pointer;
        }


        .review-button {
            color:
                    #fef3c7;

            background:
                    rgba(
                            234,
                            179,
                            8,
                            0.07
                    );

            border:
                    1px solid
                    rgba(
                            234,
                            179,
                            8,
                            0.16
                    );
        }


        .rent-button {
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
                    8px
                    20px
                    rgba(
                            124,
                            58,
                            237,
                            0.18
                    );
        }


        .rent-button:disabled {
            cursor:
                    not-allowed;

            opacity:
                    0.45;

            box-shadow:
                    none;
        }


        /* =====================================================
           EMPTY / SEARCH EMPTY
        ====================================================== */

        .catalog-empty {
            grid-column:
                    1 / -1;

            padding:
                    70px
                    25px;

            text-align:
                    center;

            border-radius:
                    20px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.56
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.09
                    );
        }


        .catalog-empty-icon {
            margin-bottom:
                    14px;

            font-size:
                    45px;
        }


        .catalog-empty h3 {
            margin:
                    0
                    0
                    8px;
        }


        .catalog-empty p {
            margin: 0;

            color:
                    #94a3b8;

            font-size:
                    12px;
        }


        .catalog-search-empty {
            display:
                    none;

            margin-top:
                    20px;

            padding:
                    28px;

            text-align:
                    center;

            border-radius:
                    16px;

            color:
                    #94a3b8;

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
        }


        /* =====================================================
           FOOTER
        ====================================================== */

        .catalog-footer {
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


        .catalog-footer-inner {
            width:
                    92%;

            max-width:
                    1450px;

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


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (
        max-width: 1100px
        ) {

            .catalog-controls {
                grid-template-columns:
                        1fr;
            }


            .catalog-hero {
                grid-template-columns:
                        1fr;
            }


            .catalog-hero-stats {
                grid-template-columns:
                        1fr
                        1fr;

                max-width:
                        320px;
            }

        }


        @media (
        max-width: 850px
        ) {

            .catalog-nav-links {
                display:
                        none;
            }


            .catalog-movie-grid {
                grid-template-columns:
                        repeat(
                                2,
                                minmax(
                                        0,
                                        1fr
                                )
                        );
            }

        }


        @media (
        max-width: 600px
        ) {

            .catalog-profile-name {
                display:
                        none;
            }


            .catalog-hero {
                padding:
                        24px;
            }


            .catalog-title {
                font-size:
                        37px;
            }


            .catalog-hero-stats {
                width:
                        100%;

                max-width:
                        none;
            }


            .catalog-movie-grid {
                grid-template-columns:
                        1fr;
            }


            .catalog-card-actions {
                grid-template-columns:
                        1fr;
            }


            .catalog-results-header {
                align-items:
                        flex-start;

                flex-direction:
                        column;
            }


            .catalog-footer-inner {
                flex-direction:
                        column;

                justify-content:
                        center;

                gap:
                        5px;

                padding:
                        15px
                        0;
            }

        }

    </style>

</head>


<body>


<!-- =========================================================
     NAVIGATION
========================================================= -->

<header class="catalog-navbar">


    <div class="catalog-navbar-inner">


        <!-- CINE RENT HOME LINK -->

        <a
                href="<%= ctx %>/"
                class="catalog-brand"
        >


            <span class="catalog-brand-icon">

                C

            </span>


            CineRent

        </a>


        <!-- LINKS -->

        <nav class="catalog-nav-links">


            <a
                    href="<%= ctx %>/"
                    class="catalog-nav-link"
            >

                Home

            </a>


            <a
                    href="<%= ctx %>/catalog"
                    class="catalog-nav-link active"
            >

                Movies

            </a>


            <a
                    href="<%= ctx %>/rentals"
                    class="catalog-nav-link"
            >

                My Rentals

            </a>


            <a
                    href="<%= ctx %>/recently-watched"
                    class="catalog-nav-link"
            >

                Recently Watched

            </a>


        </nav>


        <!-- USER -->

        <div class="catalog-profile">


            <div class="catalog-avatar">

                <%= HtmlUtil.escape(
                        userInitial
                ) %>

            </div>


            <span class="catalog-user-name">

                Hi,
                <%= HtmlUtil.escape(
                        userName
                ) %>

            </span>


            <a
                    href="<%= ctx %>/logout"
                    class="catalog-logout"
            >

                Logout

            </a>


        </div>


    </div>


</header>


<!-- =========================================================
     PAGE
========================================================= -->

<main class="catalog-page">


    <div class="catalog-container">


        <!-- =====================================================
             HERO
        ====================================================== -->

        <section class="catalog-hero">


            <div>


                <div class="catalog-hero-badge">

                    🎬 Customer Catalogue

                </div>


                <h1 class="catalog-title">

                    Discover your
                    <span>
                        next movie.
                    </span>

                </h1>


                <p class="catalog-description">

                    Explore CineRent's movie collection,
                    compare ratings, discover new titles
                    and rent your next movie in seconds.

                </p>


            </div>


            <div class="catalog-hero-stats">


                <div class="catalog-stat">


                    <span class="catalog-stat-number">

                        <%= movieCount %>

                    </span>


                    <span class="catalog-stat-label">

                        Movies

                    </span>


                </div>


                <div class="catalog-stat available">


                    <span class="catalog-stat-number">

                        <%= availableMovieCount %>

                    </span>


                    <span class="catalog-stat-label">

                        Available Now

                    </span>


                </div>


            </div>


        </section>


        <!-- =====================================================
             ERRORS
        ====================================================== -->

        <%
            if (
                    "notfound".equalsIgnoreCase(
                            error
                    )
            ) {
        %>


        <div
                class="catalog-alert"
                data-auto-hide
        >

            The selected movie could not be found.

        </div>


        <%
        } else if (
                "unavailable".equalsIgnoreCase(
                        error
                )
        ) {
        %>


        <div
                class="catalog-alert"
                data-auto-hide
        >

            This movie currently has no available copies.

        </div>


        <%
        } else if (
                "alreadyrented".equalsIgnoreCase(
                        error
                )
        ) {
        %>


        <div
                class="catalog-alert info"
                data-auto-hide
        >

            You already have this movie rented.
            Return it before renting it again.

        </div>


        <%
            }
        %>


        <!-- =====================================================
             CONTROLS
        ====================================================== -->

        <section class="catalog-controls">


            <!-- SEARCH -->

            <div class="catalog-search-wrapper">


                <span class="catalog-search-icon">

                    🔍

                </span>


                <input
                        type="search"
                        id="catalogSearch"
                        class="catalog-search"
                        placeholder="Search movie title, genre or year..."
                        autocomplete="off"
                >


            </div>


            <!-- SORT -->

            <div class="catalog-sort-group">


                <span class="catalog-sort-label">

                    Sort by

                </span>


                <a
                        href="<%= ctx %>/catalog"
                        class="catalog-sort-link
                        <%= selectedSort.trim().isEmpty()
                                ? "active"
                                : "" %>"
                >

                    Default

                </a>


                <a
                        href="<%= ctx %>/catalog?sort=rating-desc"
                        class="catalog-sort-link
                        <%= "rating-desc".equalsIgnoreCase(
                                selectedSort
                        )
                                ? "active"
                                : "" %>"
                >

                    ⭐ Highest Rated

                </a>


                <a
                        href="<%= ctx %>/catalog?sort=rating-asc"
                        class="catalog-sort-link
                        <%= "rating-asc".equalsIgnoreCase(
                                selectedSort
                        )
                                ? "active"
                                : "" %>"
                >

                    ☆ Lowest Rated

                </a>


            </div>


            <!-- RENTALS -->

            <a
                    href="<%= ctx %>/rentals"
                    class="my-rentals-button"
            >

                📀 My Rentals

            </a>


        </section>


        <!-- =====================================================
             RESULT TITLE
        ====================================================== -->

        <div class="catalog-results-header">


            <h2>

                Available Movies

            </h2>


            <div class="catalog-result-count">

                Showing

                <strong id="catalogResultCount">

                    <%= movieCount %>

                </strong>

                movie(s)

            </div>


        </div>


        <!-- =====================================================
             MOVIES
        ====================================================== -->

        <section class="catalog-movie-grid">


            <%
                if (
                        movies == null
                                ||
                                movies.isEmpty()
                ) {
            %>


            <!-- EMPTY -->

            <div class="catalog-empty">


                <div class="catalog-empty-icon">

                    🎬

                </div>


                <h3>

                    No movies available.

                </h3>


                <p>

                    The CineRent catalogue is
                    currently empty.

                </p>


            </div>


            <%
            } else {


                for (
                        Movie movie : movies
                ) {


                    boolean available =
                            movie.getAvailableCopies()
                                    > 0;
            %>


            <!-- =================================================
                 MOVIE CARD
            ================================================== -->

            <article
                    class="catalog-movie-card"

                    data-catalog-card

                    data-search="<%= HtmlUtil.escape(
                            movie.getMovieId()
                            + " "
                            + movie.getTitle()
                            + " "
                            + movie.getGenre()
                            + " "
                            + movie.getReleaseYear()
                    ) %>"
            >


                <!-- =============================================
                     POSTER
                ============================================== -->

                <div class="catalog-poster-wrapper">


                    <img
                            class="catalog-poster"

                            src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(
                                    movie.getMovieId()
                            ) %>"

                            alt="<%= HtmlUtil.escape(
                                    movie.getTitle()
                            ) %>"

                            loading="lazy"

                            onerror="
                                    this.onerror=null;
                                    this.src='<%= ctx %>/images/posters/default.svg';
                                    "
                    >


                    <div class="catalog-poster-overlay"></div>


                    <span class="movie-id-badge">

                        <%= HtmlUtil.escape(
                                movie.getMovieId()
                        ) %>

                    </span>


                    <span class="movie-rating-badge">

                        ⭐

                        <%= String.format(
                                "%.1f",
                                movie.getRating()
                        ) %>

                    </span>


                </div>


                <!-- =============================================
                     BODY
                ============================================== -->

                <div class="catalog-card-body">


                    <h3 class="catalog-movie-title">

                        <%= HtmlUtil.escape(
                                movie.getTitle()
                        ) %>

                    </h3>


                    <div class="catalog-movie-meta">


                        <span class="genre-pill">

                            <%= HtmlUtil.escape(
                                    movie.getGenre()
                            ) %>

                        </span>


                        <span>

                            <%= movie.getReleaseYear() %>

                        </span>


                    </div>


                    <!-- DESCRIPTION -->

                    <div class="catalog-movie-description">


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


                    </div>


                    <!-- =========================================
                         PRICE + AVAILABILITY
                    ========================================== -->

                    <div class="catalog-card-info">


                        <div>


                            <div class="catalog-price-label">

                                Rental Price

                            </div>


                            <div class="catalog-price">

                                LKR

                                <%= String.format(
                                        "%.2f",
                                        movie.getRentalPrice()
                                ) %>

                                <small>

                                    / rental

                                </small>


                            </div>


                        </div>


                        <div>


                            <span
                                    class="availability-pill
                                    <%= available
                                            ? "available"
                                            : "unavailable" %>"
                            >


                                <%= available
                                        ? "✓ "
                                        + movie.getAvailableCopies()
                                        + " available"
                                        : "✕ Unavailable" %>


                            </span>


                        </div>


                    </div>


                    <!-- =========================================
                         ACTIONS
                    ========================================== -->

                    <div class="catalog-card-actions">


                        <!-- REVIEWS -->

                        <a
                                href="<%= ctx %>/reviews?movieId=<%= HtmlUtil.escape(
                                        movie.getMovieId()
                                ) %>"

                                class="catalog-action-button review-button"
                        >

                            ⭐ Reviews

                        </a>


                        <!-- RENT -->

                        <form
                                method="post"
                                action="<%= ctx %>/rentals"
                        >


                            <input
                                    type="hidden"
                                    name="action"
                                    value="rent"
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
                                    class="catalog-action-button rent-button"

                                    <%= available
                                            ? ""
                                            : "disabled" %>
                            >

                                <%= available
                                        ? "▶ Rent Movie"
                                        : "Unavailable" %>

                            </button>


                        </form>


                    </div>


                </div>


            </article>


            <%
                    }
                }
            %>


        </section>


        <!-- SEARCH EMPTY -->

        <div
                id="catalogSearchEmpty"
                class="catalog-search-empty"
        >

            🔍 No movies match your search.

        </div>


    </div>


</main>


<!-- =========================================================
     FOOTER
========================================================= -->

<footer class="catalog-footer">


    <div class="catalog-footer-inner">


        <div>

            © 2026 CineRent

        </div>


        <div>

            Browse • Rent • Watch • Review

        </div>


    </div>


</footer>


<!-- =========================================================
     CATALOG SEARCH
========================================================= -->

<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {


            const searchInput =
                document.getElementById(
                    "catalogSearch"
                );


            const movieCards =
                document.querySelectorAll(
                    "[data-catalog-card]"
                );


            const resultCount =
                document.getElementById(
                    "catalogResultCount"
                );


            const emptyMessage =
                document.getElementById(
                    "catalogSearchEmpty"
                );


            if (!searchInput) {
                return;
            }


            searchInput.addEventListener(
                "input",
                function () {


                    const query =
                        searchInput
                            .value
                            .trim()
                            .toLowerCase();


                    let visible =
                        0;


                    movieCards.forEach(
                        function (card) {


                            const searchData =
                                (
                                    card.getAttribute(
                                        "data-search"
                                    )
                                    ||
                                    card.textContent
                                )
                                    .toLowerCase();


                            const matches =
                                query === ""
                                ||
                                searchData.includes(
                                    query
                                );


                            card.style.display =
                                matches
                                    ? ""
                                    : "none";


                            if (matches) {

                                visible++;

                            }

                        }
                    );


                    if (resultCount) {

                        resultCount.textContent =
                            visible;

                    }


                    if (emptyMessage) {

                        emptyMessage.style.display =
                            visible === 0
                            &&
                            movieCards.length > 0
                                ? "block"
                                : "none";

                    }

                }
            );

        }
    );

</script>


<script
        src="<%= ctx %>/js/app.js"
></script>


</body>

</html>