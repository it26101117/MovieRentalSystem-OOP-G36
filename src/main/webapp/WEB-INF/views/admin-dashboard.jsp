<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx =
            request.getContextPath();

    String adminName =
            (String) session.getAttribute(
                    "userName"
            );

    String role =
            (String) session.getAttribute(
                    "role"
            );


    // =========================================================
    // SECURITY CHECK
    // =========================================================

    if (
            adminName == null
                    ||
                    role == null
                    ||
                    !"ADMIN".equalsIgnoreCase(role)
    ) {

        response.sendRedirect(
                ctx + "/login"
        );

        return;
    }


    // =========================================================
    // DASHBOARD STATISTICS
    // =========================================================

    Integer movieCount =
            (Integer) request.getAttribute(
                    "movieCount"
            );

    Integer customerCount =
            (Integer) request.getAttribute(
                    "customerCount"
            );

    Integer activeRentalCount =
            (Integer) request.getAttribute(
                    "activeRentalCount"
            );

    Integer returnedRentalCount =
            (Integer) request.getAttribute(
                    "returnedRentalCount"
            );

    Integer totalRentalCount =
            (Integer) request.getAttribute(
                    "totalRentalCount"
            );

    Integer reviewCount =
            (Integer) request.getAttribute(
                    "reviewCount"
            );

    Integer availableCopies =
            (Integer) request.getAttribute(
                    "availableCopies"
            );


    // =========================================================
    // DEFAULT VALUES
    // =========================================================

    if (movieCount == null) {
        movieCount = 0;
    }

    if (customerCount == null) {
        customerCount = 0;
    }

    if (activeRentalCount == null) {
        activeRentalCount = 0;
    }

    if (returnedRentalCount == null) {
        returnedRentalCount = 0;
    }

    if (totalRentalCount == null) {
        totalRentalCount = 0;
    }

    if (reviewCount == null) {
        reviewCount = 0;
    }

    if (availableCopies == null) {
        availableCopies = 0;
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
        Admin Dashboard | CineRent
    </title>


    <!-- GLOBAL CSS -->

    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <!-- DASHBOARD SPECIFIC CSS -->

    <style>

        /* =====================================================
           DASHBOARD PAGE
        ====================================================== */

        .admin-dashboard {
            padding: 42px 0 60px;
        }


        .dashboard-hero {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 30px;

            margin-bottom: 35px;

            padding: 30px;

            border-radius: 22px;

            background:
                    radial-gradient(
                            circle at top right,
                            rgba(124, 58, 237, 0.20),
                            transparent 35%
                    ),
                    rgba(15, 23, 42, 0.72);

            border:
                    1px solid
                    rgba(148, 163, 184, 0.12);
        }


        .dashboard-hero-content {
            max-width: 720px;
        }


        .dashboard-badge {
            display: inline-flex;
            align-items: center;

            gap: 7px;

            padding: 7px 12px;

            margin-bottom: 16px;

            border-radius: 999px;

            font-size: 12px;
            font-weight: 700;

            background:
                    rgba(124, 58, 237, 0.14);

            border:
                    1px solid
                    rgba(139, 92, 246, 0.30);
        }


        .dashboard-title {
            margin: 0;

            font-size: clamp(
                    28px,
                    4vw,
                    42px
            );

            line-height: 1.1;
        }


        .dashboard-title span {
            color: #8b5cf6;
        }


        .dashboard-description {
            margin:
                    13px
                    0
                    0;

            color: #94a3b8;

            line-height: 1.7;
        }


        .dashboard-status {
            flex-shrink: 0;

            padding: 14px 18px;

            border-radius: 14px;

            background:
                    rgba(34, 197, 94, 0.10);

            border:
                    1px solid
                    rgba(34, 197, 94, 0.25);

            color: #86efac;

            font-size: 13px;
            font-weight: 700;
        }


        /* =====================================================
           SECTION HEADER
        ====================================================== */

        .dashboard-section-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;

            gap: 20px;

            margin:
                    42px
                    0
                    20px;
        }


        .dashboard-section-header h2 {
            margin: 0;

            font-size: 23px;
        }


        .dashboard-section-header p {
            margin:
                    6px
                    0
                    0;

            color: #94a3b8;

            font-size: 14px;
        }


        /* =====================================================
           STATISTICS
        ====================================================== */

        .dashboard-stats {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(180px, 1fr)
                    );

            gap: 16px;
        }


        .dashboard-stat-card {
            padding: 22px;

            border-radius: 18px;

            background:
                    rgba(30, 41, 59, 0.72);

            border:
                    1px solid
                    rgba(148, 163, 184, 0.12);

            transition:
                    transform 0.2s ease,
                    border-color 0.2s ease;
        }


        .dashboard-stat-card:hover {
            transform:
                    translateY(-3px);

            border-color:
                    rgba(139, 92, 246, 0.40);
        }


        .dashboard-stat-icon {
            font-size: 27px;

            margin-bottom: 14px;
        }


        .dashboard-stat-value {
            margin-bottom: 6px;

            font-size: 32px;

            font-weight: 800;
        }


        .dashboard-stat-label {
            color: #94a3b8;

            font-size: 13px;
        }


        .stat-blue {
            color: #60a5fa;
        }


        .stat-purple {
            color: #c084fc;
        }


        .stat-green {
            color: #4ade80;
        }


        .stat-yellow {
            color: #facc15;
        }


        /* =====================================================
           MANAGEMENT
        ====================================================== */

        .management-grid {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(245px, 1fr)
                    );

            gap: 18px;
        }


        .management-card {
            position: relative;

            display: flex;
            flex-direction: column;

            min-height: 260px;

            padding: 25px;

            border-radius: 20px;

            background:
                    rgba(30, 41, 59, 0.76);

            border:
                    1px solid
                    rgba(148, 163, 184, 0.12);

            overflow: hidden;

            transition:
                    transform 0.2s ease,
                    border-color 0.2s ease;
        }


        .management-card:hover {
            transform:
                    translateY(-4px);

            border-color:
                    rgba(139, 92, 246, 0.38);
        }


        .management-icon {
            display: flex;
            align-items: center;
            justify-content: center;

            width: 50px;
            height: 50px;

            margin-bottom: 18px;

            border-radius: 14px;

            background:
                    rgba(124, 58, 237, 0.13);

            font-size: 25px;
        }


        .management-card h3 {
            margin:
                    0
                    0
                    9px;

            font-size: 18px;
        }


        .management-card p {
            flex: 1;

            margin:
                    0
                    0
                    22px;

            color: #94a3b8;

            font-size: 14px;

            line-height: 1.65;
        }


        .management-card .btn {
            width: 100%;

            justify-content: center;
        }


        .management-status {
            position: absolute;

            top: 18px;
            right: 18px;

            padding: 5px 8px;

            border-radius: 999px;

            background:
                    rgba(34, 197, 94, 0.10);

            border:
                    1px solid
                    rgba(34, 197, 94, 0.20);

            color: #86efac;

            font-size: 9px;
            font-weight: 800;

            letter-spacing: 0.7px;
        }


        /* =====================================================
           SYSTEM INFORMATION
        ====================================================== */

        .system-grid {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(210px, 1fr)
                    );

            gap: 15px;
        }


        .system-item {
            padding: 19px;

            border-radius: 15px;

            background:
                    rgba(30, 41, 59, 0.65);

            border:
                    1px solid
                    rgba(148, 163, 184, 0.10);
        }


        .system-label {
            margin-bottom: 8px;

            color: #94a3b8;

            font-size: 12px;
        }


        .system-value {
            font-weight: 750;
        }


        /* =====================================================
           SUMMARY
        ====================================================== */

        .dashboard-summary {
            margin-top: 35px;

            padding: 24px;

            border-radius: 18px;

            background:
                    linear-gradient(
                            135deg,
                            rgba(37, 99, 235, 0.10),
                            rgba(124, 58, 237, 0.08)
                    );

            border:
                    1px solid
                    rgba(96, 165, 250, 0.18);

            color: #cbd5e1;

            line-height: 1.8;
        }


        .dashboard-summary strong {
            color: #ffffff;
        }


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (
        max-width: 760px
        ) {

            .admin-dashboard {
                padding-top: 24px;
            }


            .dashboard-hero {
                flex-direction: column;

                align-items: flex-start;

                padding: 22px;
            }


            .dashboard-section-header {
                flex-direction: column;

                align-items: flex-start;
            }


            .dashboard-stats {
                grid-template-columns:
                        repeat(
                                2,
                                1fr
                        );
            }

        }


        @media (
        max-width: 480px
        ) {

            .dashboard-stats {
                grid-template-columns:
                        1fr;
            }


            .management-grid {
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
     DASHBOARD
========================================================= -->

<main class="admin-dashboard">


    <div class="container">


        <!-- =====================================================
             HERO
        ====================================================== -->

        <section class="dashboard-hero">


            <div class="dashboard-hero-content">


                <div class="dashboard-badge">

                    ⚡ Administrator Dashboard

                </div>


                <h1 class="dashboard-title">

                    Welcome back,
                    <span>

                        <%= HtmlUtil.escape(
                                adminName
                        ) %>

                    </span>

                </h1>


                <p class="dashboard-description">

                    Manage the CineRent movie catalogue,
                    customers, rentals and reviews from
                    one central administration dashboard.

                </p>


            </div>


            <div class="dashboard-status">

                ● System Online

            </div>


        </section>


        <!-- =====================================================
             STATISTICS
        ====================================================== -->

        <div class="dashboard-section-header">

            <div>

                <h2>
                    Dashboard Overview
                </h2>

                <p>
                    Live information from CineRent
                    file-based storage.
                </p>

            </div>

        </div>


        <section class="dashboard-stats">


            <!-- MOVIES -->

            <div class="dashboard-stat-card">

                <div class="dashboard-stat-icon">
                    🎬
                </div>

                <div class="dashboard-stat-value stat-blue">

                    <%= movieCount %>

                </div>

                <div class="dashboard-stat-label">

                    Total Movies

                </div>

            </div>


            <!-- CUSTOMERS -->

            <div class="dashboard-stat-card">

                <div class="dashboard-stat-icon">
                    👥
                </div>

                <div class="dashboard-stat-value stat-blue">

                    <%= customerCount %>

                </div>

                <div class="dashboard-stat-label">

                    Registered Customers

                </div>

            </div>


            <!-- ACTIVE RENTALS -->

            <div class="dashboard-stat-card">

                <div class="dashboard-stat-icon">
                    📀
                </div>

                <div class="dashboard-stat-value stat-yellow">

                    <%= activeRentalCount %>

                </div>

                <div class="dashboard-stat-label">

                    Active Rentals

                </div>

            </div>


            <!-- RETURNED RENTALS -->

            <div class="dashboard-stat-card">

                <div class="dashboard-stat-icon">
                    ✅
                </div>

                <div class="dashboard-stat-value stat-green">

                    <%= returnedRentalCount %>

                </div>

                <div class="dashboard-stat-label">

                    Returned Rentals

                </div>

            </div>


            <!-- REVIEWS -->

            <div class="dashboard-stat-card">

                <div class="dashboard-stat-icon">
                    ⭐
                </div>

                <div class="dashboard-stat-value stat-purple">

                    <%= reviewCount %>

                </div>

                <div class="dashboard-stat-label">

                    Customer Reviews

                </div>

            </div>


            <!-- COPIES -->

            <div class="dashboard-stat-card">

                <div class="dashboard-stat-icon">
                    📦
                </div>

                <div class="dashboard-stat-value stat-green">

                    <%= availableCopies %>

                </div>

                <div class="dashboard-stat-label">

                    Available Movie Copies

                </div>

            </div>


        </section>


        <!-- =====================================================
             MANAGEMENT
        ====================================================== -->

        <div class="dashboard-section-header">

            <div>

                <h2>
                    Management
                </h2>

                <p>
                    Open a CineRent administration module.
                </p>

            </div>

        </div>


        <section class="management-grid">


            <!-- =================================================
                 MOVIE MANAGEMENT
            ================================================== -->

            <div class="management-card">


                <span class="management-status">
                    ACTIVE
                </span>


                <div class="management-icon">
                    🎥
                </div>


                <h3>
                    Movie Management
                </h3>


                <p>

                    Add new movies, edit movie information,
                    update rental prices, ratings,
                    descriptions and available copies.

                </p>


                <a
                        href="<%= ctx %>/movies"
                        class="btn btn-primary"
                >

                    Manage Movies

                </a>


            </div>


            <!-- =================================================
                 CUSTOMER MANAGEMENT
            ================================================== -->

            <div class="management-card">


                <span class="management-status">
                    ACTIVE
                </span>


                <div class="management-icon">
                    👥
                </div>


                <h3>
                    Customer Management
                </h3>


                <p>

                    View registered customers and search
                    customers using their ID, name,
                    email address or phone number.

                </p>


                <a
                        href="<%= ctx %>/admin/customers"
                        class="btn btn-primary"
                >

                    Manage Customers

                </a>


            </div>


            <!-- =================================================
                 RENTAL MANAGEMENT
            ================================================== -->

            <div class="management-card">


                <span class="management-status">
                    ACTIVE
                </span>


                <div class="management-icon">
                    📀
                </div>


                <h3>
                    Rental Management
                </h3>


                <p>

                    View active rentals, returned movies
                    and the complete CineRent customer
                    rental history.

                </p>


                <a
                        href="<%= ctx %>/admin/rentals"
                        class="btn btn-primary"
                >

                    Manage Rentals

                </a>


            </div>


            <!-- =================================================
                 REVIEW MANAGEMENT
            ================================================== -->

            <div class="management-card">


                <span class="management-status">
                    ACTIVE
                </span>


                <div class="management-icon">
                    ⭐
                </div>


                <h3>
                    Review Management
                </h3>


                <p>

                    View customer ratings and comments,
                    search and filter reviews and remove
                    inappropriate reviews when required.

                </p>


                <a
                        href="<%= ctx %>/admin/reviews"
                        class="btn btn-primary"
                >

                    Manage Reviews

                </a>


            </div>


        </section>


        <!-- =====================================================
             SYSTEM ACTIVITY
        ====================================================== -->

        <div class="dashboard-section-header">

            <div>

                <h2>
                    System Activity
                </h2>

                <p>
                    Current CineRent activity at a glance.
                </p>

            </div>

        </div>


        <section class="system-grid">


            <div class="system-item">

                <div class="system-label">
                    Rental Activity
                </div>

                <div class="system-value">

                    <%= activeRentalCount %>
                    Active /

                    <%= returnedRentalCount %>
                    Returned

                </div>

            </div>


            <div class="system-item">

                <div class="system-label">
                    Total Rental Records
                </div>

                <div class="system-value">

                    <%= totalRentalCount %>
                    Rentals

                </div>

            </div>


            <div class="system-item">

                <div class="system-label">
                    Movie Inventory
                </div>

                <div class="system-value">

                    <%= availableCopies %>
                    Copies Available

                </div>

            </div>


            <div class="system-item">

                <div class="system-label">
                    Platform Customers
                </div>

                <div class="system-value">

                    <%= customerCount %>
                    Customers

                </div>

            </div>


            <div class="system-item">

                <div class="system-label">
                    Customer Feedback
                </div>

                <div class="system-value">

                    <%= reviewCount %>
                    Reviews

                </div>

            </div>


            <div class="system-item">

                <div class="system-label">
                    Movie Catalogue
                </div>

                <div class="system-value">

                    <%= movieCount %>
                    Movies

                </div>

            </div>


        </section>


        <!-- =====================================================
             SYSTEM SUMMARY
        ====================================================== -->

        <section class="dashboard-summary">


            <strong>
                System Summary:
            </strong>


            CineRent currently contains

            <strong>
                <%= movieCount %>
            </strong>

            movies,

            <strong>
                <%= customerCount %>
            </strong>

            registered customers,

            <strong>
                <%= totalRentalCount %>
            </strong>

            rental records,

            <strong>
                <%= activeRentalCount %>
            </strong>

            active rentals,

            <strong>
                <%= returnedRentalCount %>
            </strong>

            returned rentals,

            <strong>
                <%= reviewCount %>
            </strong>

            customer reviews and

            <strong>
                <%= availableCopies %>
            </strong>

            available movie copies.


        </section>


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
        defer
></script>


</body>

</html>