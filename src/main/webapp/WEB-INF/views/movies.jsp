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


    int movieCount =
            movies == null
                    ? 0
                    : movies.size();


    int totalCopies = 0;


    if (movies != null) {

        for (Movie movie : movies) {

            totalCopies +=
                    movie.getAvailableCopies();
        }
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
        Movie Management | CineRent
    </title>


    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <style>

        /* =====================================================
           PAGE
        ====================================================== */

        .movie-management-page {
            padding:
                    42px
                    0
                    70px;
        }


        /* =====================================================
           HEADER
        ====================================================== */

        .movie-management-header {
            display: flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap: 25px;

            margin-bottom:
                    30px;
        }


        .movie-management-heading h1 {
            margin: 0;

            font-size:
                    32px;
        }


        .movie-management-heading p {
            margin:
                    8px
                    0
                    0;

            color:
                    #94a3b8;

            line-height:
                    1.6;
        }


        .movie-header-actions {
            display: flex;

            align-items:
                    center;

            gap: 10px;
        }


        /* =====================================================
           SUMMARY
        ====================================================== */

        .movie-summary-grid {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(
                                    190px,
                                    1fr
                            )
                    );

            gap: 15px;

            margin-bottom:
                    28px;
        }


        .movie-summary-card {
            padding:
                    20px;

            border-radius:
                    16px;

            background:
                    rgba(
                            30,
                            41,
                            59,
                            0.72
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.12
                    );
        }


        .movie-summary-label {
            margin-bottom:
                    8px;

            color:
                    #94a3b8;

            font-size:
                    12px;
        }


        .movie-summary-value {
            font-size:
                    28px;

            font-weight:
                    800;

            color:
                    #ffffff;
        }


        .movie-summary-value.purple {
            color:
                    #c084fc;
        }


        .movie-summary-value.green {
            color:
                    #4ade80;
        }


        /* =====================================================
           TOOLBAR
        ====================================================== */

        .movie-toolbar {
            display: flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap: 15px;

            margin-bottom:
                    18px;
        }


        .movie-search-wrapper {
            position:
                    relative;

            width:
                    min(
                            430px,
                            100%
                    );
        }


        .movie-search-icon {
            position:
                    absolute;

            left:
                    14px;

            top:
                    50%;

            transform:
                    translateY(-50%);

            color:
                    #64748b;

            pointer-events:
                    none;

            font-size:
                    14px;
        }


        .movie-search {
            width:
                    100%;

            padding:
                    12px
                    14px
                    12px
                    42px;

            border-radius:
                    11px;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.18
                    );

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.80
                    );

            color:
                    #ffffff;

            outline:
                    none;

            font-family:
                    inherit;
        }


        .movie-search::placeholder {
            color:
                    #64748b;
        }


        .movie-search:focus {
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


        .movie-result-summary {
            color:
                    #cbd5e1;

            font-size:
                    14px;
        }


        .movie-result-summary strong {
            color:
                    #ffffff;
        }


        /* =====================================================
           TABLE
        ====================================================== */

        .movie-table-wrapper {
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
                            0.12
                    );

            background:
                    rgba(
                            30,
                            41,
                            59,
                            0.68
                    );
        }


        .movie-table {
            width:
                    100%;

            border-collapse:
                    collapse;

            min-width:
                    1050px;
        }


        .movie-table th {
            padding:
                    15px;

            text-align:
                    left;

            background:
                    rgba(
                            51,
                            65,
                            85,
                            0.72
                    );

            color:
                    #cbd5e1;

            font-size:
                    12px;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.6px;

            white-space:
                    nowrap;
        }


        .movie-table td {
            padding:
                    15px;

            border-bottom:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.09
                    );

            vertical-align:
                    middle;
        }


        .movie-table tbody tr {
            transition:
                    background
                    0.2s ease;
        }


        .movie-table tbody tr:hover {
            background:
                    rgba(
                            51,
                            65,
                            85,
                            0.32
                    );
        }


        .movie-table tbody tr:last-child td {
            border-bottom:
                    none;
        }


        /* =====================================================
           POSTER
        ====================================================== */

        .admin-movie-poster-wrapper {
            width:
                    64px;

            height:
                    94px;

            overflow:
                    hidden;

            border-radius:
                    10px;

            background:
                    #111827;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.16
                    );
        }


        .admin-movie-poster {
            display:
                    block;

            width:
                    100%;

            height:
                    100%;

            object-fit:
                    cover;
        }


        /* =====================================================
           MOVIE DETAILS
        ====================================================== */

        .admin-movie-info {
            min-width:
                    180px;
        }


        .admin-movie-title {
            margin-bottom:
                    5px;

            color:
                    #ffffff;

            font-weight:
                    750;

            font-size:
                    14px;
        }


        .admin-movie-id {
            color:
                    #64748b;

            font-size:
                    11px;
        }


        /* =====================================================
           BADGES
        ====================================================== */

        .genre-badge {
            display:
                    inline-flex;

            align-items:
                    center;

            padding:
                    6px
                    9px;

            border-radius:
                    999px;

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

            color:
                    #c4b5fd;

            font-size:
                    11px;

            font-weight:
                    700;
        }


        .rating {
            color:
                    #facc15;

            font-weight:
                    700;

            white-space:
                    nowrap;
        }


        .copy-badge {
            display:
                    inline-flex;

            padding:
                    6px
                    9px;

            border-radius:
                    999px;

            font-size:
                    11px;

            font-weight:
                    700;
        }


        .copy-badge.available {
            color:
                    #86efac;

            background:
                    rgba(
                            34,
                            197,
                            94,
                            0.10
                    );

            border:
                    1px solid
                    rgba(
                            34,
                            197,
                            94,
                            0.20
                    );
        }


        .copy-badge.unavailable {
            color:
                    #fca5a5;

            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.10
                    );

            border:
                    1px solid
                    rgba(
                            239,
                            68,
                            68,
                            0.20
                    );
        }


        .movie-price {
            white-space:
                    nowrap;

            font-weight:
                    700;

            color:
                    #ffffff;
        }


        /* =====================================================
           ACTIONS
        ====================================================== */

        .movie-admin-actions {
            display:
                    flex;

            align-items:
                    center;

            gap:
                    8px;

            white-space:
                    nowrap;
        }


        .edit-button {
            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            padding:
                    8px
                    12px;

            border-radius:
                    8px;

            text-decoration:
                    none;

            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.12
                    );

            border:
                    1px solid
                    rgba(
                            59,
                            130,
                            246,
                            0.22
                    );

            color:
                    #93c5fd;

            font-size:
                    12px;

            font-weight:
                    700;

            transition:
                    0.2s ease;
        }


        .edit-button:hover {
            background:
                    rgba(
                            59,
                            130,
                            246,
                            0.22
                    );
        }


        .delete-form {
            display:
                    inline;

            margin: 0;
        }


        .delete-button {
            padding:
                    8px
                    12px;

            border:
                    1px solid
                    rgba(
                            239,
                            68,
                            68,
                            0.24
                    );

            border-radius:
                    8px;

            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.12
                    );

            color:
                    #fca5a5;

            font-size:
                    12px;

            font-weight:
                    700;

            cursor:
                    pointer;

            transition:
                    0.2s ease;
        }


        .delete-button:hover {
            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.22
                    );
        }


        /* =====================================================
           EMPTY / NO RESULTS
        ====================================================== */

        .empty {
            text-align:
                    center;

            padding:
                    55px
            !important;

            color:
                    #94a3b8;
        }


        .empty-icon {
            margin-bottom:
                    12px;

            font-size:
                    38px;
        }


        .no-search-results {
            display:
                    none;

            margin-top:
                    18px;

            padding:
                    25px;

            text-align:
                    center;

            border-radius:
                    14px;

            background:
                    rgba(
                            30,
                            41,
                            59,
                            0.62
                    );

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.10
                    );

            color:
                    #94a3b8;
        }


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (
        max-width: 760px
        ) {

            .movie-management-header {
                flex-direction:
                        column;

                align-items:
                        flex-start;
            }


            .movie-header-actions {
                width:
                        100%;
            }


            .movie-header-actions .btn {
                flex:
                        1;

                justify-content:
                        center;
            }


            .movie-toolbar {
                flex-direction:
                        column;

                align-items:
                        stretch;
            }


            .movie-search-wrapper {
                width:
                        100%;
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
     MAIN
========================================================= -->

<main class="movie-management-page">


    <div class="container">


        <!-- =====================================================
             HEADER
        ====================================================== -->

        <div class="movie-management-header">


            <div class="movie-management-heading">


                <h1>

                    🎬 Movie Management

                </h1>


                <p>

                    Add, update and manage movies
                    available on CineRent.

                </p>


            </div>


            <div class="movie-header-actions">


                <a
                        class="btn btn-secondary"
                        href="<%= ctx %>/admin"
                >

                    ← Dashboard

                </a>


                <a
                        class="btn btn-primary"
                        href="<%= ctx %>/movies?action=add"
                >

                    + Add Movie

                </a>


            </div>


        </div>


        <!-- =====================================================
             SUMMARY
        ====================================================== -->

        <section class="movie-summary-grid">


            <div class="movie-summary-card">


                <div class="movie-summary-label">

                    Total Movies

                </div>


                <div class="movie-summary-value purple">

                    <%= movieCount %>

                </div>


            </div>


            <div class="movie-summary-card">


                <div class="movie-summary-label">

                    Available Copies

                </div>


                <div class="movie-summary-value green">

                    <%= totalCopies %>

                </div>


            </div>


            <div class="movie-summary-card">


                <div class="movie-summary-label">

                    Poster Storage

                </div>


                <div
                        class="movie-summary-value"
                        style="
                            font-size:16px;
                        "
                >

                    data/posters/

                </div>


            </div>


        </section>


        <!-- =====================================================
             SEARCH
        ====================================================== -->

        <div class="movie-toolbar">


            <div class="movie-search-wrapper">


                <span class="movie-search-icon">

                    🔍

                </span>


                <input
                        id="movieSearch"
                        type="search"
                        class="movie-search"
                        placeholder="Search title, ID, genre, year..."
                        autocomplete="off"
                        data-movie-search
                >


            </div>


            <div class="movie-result-summary">

                <strong
                        data-movie-result-count
                >

                    <%= movieCount %>

                </strong>

                movie(s)

            </div>


        </div>


        <!-- =====================================================
             MOVIE TABLE
        ====================================================== -->

        <div class="movie-table-wrapper">


            <table class="movie-table">


                <thead>


                <tr>

                    <th>
                        Poster
                    </th>

                    <th>
                        Movie
                    </th>

                    <th>
                        Genre
                    </th>

                    <th>
                        Year
                    </th>

                    <th>
                        Price
                    </th>

                    <th>
                        Rating
                    </th>

                    <th>
                        Copies
                    </th>

                    <th>
                        Actions
                    </th>

                </tr>


                </thead>


                <tbody>


                <%
                    if (
                            movies == null
                                    ||
                                    movies.isEmpty()
                    ) {
                %>


                <!-- =================================================
                     EMPTY DATABASE
                ================================================== -->

                <tr>


                    <td
                            colspan="8"
                            class="empty"
                    >


                        <div class="empty-icon">

                            🎬

                        </div>


                        <strong>

                            No movies available.

                        </strong>


                        <div
                                style="
                                    margin-top:8px;
                                "
                        >

                            Add your first movie to
                            the CineRent catalogue.

                        </div>


                    </td>


                </tr>


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
                     MOVIE ROW
                ================================================== -->

                <tr
                        data-movie-row
                        data-movie-id="<%= HtmlUtil.escape(
                                movie.getMovieId()
                        ) %>"
                >


                    <!-- POSTER -->

                    <td>


                        <div class="admin-movie-poster-wrapper">


                            <img
                                    class="admin-movie-poster"

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


                        </div>


                    </td>


                    <!-- MOVIE -->

                    <td>


                        <div class="admin-movie-info">


                            <div class="admin-movie-title">

                                <%= HtmlUtil.escape(
                                        movie.getTitle()
                                ) %>

                            </div>


                            <div class="admin-movie-id">

                                ID:

                                <%= HtmlUtil.escape(
                                        movie.getMovieId()
                                ) %>

                            </div>


                        </div>


                    </td>


                    <!-- GENRE -->

                    <td>


                        <span class="genre-badge">

                            <%= HtmlUtil.escape(
                                    movie.getGenre()
                            ) %>

                        </span>


                    </td>


                    <!-- YEAR -->

                    <td>

                        <%= movie.getReleaseYear() %>

                    </td>


                    <!-- PRICE -->

                    <td>


                        <span class="movie-price">

                            LKR

                            <%= String.format(
                                    "%.2f",
                                    movie.getRentalPrice()
                            ) %>

                        </span>


                    </td>


                    <!-- RATING -->

                    <td class="rating">

                        ⭐

                        <%= String.format(
                                "%.1f",
                                movie.getRating()
                        ) %>

                    </td>


                    <!-- COPIES -->

                    <td>


                        <span
                                class="copy-badge
                                <%= available
                                        ? "available"
                                        : "unavailable" %>"
                        >

                            <%= available
                                    ? movie.getAvailableCopies()
                                    + " available"
                                    : "Unavailable" %>

                        </span>


                    </td>


                    <!-- ACTIONS -->

                    <td>


                        <div class="movie-admin-actions">


                            <a
                                    class="edit-button"

                                    href="<%= ctx %>/movies?action=edit&id=<%= HtmlUtil.escape(
                                            movie.getMovieId()
                                    ) %>"
                            >

                                ✏ Edit

                            </a>


                            <form
                                    class="delete-form"

                                    method="post"

                                    action="<%= ctx %>/movies"

                                    data-confirm="Are you sure you want to delete this movie? The uploaded poster will also be deleted."
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
                                        class="delete-button"
                                >

                                    🗑 Delete

                                </button>


                            </form>


                        </div>


                    </td>


                </tr>


                <%
                        }
                    }
                %>


                </tbody>


            </table>


        </div>


        <!-- =====================================================
             NO SEARCH RESULTS
        ====================================================== -->

        <div
                id="noMovieSearchResults"
                class="no-search-results"
        >

            🔍 No movies found matching your search.

        </div>


    </div>


</main>


<!-- =========================================================
     FOOTER
========================================================= -->

<jsp:include
        page="/WEB-INF/views/partials/footer.jsp"
/>


<!-- =========================================================
     SEARCH + CONFIRM SCRIPT
========================================================= -->

<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {


            // =================================================
            // MOVIE SEARCH
            // =================================================

            const searchInput =
                document.querySelector(
                    "[data-movie-search]"
                );


            const movieRows =
                document.querySelectorAll(
                    "[data-movie-row]"
                );


            const resultCount =
                document.querySelector(
                    "[data-movie-result-count]"
                );


            const noResults =
                document.getElementById(
                    "noMovieSearchResults"
                );


            if (searchInput) {


                searchInput.addEventListener(
                    "input",
                    function () {


                        const query =
                            searchInput
                                .value
                                .trim()
                                .toLowerCase();


                        let visibleCount =
                            0;


                        movieRows.forEach(
                            function (row) {


                                const rowText =
                                    row
                                        .textContent
                                        .replace(
                                            /\s+/g,
                                            " "
                                        )
                                        .trim()
                                        .toLowerCase();


                                const matches =
                                    query === ""
                                    ||
                                    rowText.includes(
                                        query
                                    );


                                row.style.display =
                                    matches
                                        ? ""
                                        : "none";


                                if (matches) {

                                    visibleCount++;

                                }

                            }
                        );


                        if (resultCount) {

                            resultCount.textContent =
                                visibleCount;

                        }


                        if (noResults) {

                            noResults.style.display =
                                visibleCount === 0
                                &&
                                movieRows.length > 0
                                    ? "block"
                                    : "none";

                        }

                    }
                );

            }


            // =================================================
            // DELETE CONFIRMATION
            // =================================================

            const confirmForms =
                document.querySelectorAll(
                    "[data-confirm]"
                );


            confirmForms.forEach(
                function (form) {


                    form.addEventListener(
                        "submit",
                        function (event) {


                            const message =
                                form.getAttribute(
                                    "data-confirm"
                                )
                                ||
                                "Are you sure?";


                            if (
                                !window.confirm(
                                    message
                                )
                            ) {

                                event.preventDefault();

                            }

                        }
                    );

                }
            );

        }
    );

</script>


<!-- =========================================================
     GLOBAL JS
========================================================= -->

<script
        src="<%= ctx %>/js/app.js"
></script>


</body>

</html>