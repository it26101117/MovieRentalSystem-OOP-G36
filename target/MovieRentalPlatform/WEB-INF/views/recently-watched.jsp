<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>

<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx =
            request.getContextPath();


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


    // =========================================================
    // GET RECENTLY WATCHED MOVIES
    //
    // This supports different possible attribute names so that
    // you do not have to immediately change your servlet.
    // =========================================================

    Object historyObject =
            request.getAttribute(
                    "watchedMovies"
            );


    if (historyObject == null) {

        historyObject =
                request.getAttribute(
                        "recentMovies"
                );
    }


    if (historyObject == null) {

        historyObject =
                request.getAttribute(
                        "recentlyWatchedMovies"
                );
    }


    if (historyObject == null) {

        historyObject =
                request.getAttribute(
                        "movies"
                );
    }


    if (historyObject == null) {

        historyObject =
                request.getAttribute(
                        "history"
                );
    }


    List<Movie> watchedMovies =
            new ArrayList<Movie>();


    if (
            historyObject
                    instanceof List<?>
    ) {

        List<?> rawList =
                (List<?>) historyObject;


        for (Object item : rawList) {

            if (
                    item
                            instanceof Movie
            ) {

                watchedMovies.add(
                        (Movie) item
                );
            }
        }
    }


    // =========================================================
    // LATEST / STACK TOP MOVIE
    // =========================================================

    Movie latestMovie =
            null;


    Object latestObject =
            request.getAttribute(
                    "latestMovie"
            );


    if (
            latestObject
                    instanceof Movie
    ) {

        latestMovie =
                (Movie) latestObject;
    }


    if (latestMovie == null) {

        Object topObject =
                request.getAttribute(
                        "topMovie"
                );


        if (
                topObject
                        instanceof Movie
        ) {

            latestMovie =
                    (Movie) topObject;
        }
    }


    if (
            latestMovie == null
                    &&
                    !watchedMovies.isEmpty()
    ) {

        latestMovie =
                watchedMovies.get(0);
    }


    if (
            watchedMovies.isEmpty()
                    &&
                    latestMovie != null
    ) {

        watchedMovies.add(
                latestMovie
        );
    }


    int watchedCount =
            watchedMovies.size();


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
        Recently Watched | CineRent
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
            margin: 0;

            background:
                    #050811;

            color:
                    #ffffff;
        }


        .history-page {
            min-height:
                    calc(100vh - 75px);

            padding:
                    48px
                    0
                    80px;

            background:

                    radial-gradient(
                            circle at 75% 7%,
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.17
                            ),
                            transparent 28%
                    ),

                    radial-gradient(
                            circle at 10% 45%,
                            rgba(
                                    37,
                                    99,
                                    235,
                                    0.09
                            ),
                            transparent 25%
                    );
        }


        .history-container {
            width:
                    92%;

            max-width:
                    1380px;

            margin:
                    0 auto;
        }


        /* =====================================================
           NAVIGATION
        ====================================================== */

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
                            0.88
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

            letter-spacing:
                    -0.5px;
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


        .customer-nav-link:hover,
        .customer-nav-link.active {
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
                    135px;

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


        .customer-logout:hover {
            color:
                    #fca5a5;

            border-color:
                    rgba(
                            239,
                            68,
                            68,
                            0.30
                    );
        }


        /* =====================================================
           HEADER
        ====================================================== */

        .history-header {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    flex-end;

            gap:
                    30px;

            margin-bottom:
                    32px;
        }


        .history-badge {
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

            letter-spacing:
                    0.6px;
        }


        .history-title {
            margin: 0;

            font-size:
                    clamp(
                            34px,
                            4vw,
                            50px
                    );

            letter-spacing:
                    -1.7px;
        }


        .history-description {
            max-width:
                    650px;

            margin:
                    10px
                    0
                    0;

            color:
                    #94a3b8;

            line-height:
                    1.75;

            font-size:
                    14px;
        }


        .history-count {
            min-width:
                    130px;

            padding:
                    16px
                    20px;

            border-radius:
                    15px;

            text-align:
                    center;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.72
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


        .history-count-number {
            display:
                    block;

            color:
                    #a78bfa;

            font-size:
                    27px;

            font-weight:
                    850;
        }


        .history-count-label {
            display:
                    block;

            margin-top:
                    4px;

            color:
                    #64748b;

            font-size:
                    10px;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.7px;
        }


        /* =====================================================
           STACK INFORMATION
        ====================================================== */

        .stack-info {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    13px;

            margin-bottom:
                    25px;

            padding:
                    14px
                    17px;

            border-radius:
                    13px;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.06
                    );

            border:
                    1px solid
                    rgba(
                            59,
                            130,
                            246,
                            0.14
                    );
        }


        .stack-info-icon {
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

            flex-shrink:
                    0;

            border-radius:
                    10px;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.10
                    );
        }


        .stack-info strong {
            color:
                    #93c5fd;
        }


        .stack-info-text {
            color:
                    #94a3b8;

            font-size:
                    11px;

            line-height:
                    1.65;
        }


        /* =====================================================
           LATEST MOVIE
        ====================================================== */

        .latest-section {
            margin-bottom:
                    45px;
        }


        .section-heading {
            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap:
                    20px;

            margin-bottom:
                    17px;
        }


        .section-heading h2 {
            margin: 0;

            font-size:
                    21px;
        }


        .section-heading p {
            margin:
                    5px
                    0
                    0;

            color:
                    #64748b;

            font-size:
                    11px;
        }


        .latest-card {
            position:
                    relative;

            overflow:
                    hidden;

            display:
                    grid;

            grid-template-columns:
                    230px
                    minmax(
                            0,
                            1fr
                    );

            min-height:
                    330px;

            border-radius:
                    22px;

            background:
                    linear-gradient(
                            135deg,
                            rgba(
                                    27,
                                    39,
                                    65,
                                    0.90
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
                            139,
                            92,
                            246,
                            0.20
                    );

            box-shadow:
                    0
                    24px
                    60px
                    rgba(
                            0,
                            0,
                            0,
                            0.22
                    );
        }


        .latest-card::after {
            content: "";

            position:
                    absolute;

            width:
                    350px;

            height:
                    350px;

            right:
                    -120px;

            top:
                    -160px;

            border-radius:
                    50%;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.15
                    );

            filter:
                    blur(30px);
        }


        .latest-poster {
            position:
                    relative;

            z-index:
                    2;

            height:
                    100%;

            min-height:
                    330px;

            overflow:
                    hidden;
        }


        .latest-poster img {
            display:
                    block;

            width:
                    100%;

            height:
                    100%;

            object-fit:
                    cover;
        }


        .latest-poster::after {
            content: "";

            position:
                    absolute;

            inset: 0;

            background:
                    linear-gradient(
                            to right,
                            transparent 55%,
                            rgba(
                                    20,
                                    30,
                                    50,
                                    0.92
                            )
                    );
        }


        .latest-content {
            position:
                    relative;

            z-index:
                    3;

            display:
                    flex;

            flex-direction:
                    column;

            justify-content:
                    center;

            padding:
                    38px;
        }


        .stack-top-badge {
            display:
                    inline-flex;

            align-items:
                    center;

            width:
                    fit-content;

            gap:
                    7px;

            margin-bottom:
                    18px;

            padding:
                    6px
                    9px;

            border-radius:
                    999px;

            color:
                    #93c5fd;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.09
                    );

            border:
                    1px solid
                    rgba(
                            59,
                            130,
                            246,
                            0.20
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


        .latest-title {
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


        .latest-meta {
            display:
                    flex;

            flex-wrap:
                    wrap;

            gap:
                    8px;

            align-items:
                    center;

            color:
                    #94a3b8;

            font-size:
                    12px;
        }


        .latest-rating {
            display:
                    inline-flex;

            align-items:
                    center;

            gap:
                    5px;

            color:
                    #facc15;

            font-weight:
                    750;
        }


        .latest-description {
            max-width:
                    650px;

            margin:
                    18px
                    0
                    0;

            color:
                    #a6b0c0;

            line-height:
                    1.75;

            font-size:
                    13px;
        }


        .latest-actions {
            display:
                    flex;

            flex-wrap:
                    wrap;

            gap:
                    10px;

            margin-top:
                    25px;
        }


        .history-primary-button,
        .history-secondary-button {
            min-height:
                    41px;

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
                    9px;

            text-decoration:
                    none;

            font-size:
                    11px;

            font-weight:
                    750;
        }


        .history-primary-button {
            color:
                    #ffffff;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6
                    );
        }


        .history-secondary-button {
            color:
                    #e2e8f0;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.09
                    );

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.04
                    );
        }


        /* =====================================================
           HISTORY GRID
        ====================================================== */

        .history-grid {
            display:
                    grid;

            grid-template-columns:
                    repeat(
                            3,
                            minmax(
                                    0,
                                    1fr
                            )
                    );

            gap:
                    18px;
        }


        .history-card {
            position:
                    relative;

            overflow:
                    hidden;

            border-radius:
                    18px;

            background:
                    rgba(
                            23,
                            33,
                            54,
                            0.72
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
                    0.22s ease,
                    border-color
                    0.22s ease;
        }


        .history-card:hover {
            transform:
                    translateY(-4px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.30
                    );
        }


        .history-card-poster {
            position:
                    relative;

            width:
                    100%;

            aspect-ratio:
                    16 / 9;

            overflow:
                    hidden;

            background:
                    #111827;
        }


        .history-card-poster img {
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
                    0.3s ease;
        }


        .history-card:hover
        .history-card-poster img {
            transform:
                    scale(1.045);
        }


        .history-card-poster::after {
            content: "";

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
                            transparent 60%
                    );
        }


        .history-number {
            position:
                    absolute;

            z-index:
                    3;

            top:
                    12px;

            left:
                    12px;

            padding:
                    5px
                    8px;

            border-radius:
                    8px;

            color:
                    #ffffff;

            background:
                    rgba(
                            0,
                            0,
                            0,
                            0.66
                    );

            font-size:
                    10px;

            font-weight:
                    800;

            backdrop-filter:
                    blur(6px);
        }


        .latest-indicator {
            position:
                    absolute;

            z-index:
                    3;

            top:
                    12px;

            right:
                    12px;

            padding:
                    5px
                    8px;

            border-radius:
                    999px;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.82
                    );

            color:
                    #ffffff;

            font-size:
                    8px;

            font-weight:
                    800;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.6px;
        }


        .history-card-body {
            padding:
                    20px;
        }


        .history-card-title {
            margin:
                    0
                    0
                    8px;

            font-size:
                    17px;

            font-weight:
                    800;
        }


        .history-card-meta {
            display:
                    flex;

            align-items:
                    center;

            flex-wrap:
                    wrap;

            gap:
                    7px;

            color:
                    #64748b;

            font-size:
                    11px;
        }


        .history-card-rating {
            color:
                    #facc15;

            font-weight:
                    700;
        }


        .history-card-description {
            min-height:
                    58px;

            margin:
                    14px
                    0
                    18px;

            color:
                    #94a3b8;

            font-size:
                    12px;

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


        .history-card-actions {
            display:
                    grid;

            grid-template-columns:
                    1fr
                    1fr;

            gap:
                    8px;
        }


        .history-card-actions a {
            min-height:
                    37px;
        }


        /* =====================================================
           EMPTY STATE
        ====================================================== */

        .history-empty {
            padding:
                    70px
                    25px;

            text-align:
                    center;

            border-radius:
                    22px;

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
                            0.10
                    );
        }


        .history-empty-icon {
            margin-bottom:
                    14px;

            font-size:
                    48px;
        }


        .history-empty h2 {
            margin:
                    0
                    0
                    10px;

            font-size:
                    22px;
        }


        .history-empty p {
            max-width:
                    430px;

            margin:
                    0
                    auto
                    22px;

            color:
                    #94a3b8;

            font-size:
                    13px;

            line-height:
                    1.7;
        }


        /* =====================================================
           FOOTER
        ====================================================== */

        .history-footer {
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


        .history-footer-inner {
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


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (
        max-width: 1000px
        ) {

            .history-grid {
                grid-template-columns:
                        1fr
                        1fr;
            }


            .latest-card {
                grid-template-columns:
                        190px
                        1fr;
            }

        }


        @media (
        max-width: 760px
        ) {

            .customer-nav-links {
                display:
                        none;
            }


            .history-header {
                flex-direction:
                        column;

                align-items:
                        flex-start;
            }


            .history-count {
                width:
                        100%;

                text-align:
                        left;
            }


            .latest-card {
                grid-template-columns:
                        1fr;
            }


            .latest-poster {
                min-height:
                        300px;

                height:
                        300px;
            }


            .latest-poster::after {
                background:
                        linear-gradient(
                                to top,
                                rgba(
                                        20,
                                        30,
                                        50,
                                        0.96
                                ),
                                transparent 60%
                        );
            }


            .latest-content {
                padding:
                        25px;
            }


            .history-grid {
                grid-template-columns:
                        1fr;
            }

        }


        @media (
        max-width: 540px
        ) {

            .customer-profile-name {
                display:
                        none;
            }


            .customer-avatar {
                display:
                        none;
            }


            .latest-actions {
                flex-direction:
                        column;
            }


            .latest-actions a {
                width:
                        100%;
            }


            .history-card-actions {
                grid-template-columns:
                        1fr;
            }


            .history-footer-inner {
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
     NAVBAR
========================================================= -->

<header class="customer-navbar">


    <div class="customer-navbar-inner">


        <!-- BRAND - RETURNS HOME -->

        <a
                href="<%= ctx %>/"
                class="customer-brand"
        >


            <span class="customer-brand-icon">

                🎬

            </span>


            CineRent

        </a>


        <!-- NAVIGATION -->

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
                    class="customer-nav-link active"
            >

                Recently Watched

            </a>


        </nav>


        <!-- PROFILE -->

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

<main class="history-page">


    <div class="history-container">


        <!-- =====================================================
             HEADER
        ====================================================== -->

        <section class="history-header">


            <div>


                <div class="history-badge">

                    🕘 Your Watch History

                </div>


                <h1 class="history-title">

                    Recently Watched

                </h1>


                <p class="history-description">

                    Revisit movies you've completed,
                    check their ratings and share your
                    thoughts with the CineRent community.

                </p>


            </div>


            <div class="history-count">


                <span class="history-count-number">

                    <%= watchedCount %>

                </span>


                <span class="history-count-label">

                    Watched Movies

                </span>


            </div>


        </section>


        <!-- =====================================================
             STACK INFORMATION
        ====================================================== -->

        <div class="stack-info">


            <div class="stack-info-icon">

                📚

            </div>


            <div class="stack-info-text">

                <strong>
                    Stack / LIFO implementation:
                </strong>

                CineRent stores your recently watched movies
                using a stack structure. The latest returned
                movie is placed at the top of the stack and
                displayed first.

            </div>


        </div>


        <%
            if (
                    latestMovie == null
                            ||
                            watchedMovies.isEmpty()
            ) {
        %>


        <!-- =====================================================
             EMPTY STATE
        ====================================================== -->

        <section class="history-empty">


            <div class="history-empty-icon">

                🎬

            </div>


            <h2>

                Nothing watched yet.

            </h2>


            <p>

                When you return a rented movie,
                CineRent will automatically add it
                to your recently watched stack.

            </p>


            <a
                    href="<%= ctx %>/catalog"
                    class="history-primary-button"
            >

                Browse Movies →

            </a>


        </section>


        <%
        } else {
        %>


        <!-- =====================================================
             LATEST / STACK TOP
        ====================================================== -->

        <section class="latest-section">


            <div class="section-heading">


                <div>


                    <h2>

                        Latest Watched

                    </h2>


                    <p>

                        The movie currently at the
                        top of your CineRent stack.

                    </p>


                </div>


            </div>


            <article class="latest-card">


                <!-- POSTER -->

                <div class="latest-poster">


                    <img
                            src="<%= ctx %>/movie-image?id=<%= HtmlUtil.escape(
                                    latestMovie.getMovieId()
                            ) %>"

                            alt="<%= HtmlUtil.escape(
                                    latestMovie.getTitle()
                            ) %>"

                            onerror="
                                    this.onerror=null;
                                    this.src='<%= ctx %>/images/posters/default.svg';
                                    "
                    >


                </div>


                <!-- INFORMATION -->

                <div class="latest-content">


                    <div class="stack-top-badge">

                        ↑ Stack Top
                        • Latest Watched

                    </div>


                    <h2 class="latest-title">

                        <%= HtmlUtil.escape(
                                latestMovie.getTitle()
                        ) %>

                    </h2>


                    <div class="latest-meta">


                        <span>

                            <%= HtmlUtil.escape(
                                    latestMovie.getGenre()
                            ) %>

                        </span>


                        <span>
                            •
                        </span>


                        <span>

                            <%= latestMovie.getReleaseYear() %>

                        </span>


                        <span>
                            •
                        </span>


                        <span class="latest-rating">

                            ⭐

                            <%= String.format(
                                    "%.1f",
                                    latestMovie.getRating()
                            ) %>

                        </span>


                    </div>


                    <%
                        String latestDescription =
                                latestMovie.getDescription();

                        if (
                                latestDescription != null
                                        &&
                                        !latestDescription
                                                .trim()
                                                .isEmpty()
                        ) {
                    %>


                    <p class="latest-description">

                        <%= HtmlUtil.escape(
                                latestDescription
                        ) %>

                    </p>


                    <%
                        }
                    %>


                    <div class="latest-actions">


                        <a
                                href="<%= ctx %>/reviews?movieId=<%= HtmlUtil.escape(
                                        latestMovie.getMovieId()
                                ) %>"

                                class="history-primary-button"
                        >

                            ⭐ View / Add Review

                        </a>


                        <a
                                href="<%= ctx %>/catalog"
                                class="history-secondary-button"
                        >

                            🎬 Browse More Movies

                        </a>


                    </div>


                </div>


            </article>


        </section>


        <!-- =====================================================
             WATCH HISTORY
        ====================================================== -->

        <section>


            <div class="section-heading">


                <div>


                    <h2>

                        Watch History

                    </h2>


                    <p>

                        Newest movies appear first
                        according to stack order.

                    </p>


                </div>


            </div>


            <div class="history-grid">


                <%
                    int position =
                            1;


                    for (
                            Movie movie
                            : watchedMovies
                    ) {


                        String movieDescription =
                                movie.getDescription();


                        if (
                                movieDescription == null
                        ) {

                            movieDescription =
                                    "";
                        }
                %>


                <article class="history-card">


                    <!-- POSTER -->

                    <div class="history-card-poster">


                        <img
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


                        <span class="history-number">

                            #<%= position %>

                        </span>


                        <%
                            if (
                                    position == 1
                            ) {
                        %>


                        <span class="latest-indicator">

                            Latest

                        </span>


                        <%
                            }
                        %>


                    </div>


                    <!-- BODY -->

                    <div class="history-card-body">


                        <h3 class="history-card-title">

                            <%= HtmlUtil.escape(
                                    movie.getTitle()
                            ) %>

                        </h3>


                        <div class="history-card-meta">


                            <span>

                                <%= HtmlUtil.escape(
                                        movie.getGenre()
                                ) %>

                            </span>


                            <span>
                                •
                            </span>


                            <span>

                                <%= movie.getReleaseYear() %>

                            </span>


                            <span>
                                •
                            </span>


                            <span class="history-card-rating">

                                ⭐

                                <%= String.format(
                                        "%.1f",
                                        movie.getRating()
                                ) %>

                            </span>


                        </div>


                        <div class="history-card-description">

                            <%
                                if (
                                        movieDescription
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
                                    movieDescription
                            ) %>

                            <%
                                }
                            %>


                        </div>


                        <div class="history-card-actions">


                            <a
                                    href="<%= ctx %>/reviews?movieId=<%= HtmlUtil.escape(
                                            movie.getMovieId()
                                    ) %>"

                                    class="history-primary-button"
                            >

                                ⭐ Reviews

                            </a>


                            <a
                                    href="<%= ctx %>/catalog"
                                    class="history-secondary-button"
                            >

                                Movies

                            </a>


                        </div>


                    </div>


                </article>


                <%
                        position++;
                    }
                %>


            </div>


        </section>


        <%
            }
        %>


    </div>


</main>


<!-- =========================================================
     FOOTER
========================================================= -->

<footer class="history-footer">


    <div class="history-footer-inner">


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
        defer
></script>


</body>

</html>