<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String error =
            (String) request.getAttribute(
                    "error"
            );


    boolean registered =
            "true".equalsIgnoreCase(
                    request.getParameter(
                            "registered"
                    )
            );


    String currentRole =
            (String) session.getAttribute(
                    "role"
            );


    String currentUser =
            (String) session.getAttribute(
                    "userName"
            );


    // Extra protection if JSP is directly reached
    if (
            currentUser != null
                    &&
                    currentRole != null
    ) {

        if (
                "ADMIN".equalsIgnoreCase(
                        currentRole
                )
        ) {

            response.sendRedirect(
                    request.getContextPath()
                            + "/admin"
            );

        } else {

            response.sendRedirect(
                    request.getContextPath()
                            + "/catalog"
            );
        }

        return;
    }
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Sign In | CineRent
    </title>


    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">

</head>


<body>


<!-- =========================================================
     NAVBAR
========================================================= -->

<nav class="navbar">

    <div class="container navbar-inner">


        <a href="<%= request.getContextPath() %>/"
           class="brand">

            <span class="brand-icon">

                🎬

            </span>

            CineRent

        </a>


        <div class="nav-links">


            <a href="<%= request.getContextPath() %>/">

                Home

            </a>


            <a href="<%= request.getContextPath() %>/register"
               class="btn btn-primary">

                Create Account

            </a>


        </div>


    </div>

</nav>


<!-- =========================================================
     LOGIN PAGE
========================================================= -->

<main class="auth-page">

    <div class="container auth-layout">


        <!-- =================================================
             LEFT SIDE
        ================================================== -->

        <section class="auth-intro">


            <div class="auth-label">

                🎞️ Welcome Back

            </div>


            <h1>

                Your movies are

                <span>
                    waiting.
                </span>

            </h1>


            <p>

                Sign in to browse the CineRent catalogue,
                manage your active rentals, see recently
                watched movies and share your ratings.

            </p>


            <div class="auth-feature-list">


                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        🎬

                    </span>

                    Browse and rent available movies

                </div>


                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        📀

                    </span>

                    Manage rentals and returns

                </div>


                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        🕘

                    </span>

                    View your recently watched history

                </div>


                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        ⭐

                    </span>

                    Rate and review completed movies

                </div>


            </div>


        </section>


        <!-- =================================================
             LOGIN CARD
        ================================================== -->

        <section class="auth-card">


            <div class="auth-card-header">

                <h2>

                    Sign in

                </h2>


                <p>

                    Enter your CineRent account details
                    to continue.

                </p>

            </div>


            <!-- =============================================
                 REGISTER SUCCESS
            ============================================== -->

            <%
                if (registered) {
            %>


            <div class="alert alert-success">

                ✓ Account created successfully.
                You can now sign in.

            </div>


            <%
                }
            %>


            <!-- =============================================
                 LOGIN ERROR
            ============================================== -->

            <%
                if (
                        error != null
                                &&
                                !error.trim().isEmpty()
                ) {
            %>


            <div class="alert alert-danger">

                <%= HtmlUtil.escape(error) %>

            </div>


            <%
                }
            %>


            <!-- =============================================
                 LOGIN FORM
            ============================================== -->

            <form method="post"
                  action="<%= request.getContextPath() %>/login">


                <!-- EMAIL -->

                <div class="form-group">


                    <label for="email"
                           class="form-label">

                        Email Address

                    </label>


                    <div class="input-wrapper">


                        <span class="input-icon">

                            ✉

                        </span>


                        <input type="email"
                               id="email"
                               name="email"
                               class="form-control with-icon"
                               placeholder="you@example.com"
                               autocomplete="email"
                               required>


                    </div>


                </div>


                <!-- PASSWORD -->

                <div class="form-group">


                    <label for="password"
                           class="form-label">

                        Password

                    </label>


                    <div class="password-wrapper">


                        <input type="password"
                               id="password"
                               name="password"
                               class="form-control"
                               placeholder="Enter your password"
                               autocomplete="current-password"
                               required>


                        <button type="button"
                                class="password-toggle"
                                onclick="togglePassword('password', this)">

                            SHOW

                        </button>


                    </div>


                </div>


                <!-- LOGIN -->

                <button type="submit"
                        class="btn btn-primary auth-submit">

                    Sign In →

                </button>


            </form>


            <div class="auth-divider">

                NEW TO CINERENT?

            </div>


            <div class="auth-switch">

                Don't have an account?

                <a href="<%= request.getContextPath() %>/register">

                    Create one now

                </a>

            </div>


            <a href="<%= request.getContextPath() %>/"
               class="back-home">

                ← Back to CineRent

            </a>


        </section>


    </div>

</main>


<script>

    function togglePassword(inputId, button) {

        const input =
            document.getElementById(
                inputId
            );


        if (
            input.type === "password"
        ) {

            input.type =
                "text";

            button.textContent =
                "HIDE";

        } else {

            input.type =
                "password";

            button.textContent =
                "SHOW";
        }
    }

</script>


</body>

</html>