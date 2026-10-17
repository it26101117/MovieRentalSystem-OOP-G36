<%@ page contentType="text/html;charset=UTF-8" %>

<%
    String error = (String) request.getAttribute("error");

    boolean registered = "true".equalsIgnoreCase(request.getParameter("registered"));
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
        Sign In | CineRent
    </title>

    <link
        rel="stylesheet"
        href="<%= request.getContextPath() %>/css/style.css"
    >

</head>
<body>

<div class="auth-page">

    <div class="auth-shell">

        <section class="auth-showcase">

            <a
                href="<%= request.getContextPath() %>/"
                class="brand"
            >

                <span class="brand-mark">
                    C
                </span>

                CineRent

            </a>
            <div style="position:relative;z-index:3;">

                <span class="auth-label">
                    Welcome back
                </span>

                <h1>
                    Continue your
                    <span class="gradient-text">
                        movie journey.
                    </span>
                </h1>

                <p>
                    Browse titles, manage rentals,
                    revisit your watch history and
                    share reviews.
                </p>

            </div>

            <small
                style="
                    position:relative;
                    z-index:3;
                    color:#8491a3;
                "
            >
                CineRent · Movie Rental Platform
            </small>

        </section>

        <section class="auth-form-side">

            <h1>
                Sign in
            </h1>

            <p>
                Enter your account details.
            </p>


            <% if (registered) { %>

                <div
                    class="alert alert-success"
                    data-auto-hide
                >
                    Account created successfully.
                </div>

            <% } %>

            <% if (error != null) { %>

                <div class="alert alert-danger">
                    <%= error %>
                </div>

            <% } %>


            <form
                method="post"
                action="<%= request.getContextPath() %>/login"
            >

                <div class="form-group">

                    <label class="form-label">
                        Email address
                    </label>

                    <input
                        type="email"
                        name="email"
                        class="form-control"
                        placeholder="name@example.com"
                        required
                    >

                </div>


                <div class="form-group">

                    <label class="form-label">
                        Password
                    </label>

                    <input
                        type="password"
                        name="password"
                        class="form-control"
                        placeholder="Enter password"
                        required
                    >

                </div>


                <button
                    type="submit"
                    class="btn btn-primary btn-full"
                >
                    Sign In
                </button>

            </form>


            <div class="auth-switch">

                Don't have an account?

                <a
                    href="<%= request.getContextPath() %>/register"
                >
                    Create one
                </a>

            </div>

        </section>

    </div>

</div>


<script
    src="<%= request.getContextPath() %>/js/app.js"
    defer
></script>

</body>

</html>