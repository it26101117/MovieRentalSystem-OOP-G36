<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Customer" %>

<%
    String adminName =
            (String) session.getAttribute(
                    "userName"
            );

    String role =
            (String) session.getAttribute(
                    "role"
            );


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


    List<Customer> customers =
            (List<Customer>)
                    request.getAttribute(
                            "customers"
                    );


    Integer customerCount =
            (Integer)
                    request.getAttribute(
                            "customerCount"
                    );


    String search =
            (String)
                    request.getAttribute(
                            "search"
                    );


    if (customerCount == null) {
        customerCount = 0;
    }

    if (search == null) {
        search = "";
    }
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Customer Management | CineRent
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
            width: 92%;

            max-width: 1200px;

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


        /* SUMMARY */

        .summary {
            background: #1e293b;

            padding: 20px;

            border-radius: 10px;

            margin-bottom: 25px;
        }


        .summary strong {
            color: #60a5fa;

            font-size: 24px;
        }


        /* SEARCH */

        .search-box {
            background: #1e293b;

            padding: 20px;

            border-radius: 10px;

            margin-bottom: 25px;
        }


        .search-form {
            display: flex;

            gap: 10px;
        }


        .search-input {
            flex: 1;

            padding: 12px 14px;

            background: #0f172a;

            color: white;

            border: 1px solid #475569;

            border-radius: 7px;

            font-size: 14px;
        }


        .search-button {
            background: #2563eb;

            color: white;

            border: none;

            padding: 12px 20px;

            border-radius: 7px;

            cursor: pointer;

            font-weight: bold;
        }


        .search-button:hover {
            background: #1d4ed8;
        }


        .clear-button {
            display: inline-block;

            background: #475569;

            color: white;

            padding: 12px 18px;

            border-radius: 7px;

            text-decoration: none;
        }


        /* TABLE */

        .table-wrapper {
            overflow-x: auto;

            background: #1e293b;

            border-radius: 12px;
        }


        table {
            width: 100%;

            border-collapse: collapse;
        }


        th {
            background: #172033;

            color: #94a3b8;

            padding: 15px;

            text-align: left;

            font-size: 13px;

            text-transform: uppercase;
        }


        td {
            padding: 16px 15px;

            border-top: 1px solid #334155;
        }


        tr:hover {
            background: #263449;
        }


        .customer-id {
            color: #60a5fa;

            font-weight: bold;
        }


        .email {
            color: #cbd5e1;
        }


        .role {
            display: inline-block;

            background: #14532d;

            color: #86efac;

            padding: 5px 9px;

            border-radius: 20px;

            font-size: 12px;

            font-weight: bold;
        }


        .empty {
            padding: 40px;

            text-align: center;

            color: #94a3b8;
        }


        @media (max-width: 700px) {

            .header {
                flex-direction: column;

                align-items: flex-start;
            }


            .search-form {
                flex-direction: column;
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
                👥 Customer Management
            </h1>

            <p class="subtitle">
                View registered CineRent customers.
            </p>

        </div>


        <div class="nav">

            <a href="<%= request.getContextPath() %>/admin">
                Dashboard
            </a>

            <a href="<%= request.getContextPath() %>/movies">
                Movies
            </a>

            <a href="<%= request.getContextPath() %>/logout"
               class="logout">
                Logout
            </a>

        </div>

    </div>


    <!-- SUMMARY -->

    <div class="summary">

        Customers shown:

        <strong>
            <%= customerCount %>
        </strong>

    </div>


    <!-- SEARCH -->

    <div class="search-box">

        <form method="get"
              action="<%= request.getContextPath() %>/admin/customers"
              class="search-form">


            <input type="text"
                   name="search"
                   class="search-input"
                   value="<%= search %>"
                   placeholder="Search by ID, name, email or phone">


            <button type="submit"
                    class="search-button">

                Search

            </button>


            <a href="<%= request.getContextPath() %>/admin/customers"
               class="clear-button">

                Clear

            </a>

        </form>

    </div>


    <!-- CUSTOMER TABLE -->

    <div class="table-wrapper">


        <%
            if (
                    customers == null
                            ||
                            customers.isEmpty()
            ) {
        %>


        <div class="empty">

            <h3>
                No Customers Found
            </h3>

            <p>
                No customer accounts match
                the current search.
            </p>

        </div>


        <%
        } else {
        %>


        <table>

            <thead>

            <tr>

                <th>
                    Customer ID
                </th>

                <th>
                    Name
                </th>

                <th>
                    Email
                </th>

                <th>
                    Phone
                </th>

                <th>
                    Role
                </th>

            </tr>

            </thead>


            <tbody>


            <%
                for (
                        Customer customer :
                        customers
                ) {
            %>


            <tr>

                <td class="customer-id">

                    <%= customer.getUserId() %>

                </td>


                <td>

                    <%= customer.getName() %>

                </td>


                <td class="email">

                    <%= customer.getEmail() %>

                </td>


                <td>

                    <%= customer.getPhoneNumber() %>

                </td>


                <td>

                    <span class="role">

                        <%= customer.getRole() %>

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