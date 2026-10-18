<%@ page contentType="text/html;charset=UTF-8" %>

<%
    String error = (String) request.getAttribute("error");
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
        Create Account | CineRent
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
                class="brand"
                href="<%= request.getContextPath() %>/"
            >

                <span class="brand-mark">
                    C
                </span>

                CineRent

            </a>


            <div style="position:relative;z-index:3;">

                <span class="auth-label">
                    Join CineRent
                </span>

                <h1>
                    Your movie
                    collection
                    begins here.
                </h1>

                <p>
                    Create an account and start
                    renting, reviewing and tracking
                    your movies.
                </p>

            </div>


            <small
                style="
                    position:relative;
                    z-index:3;
                    color:#8491a3;
                "
            >
                Browse · Rent · Return · Review
            </small>

        </section>



        <section class="auth-form-side">

            <h1>
                Create account
            </h1>

            <p>
                Join CineRent in a few seconds.
            </p>

            <% if (error != null) { %>

                <div class="alert alert-danger">
                    <%= error %>
                </div>

            <% } %>


            <form
                method="post"
                action="<%= request.getContextPath() %>/register"
            >

                <div class="form-group">

                    <label class="form-label">
                        Full name
                    </label>

                    <input
                        type="text"
                        name="name"
                        class="form-control"
                        required
                    >

                </div>


                <div class="form-group">

                    <label class="form-label">
                        Email
                    </label>

                    <input
                        type="email"
                        name="email"
                        class="form-control"
                        required
                    >

                </div>


                <div class="form-group">

                    <label class="form-label">
                        Phone number
                    </label>

                    <input
                        type="text"
                        name="phone"
                        class="form-control"
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
                        required
                    >

                </div>

                <button
                    class="btn btn-primary btn-full"
                    type="submit"
                >
                    Create Account
                </button>

            </form>

            <div class="auth-switch">

                Already registered?

                <a
                    href="<%= request.getContextPath() %>/login"
                >
                    Sign in
                </a>

            </div>

        </section>

    </div>

</div>

</body>

</html>