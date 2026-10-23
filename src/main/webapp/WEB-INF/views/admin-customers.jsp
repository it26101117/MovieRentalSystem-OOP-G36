<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.util.List" %>
<%@ page import="com.movierental.model.Customer" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");

    String search = (String) request.getAttribute("search");
    if (search == null) {
        search = "";
    }

    String ctx = request.getContextPath();
%>

<!DOCTYPE html>

<html>

<head>

    <meta charset="UTF-8">

    <meta
        name="viewport"
        content="width=device-width, initial-scale=1"
    >

    <title>
        Customers | CineRent
    </title>

    <link
        rel="stylesheet"
        href="<%= ctx %>/css/style.css"
    >

</head>


<body>


<jsp:include
    page="/WEB-INF/views/partials/admin-nav.jsp"
/>


<main class="page">

    <div class="container">


        <div class="page-header">

            <div>

                <h1 class="page-title">
                    Customers
                </h1>

                <p class="page-description">
                    Manage registered customers.
                </p>

            </div>

        </div>


        <div class="admin-toolbar">

            <form
                method="get"
                action="<%= ctx %>/admin/customers"
                class="search-box"
            >

                <span class="search-icon">
                    ⌕
                </span>

                <input
                    class="form-control"
                    type="search"
                    name="search"
                    value="<%= HtmlUtil.escape(search) %>"
                    placeholder="Search customers..."
                >

            </form>

        </div>


        <div class="table-wrapper">

            <table>

                <thead>

                <tr>
                    <th>#</th>
                    <th>Customer</th>
                    <th>Email</th>
                    <th>Phone</th>
                    <th>User ID</th>
                </tr>

                </thead>


                <tbody>


                <%
                    if (customers != null) {

                        int index = 1;

                        for (Customer customer: customers) {

                            String name = customer.getName();

                            String initial = name != null && !name.isEmpty()? name.substring(0,1).toUpperCase() : "C";
                %>


                <tr>

                    <td>
                        <%= index++ %>
                    </td>


                    <td>

                        <div class="customer-cell">

                            <span class="customer-avatar">
                                <%= initial %>
                            </span>

                            <span class="table-title">
                                <%= HtmlUtil.escape(customer.getName()) %>
                            </span>

                        </div>

                    </td>


                    <td>
                        <%= HtmlUtil.escape(customer.getEmail()) %>
                    </td>


                    <td>
                        <%= HtmlUtil.escape(customer.getPhoneNumber()) %>
                    </td>


                    <td>
                        <span class="badge badge-primary">
                            <%= customer.getUserId() %>
                        </span>
                    </td>

                </tr>


                <%
                        }
                    }
                %>


                </tbody>

            </table>

        </div>

    </div>

</main>


</body>

</html>