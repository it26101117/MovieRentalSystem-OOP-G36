<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String adminName =
            (String) session.getAttribute("userName");

    String role =
            (String) session.getAttribute("role");


    // =========================================================
    // ADMIN ACCESS CHECK
    // =========================================================

    if (
            adminName == null
                    ||
                    role == null
                    ||
                    !"ADMIN".equalsIgnoreCase(role)
    ) {

        response.sendRedirect(
                request.getContextPath()
                        + "/login"
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

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Admin Dashboard | CineRent
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
           MAIN CONTAINER
        ====================================================== */

        .container {
            width: 92%;

            max-width: 1280px;

            margin: 40px auto;
        }


        /* =====================================================
           HEADER
        ====================================================== */

        .header {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            margin-bottom: 35px;
        }


        .header-title h1 {
            margin: 0;

            font-size: 30px;
        }


        .subtitle {
            color: #94a3b8;

            margin-top: 8px;
        }


        .welcome {
            color: #cbd5e1;

            margin-top: 10px;

            margin-bottom: 0;
        }


        .welcome strong {
            color: #60a5fa;
        }


        /* =====================================================
           NAVIGATION
        ====================================================== */

        .nav {
            display: flex;

            align-items: center;

            gap: 18px;

            flex-wrap: wrap;
        }


        .nav a {
            color: #60a5fa;

            text-decoration: none;

            font-size: 14px;

            font-weight: bold;
        }


        .nav a:hover {
            text-decoration: underline;
        }


        .logout {
            color: #f87171 !important;
        }


        /* =====================================================
           SECTION HEADINGS
        ====================================================== */

        .section-heading {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            margin-bottom: 20px;
        }


        .section-heading h2 {
            margin: 0;
        }


        .section-description {
            color: #94a3b8;

            font-size: 14px;

            margin-top: 6px;
        }


        /* =====================================================
           STATISTICS
        ====================================================== */

        .statistics {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(190px, 1fr)
                    );

            gap: 20px;

            margin-bottom: 45px;
        }


        .stat-card {
            background: #1e293b;

            padding: 24px;

            border-radius: 12px;

            box-shadow:
                    0 8px 25px
                    rgba(0, 0, 0, 0.18);

            border: 1px solid transparent;

            transition:
                    transform 0.2s,
                    border-color 0.2s;
        }


        .stat-card:hover {
            transform: translateY(-3px);

            border-color: #334155;
        }


        .stat-icon {
            font-size: 30px;

            margin-bottom: 12px;
        }


        .stat-number {
            font-size: 34px;

            font-weight: bold;

            margin-bottom: 6px;
        }


        .stat-label {
            color: #94a3b8;

            font-size: 14px;
        }


        .blue-number {
            color: #60a5fa;
        }


        .yellow-number {
            color: #facc15;
        }


        .green-number {
            color: #4ade80;
        }


        .purple-number {
            color: #c084fc;
        }


        /* =====================================================
           MANAGEMENT
        ====================================================== */

        .management-grid {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(250px, 1fr)
                    );

            gap: 20px;

            margin-bottom: 45px;
        }


        .management-card {
            display: block;

            background: #1e293b;

            padding: 26px;

            border-radius: 12px;

            text-decoration: none;

            color: white;

            border:
                    1px solid transparent;

            min-height: 225px;

            transition:
                    transform 0.2s,
                    border-color 0.2s,
                    background 0.2s;
        }


        .management-card:hover {
            transform: translateY(-4px);

            border-color: #3b82f6;

            background: #243146;
        }


        .management-icon {
            font-size: 36px;

            margin-bottom: 17px;
        }


        .management-card h3 {
            margin-top: 0;

            margin-bottom: 10px;
        }


        .management-card p {
            color: #94a3b8;

            line-height: 1.5;

            margin-bottom: 0;
        }


        /* =====================================================
           ACTIVE STATUS
        ====================================================== */

        .working {
            display: inline-block;

            background: #14532d;

            color: #86efac;

            padding: 6px 10px;

            border-radius: 20px;

            font-size: 11px;

            font-weight: bold;

            margin-top: 18px;
        }


        /* =====================================================
           QUICK INFORMATION
        ====================================================== */

        .quick-info {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(220px, 1fr)
                    );

            gap: 15px;

            margin-top: 25px;
        }


        .quick-item {
            background: #1e293b;

            padding: 18px;

            border-radius: 9px;
        }


        .quick-label {
            color: #94a3b8;

            font-size: 13px;

            margin-bottom: 7px;
        }


        .quick-value {
            font-weight: bold;
        }


        /* =====================================================
           SYSTEM SUMMARY
        ====================================================== */

        .info-box {
            margin-top: 35px;

            background: #172033;

            border-left:
                    4px solid #2563eb;

            padding: 22px;

            border-radius: 8px;

            color: #cbd5e1;

            line-height: 1.7;
        }


        .info-box strong {
            color: #60a5fa;
        }


        /* =====================================================
           FOOTER
        ====================================================== */

        .footer {
            color: #64748b;

            text-align: center;

            font-size: 13px;

            margin-top: 45px;

            padding-bottom: 20px;
        }


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (max-width: 760px) {

            .header {
                flex-direction: column;

                align-items: flex-start;
            }


            .section-heading {
                flex-direction: column;

                align-items: flex-start;
            }


            .statistics {
                grid-template-columns: 1fr;
            }


            .management-grid {
                grid-template-columns: 1fr;
            }

        }

    </style>

</head>


<body>

<div class="container">


    <!-- =====================================================
         HEADER
    ====================================================== -->

    <div class="header">

        <div class="header-title">

            <h1>
                🎬 CineRent Admin
            </h1>


            <p class="subtitle">
                Movie Rental & Review Platform
            </p>


            <p class="welcome">

                Welcome,

                <strong>
                    <%= adminName %>
                </strong>

                👋

            </p>

        </div>


        <!-- =================================================
             NAVIGATION
        ================================================== -->

        <div class="nav">

            <a href="<%= request.getContextPath() %>/admin">

                Dashboard

            </a>


            <a href="<%= request.getContextPath() %>/movies">

                Movies

            </a>


            <a href="<%= request.getContextPath() %>/admin/customers">

                Customers

            </a>


            <a href="<%= request.getContextPath() %>/admin/rentals">

                Rentals

            </a>


            <a href="<%= request.getContextPath() %>/admin/reviews">

                Reviews

            </a>


            <a href="<%= request.getContextPath() %>/">

                Home

            </a>


            <a href="<%= request.getContextPath() %>/logout"
               class="logout">

                Logout

            </a>

        </div>

    </div>


    <!-- =====================================================
         DASHBOARD OVERVIEW
    ====================================================== -->

    <div class="section-heading">

        <div>

            <h2>
                Dashboard Overview
            </h2>


            <div class="section-description">

                Live information generated from
                CineRent text-file storage.

            </div>

        </div>

    </div>


    <!-- =====================================================
         STATISTICS
    ====================================================== -->

    <div class="statistics">


        <!-- MOVIES -->

        <div class="stat-card">

            <div class="stat-icon">

                🎬

            </div>


            <div class="stat-number blue-number">

                <%= movieCount %>

            </div>


            <div class="stat-label">

                Total Movies

            </div>

        </div>


        <!-- CUSTOMERS -->

        <div class="stat-card">

            <div class="stat-icon">

                👥

            </div>


            <div class="stat-number blue-number">

                <%= customerCount %>

            </div>


            <div class="stat-label">

                Registered Customers

            </div>

        </div>


        <!-- ACTIVE RENTALS -->

        <div class="stat-card">

            <div class="stat-icon">

                📀

            </div>


            <div class="stat-number yellow-number">

                <%= activeRentalCount %>

            </div>


            <div class="stat-label">

                Active Rentals

            </div>

        </div>


        <!-- RETURNED RENTALS -->

        <div class="stat-card">

            <div class="stat-icon">

                ✅

            </div>


            <div class="stat-number green-number">

                <%= returnedRentalCount %>

            </div>


            <div class="stat-label">

                Returned Rentals

            </div>

        </div>


        <!-- REVIEWS -->

        <div class="stat-card">

            <div class="stat-icon">

                ⭐

            </div>


            <div class="stat-number purple-number">

                <%= reviewCount %>

            </div>


            <div class="stat-label">

                Customer Reviews

            </div>

        </div>


        <!-- AVAILABLE COPIES -->

        <div class="stat-card">

            <div class="stat-icon">

                📦

            </div>


            <div class="stat-number green-number">

                <%= availableCopies %>

            </div>


            <div class="stat-label">

                Available Movie Copies

            </div>

        </div>


    </div>


    <!-- =====================================================
         MANAGEMENT SECTION
    ====================================================== -->

    <div class="section-heading">

        <div>

            <h2>
                Management
            </h2>


            <div class="section-description">

                Access all CineRent
                administration modules.

            </div>

        </div>

    </div>


    <div class="management-grid">


        <!-- =================================================
             MOVIE MANAGEMENT
        ================================================== -->

        <a class="management-card"
           href="<%= request.getContextPath() %>/movies">


            <div class="management-icon">

                🎥

            </div>


            <h3>
                Movie Management
            </h3>


            <p>

                Add, edit, view and delete movies.
                Manage rental prices, ratings,
                descriptions and available copies.

            </p>


            <div class="working">

                ● ACTIVE

            </div>

        </a>


        <!-- =================================================
             CUSTOMER MANAGEMENT
        ================================================== -->

        <a class="management-card"
           href="<%= request.getContextPath() %>/admin/customers">


            <div class="management-icon">

                👥

            </div>


            <h3>
                Customer Management
            </h3>


            <p>

                View registered customers and
                search using customer ID,
                name, email or phone number.

            </p>


            <div class="working">

                ● ACTIVE

            </div>

        </a>


        <!-- =================================================
             RENTAL MANAGEMENT
        ================================================== -->

        <a class="management-card"
           href="<%= request.getContextPath() %>/admin/rentals">


            <div class="management-icon">

                📀

            </div>


            <h3>
                Rental Management
            </h3>


            <p>

                View active rentals,
                returned movies and complete
                customer rental history.

            </p>


            <div class="working">

                ● ACTIVE

            </div>

        </a>


        <!-- =================================================
             REVIEW MANAGEMENT
        ================================================== -->

        <a class="management-card"
           href="<%= request.getContextPath() %>/admin/reviews">


            <div class="management-icon">

                ⭐

            </div>


            <h3>
                Review Management
            </h3>


            <p>

                View customer ratings,
                comments and movie reviews.
                Search, filter and remove
                reviews when necessary.

            </p>


            <div class="working">

                ● ACTIVE

            </div>

        </a>


    </div>


    <!-- =====================================================
         SYSTEM ACTIVITY
    ====================================================== -->

    <div class="section-heading">

        <div>

            <h2>
                System Activity
            </h2>


            <div class="section-description">

                Current CineRent status
                at a glance.

            </div>

        </div>

    </div>


    <div class="quick-info">


        <!-- RENTAL ACTIVITY -->

        <div class="quick-item">

            <div class="quick-label">

                Rental Activity

            </div>


            <div class="quick-value">

                <%= activeRentalCount %>
                Active /

                <%= returnedRentalCount %>
                Returned

            </div>

        </div>


        <!-- TOTAL RENTALS -->

        <div class="quick-item">

            <div class="quick-label">

                Total Rental Records

            </div>


            <div class="quick-value">

                <%= totalRentalCount %>
                Rentals

            </div>

        </div>


        <!-- MOVIE INVENTORY -->

        <div class="quick-item">

            <div class="quick-label">

                Movie Inventory

            </div>


            <div class="quick-value">

                <%= availableCopies %>
                Copies Available

            </div>

        </div>


        <!-- CUSTOMERS -->

        <div class="quick-item">

            <div class="quick-label">

                Platform Customers

            </div>


            <div class="quick-value">

                <%= customerCount %>
                Customers

            </div>

        </div>


        <!-- REVIEWS -->

        <div class="quick-item">

            <div class="quick-label">

                Customer Feedback

            </div>


            <div class="quick-value">

                <%= reviewCount %>
                Reviews

            </div>

        </div>


        <!-- MOVIES -->

        <div class="quick-item">

            <div class="quick-label">

                Movie Catalogue

            </div>


            <div class="quick-value">

                <%= movieCount %>
                Movies

            </div>

        </div>


    </div>


    <!-- =====================================================
         SYSTEM SUMMARY
    ====================================================== -->

    <div class="info-box">


        <strong>
            System Summary:
        </strong>


        CineRent currently has

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

        movie copies currently available.


    </div>


    <!-- =====================================================
         FOOTER
    ====================================================== -->

    <div class="footer">

        CineRent Movie Rental & Review Platform
        • Administrator Dashboard

    </div>


</div>

</body>

</html>