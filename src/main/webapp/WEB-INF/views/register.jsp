<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String error = (String) request.getAttribute("error");
    String currentUser = (String) session.getAttribute("userName");
    String currentRole = (String) session.getAttribute("role");

    if (currentUser != null && currentRole != null) {

        if ("ADMIN".equalsIgnoreCase(currentRole)) {
            response.sendRedirect(request.getContextPath() + "/admin");

        } else {
            response.sendRedirect(request.getContextPath() + "/catalog");
        }
        return;
    }



    // Preserve form values after validation error
    String nameValue =request.getParameter("name");
    String emailValue = request.getParameter("email");
    String phoneValue = request.getParameter("phone");

    if (nameValue == null) {
        nameValue = "";
    }

    if (emailValue == null) {
        emailValue = "";
    }


    if (phoneValue == null) {
        phoneValue = "";
    }
%>

<!DOCTYPE html>

<html lang="en">

<head>

    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>
        Create Account | CineRent
    </title>

    <link rel="stylesheet"
          href="<%= request.getContextPath() %>/css/style.css">

</head>

<body>








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


            <a href="<%= request.getContextPath() %>/login"
               class="btn btn-secondary">

                Sign In

            </a>


        </div>


    </div>

</nav>





<!-- register page-->

<main class="auth-page">

    <div class="container auth-layout">

        <!-- intro-->

        <section class="auth-intro">

            <div class="auth-label">

                🍿 Join CineRent

            </div>

            <h1>

                Your next movie

                <span>
                    starts here.
                </span>

            </h1>

            <p>

                Create your CineRent account and start
                discovering, renting and reviewing
                movies from one simple platform.

            </p>



            <div class="auth-feature-list">


                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        🎥

                    </span>

                    Discover movies by rating and genre

                </div>


                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        📀

                    </span>

                    Rent and return movies online

                </div>

                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        🕘

                    </span>

                    Maintain your recently watched list

                </div>



                <div class="auth-feature">

                    <span class="auth-feature-icon">

                        ⭐

                    </span>

                    Share ratings after completing rentals

                </div>

            </div>

        </section>

        <!-- register card -->

        <section class="auth-card">

            <div class="auth-card-header">


                <h2>

                    Create Account

                </h2>

                <p>

                    Register as a CineRent customer
                    to get started.

                </p>


            </div>

            <!-- error -->

            <%
                if ( error != null && !error.trim().isEmpty()) {
            %>

            <div class="alert alert-danger">

                <%= HtmlUtil.escape(error) %>

            </div>


            <%
                }
            %>


            <!-- register form -->

            <form method="post"
                  action="<%= request.getContextPath() %>/register">


                <!-- name -->

                <div class="form-group">

                    <label for="name"
                           class="form-label">

                        Full Name

                    </label>


                    <div class="input-wrapper">

                        <span class="input-icon">

                            👤

                        </span>


                        <input type="text"
                               id="name"
                               name="name"
                               class="form-control with-icon"
                               value="<%= HtmlUtil.escape(nameValue) %>"
                               placeholder="Enter your full name"
                               autocomplete="name"
                               maxlength="100"
                               required>

                    </div>


                </div>


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
                               value="<%= HtmlUtil.escape(emailValue) %>"
                               placeholder="you@example.com"
                               autocomplete="email"
                               maxlength="150"
                               required>


                    </div>

                    <span class="form-help">

                        Your email is used to sign in
                        to your CineRent account.

                    </span>

                </div>


                <!-- phone -->

                <div class="form-group">

                    <label for="phone"
                           class="form-label">

                        Phone Number

                    </label>


                    <div class="input-wrapper">

                        <span class="input-icon">

                            ☎

                        </span>


                        <input type="tel"
                               id="phone"
                               name="phone"
                               class="form-control with-icon"
                               value="<%= HtmlUtil.escape(phoneValue) %>"
                               placeholder="07XXXXXXXX"
                               autocomplete="tel"
                               maxlength="20"
                               required>


                    </div>

                </div>

                <!-- password -->

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
                               placeholder="Create a password"
                               autocomplete="new-password"
                               minlength="6"
                               required>


                        <button type="button"
                                class="password-toggle"
                                onclick="togglePassword('password', this)">

                            SHOW

                        </button>

                    </div>

                    <span class="form-help">

                        Use at least 6 characters.

                    </span>

                </div>


                <!-- Confirm password -->

                <div class="form-group">

                    <label for="confirmPassword"
                           class="form-label">

                        Confirm Password

                    </label>


                    <div class="password-wrapper">

                        <input type="password"
                               id="confirmPassword"
                               class="form-control"
                               placeholder="Enter the password again"
                               autocomplete="new-password"
                               minlength="6"
                               required>

                        <button type="button"
                                class="password-toggle"
                                onclick="togglePassword('confirmPassword', this)">

                            SHOW

                        </button>

                    </div>


                    <span id="passwordError"
                          class="form-help text-danger"
                          style="display:none;">

                        Passwords do not match.

                    </span>


                </div>

                <!-- SUBMIT -->

                <button type="submit"
                        class="btn btn-primary auth-submit">

                    Create My Account →

                </button>

            </form>


            <div class="auth-divider">

                ALREADY REGISTERED?

            </div>

            <div class="auth-switch">

                Already have an account?

                <a href="<%= request.getContextPath() %>/login">

                    Sign in

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

        const input = document.getElementById(inputId);

        if (input.type === "password") {

            input.type = "text";

            button.textContent = "HIDE";

        } else {

            input.type = "password";

            button.textContent = "SHOW";
        }
    }


    const form = document.querySelector("form");


    form.addEventListener(
        "submit",
        function(event) {

            const password = document.getElementById("password").value;


            const confirmPassword = document.getElementById("confirmPassword").value;


            const error = document.getElementById("passwordError");


            if (password !== confirmPassword) {

                event.preventDefault();

                error.style.display = "block";

                return;
            }

            error.style.display = "none";
        }
    );

</script>


</body>

</html>