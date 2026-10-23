<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.movierental.model.Movie" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx =
            request.getContextPath();


    Movie movie =
            (Movie)
                    request.getAttribute(
                            "movie"
                    );


    String error =
            (String)
                    request.getAttribute(
                            "error"
                    );
// ADD / EDIT MODE

    boolean editMode =
            movie != null;


    String pageTitle =
            editMode
                    ? "Edit Movie"
                    : "Add Movie";


    String submitAction =
            editMode
                    ? "update"
                    : "add";


    String submitText =
            editMode
                    ? "Update Movie"
                    : "Add Movie";

    // FORM VALUES


    String title =
            editMode
                    && movie.getTitle() != null
                    ? movie.getTitle()
                    : "";


    String genre =
            editMode
                    && movie.getGenre() != null
                    ? movie.getGenre()
                    : "";


    String description =
            editMode
                    && movie.getDescription() != null
                    ? movie.getDescription()
                    : "";

    // POSTER


    String posterUrl;

    if (editMode) {

        posterUrl =
                ctx
                        + "/movie-image?id="
                        + movie.getMovieId();

    } else {

        posterUrl =
                ctx
                        + "/images/posters/default.svg";
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
        <%= pageTitle %> | CineRent
    </title>


    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <style>

        /*
           PAGE
        */

        .movie-form-page {

            padding:
                    42px
                    0
                    70px;

        }


        .movie-form-header {

            display: flex;

            justify-content:
                    space-between;

            align-items:
                    center;

            gap: 20px;

            margin-bottom:
                    28px;

        }


        .movie-form-header h1 {

            margin: 0;

            font-size:
                    30px;

        }


        .movie-form-header p {

            margin:
                    8px
                    0
                    0;

            color:
                    #94a3b8;

            line-height:
                    1.6;

        }


        /*
           WRAPPER
        */

        .movie-form-wrapper {

            display: grid;

            grid-template-columns:
                    minmax(0, 1fr)
                    330px;

            gap: 25px;

            align-items:
                    start;

        }


        /*
           FORM CARD
         */

        .movie-form-card {

            padding:
                    30px;

            border-radius:
                    20px;

            background:
                    rgba(
                            30,
                            41,
                            59,
                            0.78
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


        .form-section-title {

            margin:
                    0
                    0
                    22px;

            font-size:
                    19px;

        }


        /*
           FORM GRID
        */

        .form-grid {

            display: grid;

            grid-template-columns:
                    repeat(
                            2,
                            1fr
                    );

            gap: 19px;

        }


        .form-group {

            display: flex;

            flex-direction:
                    column;

            gap: 8px;

        }


        .form-group.full-width {

            grid-column:
                    1 / -1;

        }


        .form-group label {

            font-size:
                    13px;

            font-weight:
                    700;

            color:
                    #cbd5e1;

        }


        /*
           INPUTS
         */

        .movie-input,
        .movie-textarea {

            width: 100%;

            padding:
                    13px
                    14px;

            border-radius:
                    11px;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.20
                    );

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.75
                    );

            color:
                    #ffffff;

            outline:
                    none;

            font-family:
                    inherit;

            transition:
                    border-color
                    0.2s ease,
                    box-shadow
                    0.2s ease;

        }


        .movie-input:focus,
        .movie-textarea:focus {

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
                            0.12
                    );

        }


        .movie-textarea {

            min-height:
                    140px;

            resize:
                    vertical;

        }


        .form-hint {

            color:
                    #64748b;

            font-size:
                    11px;

            line-height:
                    1.6;

        }


        /*
           POSTER UPLOAD
         */

        .poster-upload-section {

            display: grid;

            grid-template-columns:
                    180px
                    minmax(
                            0,
                            1fr
                    );

            gap: 22px;

            align-items:
                    start;

            padding:
                    20px;

            border-radius:
                    16px;

            border:
                    1px solid
                    rgba(
                            139,
                            92,
                            246,
                            0.20
                    );

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.05
                    );

        }


        .poster-preview-wrapper {

            position:
                    relative;

            width:
                    180px;

            aspect-ratio:
                    2 / 3;

            overflow:
                    hidden;

            border-radius:
                    14px;

            background:
                    #0f172a;

            border:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.18
                    );

        }


        .poster-preview {

            display: block;

            width:
                    100%;

            height:
                    100%;

            object-fit:
                    cover;

        }


        .poster-preview-label {

            position:
                    absolute;

            left: 9px;

            bottom: 9px;

            padding:
                    5px
                    8px;

            border-radius:
                    7px;

            background:
                    rgba(
                            0,
                            0,
                            0,
                            0.72
                    );

            color:
                    #ffffff;

            font-size:
                    10px;

            font-weight:
                    700;

        }


        .poster-upload-content {

            display: flex;

            flex-direction:
                    column;

            gap: 12px;

        }


        .poster-upload-content h3 {

            margin: 0;

            font-size:
                    16px;

        }


        .poster-upload-content p {

            margin: 0;

            color:
                    #94a3b8;

            font-size:
                    12px;

            line-height:
                    1.7;

        }


        .poster-file-input {

            width: 100%;

            padding:
                    12px;

            border-radius:
                    11px;

            border:
                    1px dashed
                    rgba(
                            139,
                            92,
                            246,
                            0.45
                    );

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.70
                    );

            color:
                    #cbd5e1;

            cursor:
                    pointer;

        }


        .poster-file-input::file-selector-button {

            margin-right:
                    12px;

            padding:
                    9px
                    13px;

            border:
                    0;

            border-radius:
                    8px;

            background:
                    #7c3aed;

            color:
                    #ffffff;

            font-weight:
                    700;

            cursor:
                    pointer;

        }


        .poster-file-name {

            min-height:
                    18px;

            color:
                    #c4b5fd;

            font-size:
                    11px;

        }


        .poster-requirements {

            display: flex;

            flex-wrap:
                    wrap;

            gap: 7px;

        }


        .poster-requirement {

            padding:
                    5px
                    8px;

            border-radius:
                    999px;

            background:
                    rgba(
                            148,
                            163,
                            184,
                            0.08
                    );

            color:
                    #94a3b8;

            font-size:
                    10px;

        }


        /*
           FORM ACTIONS
         */

        .movie-form-actions {

            display: flex;

            align-items:
                    center;

            gap: 12px;

            margin-top:
                    28px;

        }


        .movie-form-actions .btn {

            min-width:
                    145px;

            justify-content:
                    center;

        }


        /*
           SIDE CARD
         */

        .movie-side-card {

            padding:
                    25px;

            border-radius:
                    20px;

            background:
                    rgba(
                            30,
                            41,
                            59,
                            0.65
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


        .movie-side-icon {

            display: flex;

            align-items:
                    center;

            justify-content:
                    center;

            width:
                    64px;

            height:
                    64px;

            margin-bottom:
                    20px;

            border-radius:
                    17px;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.16
                    );

            font-size:
                    31px;

        }


        .movie-side-card h3 {

            margin:
                    0
                    0
                    10px;

        }


        .movie-side-card p {

            margin: 0;

            color:
                    #94a3b8;

            font-size:
                    13px;

            line-height:
                    1.7;

        }


        .movie-form-info {

            margin-top:
                    22px;

        }


        .movie-form-info-item {

            padding:
                    12px
                    0;

            border-bottom:
                    1px solid
                    rgba(
                            148,
                            163,
                            184,
                            0.10
                    );

        }


        .movie-form-info-item:last-child {

            border-bottom:
                    none;

        }


        .movie-form-info-label {

            display:
                    block;

            margin-bottom:
                    5px;

            color:
                    #64748b;

            font-size:
                    11px;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.6px;

        }


        .movie-form-info-value {

            font-size:
                    13px;

            font-weight:
                    700;

        }


        /*
           ERROR
         */

        .movie-form-error {

            margin-bottom:
                    22px;

            padding:
                    13px
                    15px;

            border-radius:
                    10px;

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
                            0.25
                    );

            color:
                    #fca5a5;

        }


        /*
           RESPONSIVE
         */

        @media (
        max-width: 900px
        ) {

            .movie-form-wrapper {

                grid-template-columns:
                        1fr;

            }

        }


        @media (
        max-width: 700px
        ) {

            .poster-upload-section {

                grid-template-columns:
                        1fr;

            }


            .poster-preview-wrapper {

                width:
                        160px;

                margin:
                        0 auto;

            }

        }


        @media (
        max-width: 650px
        ) {

            .movie-form-header {

                flex-direction:
                        column;

                align-items:
                        flex-start;

            }


            .form-grid {

                grid-template-columns:
                        1fr;

            }


            .form-group.full-width {

                grid-column:
                        auto;

            }


            .movie-form-card {

                padding:
                        20px;

            }


            .movie-form-actions {

                flex-direction:
                        column;

            }


            .movie-form-actions .btn {

                width:
                        100%;

            }

        }

    </style>

</head>


<body>


<!--
     ADMIN NAV
 -->

<jsp:include
        page="/WEB-INF/views/partials/admin-nav.jsp"
/>


<!--
     PAGE
 -->

<main class="movie-form-page">


    <div class="container">


        <!--
             HEADER
         -->

        <div class="movie-form-header">


            <div>


                <h1>

                    <%= editMode
                            ? "Edit Movie"
                            : "Add New Movie" %>

                </h1>


                <p>

                    <%= editMode
                            ? "Update movie information or replace the current movie poster."
                            : "Add a new movie and upload its poster to the CineRent catalogue." %>

                </p>


            </div>


            <a
                    href="<%= ctx %>/movies"
                    class="btn btn-secondary"
            >

                ← Back to Movies

            </a>


        </div>


        <!--
             ERROR
       -->

        <%
            if (
                    error != null
                            &&
                            !error.trim().isEmpty()
            ) {
        %>


        <div class="movie-form-error">

            <%= HtmlUtil.escape(
                    error
            ) %>

        </div>


        <%
            }
        %>


        <div class="movie-form-wrapper">


            <!--
                 FORM
            -->

            <section class="movie-form-card">


                <h2 class="form-section-title">

                    Movie Information

                </h2>


                <!-- IMPORTANT:
                     multipart/form-data is required
                     for image uploading
                -->

                <form
                        method="post"
                        action="<%= ctx %>/movies"
                        enctype="multipart/form-data"
                >


                    <!--
                         ACTION
                    -->

                    <input
                            type="hidden"
                            name="action"
                            value="<%= submitAction %>"
                    >


                    <!--
                         MOVIE ID - EDIT ONLY
                     -->

                    <%
                        if (editMode) {
                    %>


                    <input
                            type="hidden"
                            name="movieId"
                            value="<%= HtmlUtil.escape(
                                    movie.getMovieId()
                            ) %>"
                    >


                    <%
                        }
                    %>


                    <div class="form-grid">


                        <!--
                             TITLE
                         -->

                        <div class="form-group full-width">


                            <label for="title">

                                Movie Title *

                            </label>


                            <input
                                    id="title"
                                    class="movie-input"
                                    type="text"
                                    name="title"
                                    value="<%= HtmlUtil.escape(
                                            title
                                    ) %>"
                                    placeholder="Enter movie title"
                                    maxlength="150"
                                    required
                            >


                        </div>


                        <!--
                             GENRE
                         -->

                        <div class="form-group">


                            <label for="genre">

                                Genre *

                            </label>


                            <input
                                    id="genre"
                                    class="movie-input"
                                    type="text"
                                    name="genre"
                                    value="<%= HtmlUtil.escape(
                                            genre
                                    ) %>"
                                    placeholder="e.g. Action"
                                    maxlength="60"
                                    required
                            >


                        </div>


                        <!--
                             RELEASE YEAR
                        -->

                        <div class="form-group">


                            <label for="releaseYear">

                                Release Year *

                            </label>


                            <input
                                    id="releaseYear"
                                    class="movie-input"
                                    type="number"
                                    name="releaseYear"
                                    value="<%= editMode
                                            ? movie.getReleaseYear()
                                            : "" %>"
                                    placeholder="e.g. 2026"
                                    min="1888"
                                    max="2100"
                                    required
                            >


                        </div>


                        <!--
                             RENTAL PRICE
                         -->

                        <div class="form-group">


                            <label for="rentalPrice">

                                Rental Price (LKR) *

                            </label>


                            <input
                                    id="rentalPrice"
                                    class="movie-input"
                                    type="number"
                                    name="rentalPrice"
                                    value="<%= editMode
                                            ? movie.getRentalPrice()
                                            : "" %>"
                                    placeholder="e.g. 500"
                                    min="0"
                                    step="0.01"
                                    required
                            >


                        </div>


                        <!--
                             RATING
                        -->

                        <div class="form-group">


                            <label for="rating">

                                Rating *

                            </label>


                            <input
                                    id="rating"
                                    class="movie-input"
                                    type="number"
                                    name="rating"
                                    value="<%= editMode
                                            ? movie.getRating()
                                            : "0" %>"
                                    min="0"
                                    max="5"
                                    step="0.1"
                                    required
                            >


                            <span class="form-hint">

                                Rating must be between
                                0.0 and 5.0.

                            </span>


                        </div>


                        <!--
                             AVAILABLE COPIES
                         -->

                        <div class="form-group">


                            <label for="availableCopies">

                                Available Copies *

                            </label>


                            <input
                                    id="availableCopies"
                                    class="movie-input"
                                    type="number"
                                    name="availableCopies"
                                    value="<%= editMode
                                            ? movie.getAvailableCopies()
                                            : "1" %>"
                                    min="0"
                                    required
                            >


                        </div>


                        <!-- EMPTY GRID ITEM -->

                        <div class="form-group">

                            <label>
                                Mode
                            </label>

                            <input
                                    class="movie-input"
                                    type="text"
                                    value="<%= editMode
                                            ? "Update Existing Movie"
                                            : "Create New Movie" %>"
                                    disabled
                            >

                        </div>


                        <!--
                             MOVIE POSTER
                         -->

                        <div class="form-group full-width">


                            <label for="poster">

                                Movie Poster

                            </label>


                            <div class="poster-upload-section">


                                <!--
                                     PREVIEW
                                 -->

                                <div class="poster-preview-wrapper">


                                    <img
                                            id="posterPreview"
                                            class="poster-preview"
                                            src="<%= posterUrl %>"
                                            alt="Movie poster preview"
                                            onerror="
                                                    this.onerror=null;
                                                    this.src='<%= ctx %>/images/posters/default.svg';
                                                    "
                                    >


                                    <span class="poster-preview-label">

                                        <%= editMode
                                                ? "Current Poster"
                                                : "Preview" %>

                                    </span>


                                </div>


                                <!--
                                     BROWSE
                                 -->

                                <div class="poster-upload-content">


                                    <h3>

                                        <%= editMode
                                                ? "Replace Movie Poster"
                                                : "Upload Movie Poster" %>

                                    </h3>


                                    <p>

                                        Select a poster image from
                                        your computer.

                                        <%
                                            if (editMode) {
                                        %>

                                        If you do not select a new image,
                                        the existing poster will remain.

                                        <%
                                            }
                                        %>

                                    </p>


                                    <input
                                            id="poster"
                                            class="poster-file-input"
                                            type="file"
                                            name="poster"
                                            accept="image/jpeg,image/png,image/webp"
                                    >


                                    <div
                                            id="posterFileName"
                                            class="poster-file-name"
                                    >

                                        No new image selected

                                    </div>


                                    <div class="poster-requirements">


                                        <span class="poster-requirement">

                                            JPG

                                        </span>


                                        <span class="poster-requirement">

                                            PNG

                                        </span>


                                        <span class="poster-requirement">

                                            WEBP

                                        </span>


                                        <span class="poster-requirement">

                                            Maximum 5 MB

                                        </span>


                                        <span class="poster-requirement">

                                            Recommended 2:3 poster ratio

                                        </span>


                                    </div>


                                </div>


                            </div>


                        </div>


                        <!--
                             DESCRIPTION
                         -->

                        <div class="form-group full-width">


                            <label for="description">

                                Description

                            </label>


                            <textarea
                                    id="description"
                                    class="movie-textarea"
                                    name="description"
                                    maxlength="1000"
                                    placeholder="Enter a short movie description..."
                            ><%= HtmlUtil.escape(
                                    description
                            ) %></textarea>


                        </div>


                    </div>


                    <!--
                         BUTTONS
                     -->

                    <div class="movie-form-actions">


                        <button
                                type="submit"
                                class="btn btn-primary"
                        >

                            <%= editMode
                                    ? "Update Movie"
                                    : "Add Movie" %>

                        </button>


                        <a
                                href="<%= ctx %>/movies"
                                class="btn btn-secondary"
                        >

                            Cancel

                        </a>


                    </div>


                </form>


            </section>


            <!--
                 SIDE PANEL
             -->

            <aside class="movie-side-card">


                <div class="movie-side-icon">

                    <%= editMode
                            ? "✏️"
                            : "🎬" %>

                </div>


                <h3>

                    <%= editMode
                            ? "Editing Movie"
                            : "Create Movie" %>

                </h3>


                <p>

                    Movie information is stored using
                    CineRent's file-handling system.

                    Poster images are stored separately
                    inside the data/posters folder.

                </p>


                <div class="movie-form-info">


                    <!-- MODE -->

                    <div class="movie-form-info-item">


                        <span class="movie-form-info-label">

                            Mode

                        </span>


                        <span class="movie-form-info-value">

                            <%= editMode
                                    ? "Update"
                                    : "Create" %>

                        </span>


                    </div>


                    <!-- MOVIE ID -->

                    <%
                        if (editMode) {
                    %>


                    <div class="movie-form-info-item">


                        <span class="movie-form-info-label">

                            Movie ID

                        </span>


                        <span class="movie-form-info-value">

                            <%= HtmlUtil.escape(
                                    movie.getMovieId()
                            ) %>

                        </span>


                    </div>


                    <%
                        }
                    %>


                    <!-- MOVIE DATA -->

                    <div class="movie-form-info-item">


                        <span class="movie-form-info-label">

                            Movie Data

                        </span>


                        <span class="movie-form-info-value">

                            data/movies.txt

                        </span>


                    </div>


                    <!-- POSTER DATA -->

                    <div class="movie-form-info-item">


                        <span class="movie-form-info-label">

                            Poster Storage

                        </span>


                        <span class="movie-form-info-value">

                            data/posters/

                        </span>


                    </div>


                    <!-- IMAGE LIMIT -->

                    <div class="movie-form-info-item">


                        <span class="movie-form-info-label">

                            Poster Limit

                        </span>


                        <span class="movie-form-info-value">

                            5 MB

                        </span>


                    </div>


                    <!-- IMAGE TYPES -->

                    <div class="movie-form-info-item">


                        <span class="movie-form-info-label">

                            Supported Images

                        </span>


                        <span class="movie-form-info-value">

                            JPG / PNG / WEBP

                        </span>


                    </div>


                </div>


            </aside>


        </div>


    </div>


</main>


<!--
     FOOTER
 -->

<jsp:include
        page="/WEB-INF/views/partials/footer.jsp"
/>


<script
        src="<%= ctx %>/js/app.js"
        defer
></script>


<!--
     POSTER PREVIEW SCRIPT
 -->

<script>

    document.addEventListener(
        "DOMContentLoaded",
        function () {


            const posterInput =
                document.getElementById(
                    "poster"
                );


            const posterPreview =
                document.getElementById(
                    "posterPreview"
                );


            const posterFileName =
                document.getElementById(
                    "posterFileName"
                );


            if (
                !posterInput
                ||
                !posterPreview
            ) {

                return;
            }


            posterInput.addEventListener(
                "change",
                function () {


                    const file =
                        this.files[0];


                    if (!file) {

                        posterFileName.textContent =
                            "No new image selected";

                        return;
                    }



                    // ALLOWED IMAGE TYPES


                    const allowedTypes = [
                        "image/jpeg",
                        "image/png",
                        "image/webp"
                    ];


                    if (
                        !allowedTypes.includes(
                            file.type
                        )
                    ) {


                        alert(
                            "Please select a JPG, PNG or WEBP image."
                        );


                        this.value =
                            "";


                        posterFileName.textContent =
                            "No new image selected";


                        return;
                    }

                    // MAX 5 MB

                    const maximumSize =
                        5
                        *
                        1024
                        *
                        1024;


                    if (
                        file.size
                        >
                        maximumSize
                    ) {


                        alert(
                            "Poster image must be smaller than 5 MB."
                        );


                        this.value =
                            "";


                        posterFileName.textContent =
                            "No new image selected";


                        return;
                    }



                    // SHOW FILE NAME

                    posterFileName.textContent =
                        file.name;



                    // PREVIEW IMAGE

                    const previewUrl =
                        URL.createObjectURL(
                            file
                        );


                    posterPreview.src =
                        previewUrl;


                    posterPreview.onload =
                        function () {

                            URL.revokeObjectURL(
                                previewUrl
                            );
                        };

                }
            );

        }
    );

</script>


</body>

</html>