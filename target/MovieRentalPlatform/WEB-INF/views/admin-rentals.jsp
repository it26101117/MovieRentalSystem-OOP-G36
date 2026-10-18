<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%@ page import="com.movierental.model.Rental" %>
<%@ page import="com.movierental.model.User" %>
<%@ page import="com.movierental.model.Movie" %>

<%
    String adminName = (String) session.getAttribute( "userName" );


    String role =(String) session.getAttribute("role");


    // ADMIN ACCESS CHECK


    if (adminName == null ||role == null|| !"ADMIN".equalsIgnoreCase(role)) {

        response.sendRedirect(request.getContextPath()+ "/login");

        return;
    }


    // GET REQUEST DATA

    List<Rental> rentals =(List<Rental>)request.getAttribute("rentals");


    Map<String, User> userMap =(Map<String, User>)request.getAttribute("userMap");

    Map<String, Movie> movieMap =(Map<String, Movie>)request.getAttribute("movieMap");

    String selectedStatus =(String)request.getAttribute("selectedStatus");

    String search =(String)request.getAttribute("search");

    Integer totalRentalCount =(Integer)request.getAttribute("totalRentalCount");

    Integer activeRentalCount =(Integer)request.getAttribute("activeRentalCount");

    Integer returnedRentalCount =(Integer)request.getAttribute("returnedRentalCount");

    Integer filteredCount =(Integer)request.getAttribute("filteredCount");

    if (selectedStatus == null) {
        selectedStatus = "all";
    }

    if (search == null) {
        search = "";
    }

    if (totalRentalCount == null) {
        totalRentalCount = 0;
    }

    if (activeRentalCount == null) {
        activeRentalCount = 0;
    }

    if (returnedRentalCount == null) {
        returnedRentalCount = 0;
    }

    if (filteredCount == null) {
        filteredCount = 0;
    }
%>


<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Rental Management | CineRent
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


        .container {
            width: 94%;

            max-width: 1350px;

            margin: 40px auto;
        }


        /* HEADER */

        .header {
            display: flex;

            justify-content: space-between;

            align-items: center;

            gap: 20px;

            margin-bottom: 30px;
        }


        .header h1 {
            margin: 0;
        }


        .subtitle {
            color: #94a3b8;

            margin-top: 8px;
        }


        .nav {
            display: flex;

            gap: 16px;

            flex-wrap: wrap;
        }


        .nav a {
            color: #60a5fa;

            text-decoration: none;
        }


        .nav a:hover {
            text-decoration: underline;
        }


        .logout {
            color: #f87171 !important;
        }


        /*  STATISTICS */

        .statistics {
            display: grid;

            grid-template-columns:
                    repeat(
                            auto-fit,
                            minmax(200px, 1fr)
                    );

            gap: 18px;

            margin-bottom: 28px;
        }


        .stat-card {
            background: #1e293b;

            padding: 22px;

            border-radius: 11px;
        }


        .stat-number {
            font-size: 30px;

            font-weight: bold;

            margin-bottom: 6px;
        }


        .stat-label {
            color: #94a3b8;

            font-size: 14px;
        }


        .active-number {
            color: #facc15;
        }


        .returned-number {
            color: #4ade80;
        }


        /*  FILTER */

        .filter-box {
            background: #1e293b;

            padding: 20px;

            border-radius: 11px;

            margin-bottom: 25px;
        }


        .filter-form {
            display: flex;

            gap: 10px;

            align-items: center;

            flex-wrap: wrap;
        }


        .search-input {
            flex: 1;

            min-width: 250px;

            padding: 12px 14px;

            background: #0f172a;

            border: 1px solid #475569;

            border-radius: 7px;

            color: white;

            font-size: 14px;
        }


        .status-select {
            padding: 12px;

            background: #0f172a;

            color: white;

            border: 1px solid #475569;

            border-radius: 7px;

            min-width: 160px;
        }


        .filter-button {
            background: #2563eb;

            color: white;

            border: none;

            padding: 12px 20px;

            border-radius: 7px;

            cursor: pointer;

            font-weight: bold;

        }


        .filter-button:hover {
            background: #1d4ed8;
        }


        .clear-button {
            display: inline-block;

            padding: 12px 18px;

            border-radius: 7px;

            background: #475569;

            color: white;

            text-decoration: none;
        }


        /*  TABLE */

        .table-wrapper {
            background: #1e293b;

            border-radius: 12px;

            overflow-x: auto;
        }


        table {
            width: 100%;

            border-collapse: collapse;

            min-width: 1000px;
        }


        th {
            background: #172033;

            color: #94a3b8;

            padding: 15px;

            text-align: left;

            font-size: 12px;

            text-transform: uppercase;
        }


        td {
            padding: 16px 15px;

            border-top: 1px solid #334155;

            vertical-align: middle;
        }


        tr:hover {
            background: #263449;
        }


        .rental-id {
            color: #60a5fa;

            font-weight: bold;
        }


        .sub-text {
            color: #94a3b8;

            font-size: 12px;

            margin-top: 4px;
        }


        /*  STATUS */

        .status {
            display: inline-block;

            padding: 6px 10px;

            border-radius: 20px;

            font-size: 11px;

            font-weight: bold;
        }


        .status-rented {
            background: #713f12;

            color: #fde68a;
        }


        .status-returned {
            background: #14532d;

            color: #86efac;
        }


        .empty {
            padding: 45px;

            text-align: center;

            color: #94a3b8;
        }


        /*  RESULT INFO */

        .result-info {
            color: #94a3b8;

            margin-bottom: 14px;

            font-size: 14px;
        }


        .result-info strong {
            color: white;
        }


        /*   MOBILE */

        @media (max-width: 700px) {

            .header {
                flex-direction: column;

                align-items: flex-start;
            }


            .filter-form {
                flex-direction: column;

                align-items: stretch;
            }


            .search-input {
                min-width: 100%;
            }

        }

    </style>

</head>


<body>

<div class="container">


    <!-- HEADER -->

    <div class="header">

        <div>

            <h1>
                📀 Rental Management
            </h1>

            <p class="subtitle">
                Monitor active rentals,
                returned movies and rental history.
            </p>

        </div>


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

            <a href="<%= request.getContextPath() %>/logout"
               class="logout">

                Logout

            </a>

        </div>

    </div>


    <!--  STATISTICS -->

    <div class="statistics">


        <div class="stat-card">

            <div class="stat-number">
                <%= totalRentalCount %>
            </div>

            <div class="stat-label">
                Total Rentals
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-number active-number">
                <%= activeRentalCount %>
            </div>

            <div class="stat-label">
                Active Rentals
            </div>

        </div>


        <div class="stat-card">

            <div class="stat-number returned-number">
                <%= returnedRentalCount %>
            </div>

            <div class="stat-label">
                Returned Rentals
            </div>

        </div>


    </div>


    <!--  FILTERS -->

    <div class="filter-box">

        <form method="get"
              action="<%= request.getContextPath() %>/admin/rentals"
              class="filter-form">


            <input type="text"
                   name="search"
                   class="search-input"
                   value="<%= search %>"
                   placeholder="Search rental ID, customer, email, movie...">


            <select name="status"
                    class="status-select">


                <option value="all"
                        <%= "all".equalsIgnoreCase(selectedStatus)
                                ? "selected"
                                : "" %>>

                    All Rentals

                </option>


                <option value="RENTED"
                        <%= "RENTED".equalsIgnoreCase(selectedStatus)
                                ? "selected"
                                : "" %>>

                    Active / Rented

                </option>


                <option value="RETURNED"
                        <%= "RETURNED".equalsIgnoreCase(selectedStatus)
                                ? "selected"
                                : "" %>>

                    Returned

                </option>

            </select>


            <button type="submit"
                    class="filter-button">

                Filter

            </button>


            <a href="<%= request.getContextPath() %>/admin/rentals"
               class="clear-button">

                Clear

            </a>


        </form>

    </div>


    <!-- RESULT COUNT -->

    <div class="result-info">

        Showing

        <strong>
            <%= filteredCount %>
        </strong>

        rental record(s).

    </div>


    <!--  RENTAL TABLE-->

    <div class="table-wrapper">


        <%
            if ( rentals == null  ||  rentals.isEmpty() ) {
        %>


        <div class="empty">

            <h3>
                No Rental Records Found
            </h3>

            <p>
                No rentals match your current
                search or filter.
            </p>

        </div>


        <%
        } else {
        %>


        <table>

            <thead>

            <tr>

                <th>
                    Rental ID
                </th>

                <th>
                    Customer
                </th>

                <th>
                    Movie
                </th>

                <th>
                    Rental Date
                </th>

                <th>
                    Return Date
                </th>

                <th>
                    Status
                </th>

            </tr>

            </thead>


            <tbody>


            <%
                for (Rental rental : rentals) {

                    User customer = userMap != null ? userMap.get(  rental.getUserId() ): null;


                    Movie movie =  movieMap != null   ? movieMap.get( rental.getMovieId() ) : null;

                    String status = rental.getStatus();


                    boolean returned = "RETURNED" .equalsIgnoreCase( status );
            %>


            <tr>


                <!-- RENTAL ID -->

                <td class="rental-id">

                    <%= rental.getRentalId() %>

                </td>


                <!-- CUSTOMER -->

                <td>

                    <%
                        if (customer != null) {
                    %>

                    <strong>
                        <%= customer.getName() %>
                    </strong>

                    <div class="sub-text">
                        <%= customer.getUserId() %>
                        •
                        <%= customer.getEmail() %>
                    </div>

                    <%
                    } else {
                    %>

                    Unknown Customer

                    <div class="sub-text">
                        <%= rental.getUserId() %>
                    </div>

                    <%
                        }
                    %>

                </td>


                <!-- MOVIE -->

                <td>

                    <%
                        if (movie != null) {
                    %>

                    <strong>
                        <%= movie.getTitle() %>
                    </strong>

                    <div class="sub-text">
                        <%= movie.getMovieId() %>
                    </div>

                    <%
                    } else {
                    %>

                    Unknown Movie

                    <div class="sub-text">
                        <%= rental.getMovieId() %>
                    </div>

                    <%
                        }
                    %>

                </td>


                <!-- RENTAL DATE -->

                <td>

                    <%= rental.getRentalDate() %>

                </td>


                <!-- RETURN DATE -->

                <td>

                    <%
                        if (rental.getReturnDate() == null || rental.getReturnDate().trim().isEmpty() ) {
                    %>

                    <span class="sub-text">
                        Not returned
                    </span>

                    <%
                    } else {
                    %>

                    <%= rental.getReturnDate() %>

                    <%
                        }
                    %>

                </td>

                <!-- STATUS -->

                <td>

                    <span class="status
                    <%= returned
                            ? "status-returned"
                            : "status-rented" %>">

                        <%= rental.getStatus() %>

                    </span>

                </td>

            </tr>

            <%
                }
            %>

            </tbody>

        </table>

        <%
            }
        %>

    </div>


</div>

</body>

</html>