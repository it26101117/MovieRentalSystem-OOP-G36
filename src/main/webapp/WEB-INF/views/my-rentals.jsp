<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="java.lang.reflect.Method" %>
<%@ page import="java.time.LocalDate,java.time.LocalDateTime,java.time.format.DateTimeFormatter" %>
<%@ page import="com.movierental.model.Movie,com.movierental.model.Payment" %>
<%@ page import="com.movierental.util.HtmlUtil" %>
<%!
    // Supports common Rental getter names until Rental.java is available.
    private static Object read(Object obj, String... names) {
        if (obj == null) return null;
        for (String name : names) {
            try {
                Method m = obj.getClass().getMethod(name);
                if (m.getParameterCount() == 0) {
                    Object value = m.invoke(obj);
                    if (value != null) return value;
                }
            } catch (ReflectiveOperationException | SecurityException ignored) { }
        }
        return null;
    }
    private static String value(Object obj, String... names) {
        Object result = read(obj, names);
        return result == null ? "" : String.valueOf(result).trim();
    }
    private static String esc(String text) {
        return HtmlUtil.escape(text == null ? "" : text);
    }
    private static String date(Object obj) {
        if (obj == null) return "Not available";
        if (obj instanceof LocalDateTime)
            return ((LocalDateTime) obj).format(
                    DateTimeFormatter.ofPattern(
                            "dd MMM yyyy, hh:mm a", Locale.ENGLISH
                    )
            );
        if (obj instanceof LocalDate)
            return ((LocalDate) obj).format(
                    DateTimeFormatter.ofPattern(
                            "dd MMM yyyy", Locale.ENGLISH
                    )
            );
        String text = String.valueOf(obj).trim();
        return text.isEmpty() ? "Not available" : text.replace('T', ' ');
    }
    private static String status(Object rental) {
        String result = value(
                rental, "getStatus", "getRentalStatus"
        );
        if (!result.isEmpty())
            return result.toUpperCase(Locale.ROOT);
        Object returned = read(
                rental, "isReturned", "getReturned"
        );
        if (returned instanceof Boolean)
            return (Boolean) returned ? "RETURNED" : "ACTIVE";
        return "UNKNOWN";
    }
    private static boolean active(String s) {
        return "ACTIVE".equals(s)
                || "RENTED".equals(s)
                || "ONGOING".equals(s);
    }
    private static boolean returned(String s) {
        return "RETURNED".equals(s)
                || "COMPLETED".equals(s)
                || "CLOSED".equals(s);
    }
%>
<%
    String ctx = request.getContextPath();
    String userId = (String) session.getAttribute("userId");
    String role = (String) session.getAttribute("role");
    if (userId == null || role == null) {
        response.sendRedirect(ctx + "/login");
        return;
    }
    if (!"CUSTOMER".equalsIgnoreCase(role)) {
        response.sendRedirect(ctx + "/admin");
        return;
    }
    String userName =
            (String) session.getAttribute("userName");
    if (userName == null || userName.isBlank())
        userName = "Customer";
    // ==================================================
    // RENTAL RECORDS
    // ==================================================
    Object rawRentals = request.getAttribute("rentals");
    if (!(rawRentals instanceof List<?>))
        rawRentals = request.getAttribute("myRentals");
    List<Object> rentals = new ArrayList<>();
    if (rawRentals instanceof List<?>) {
        for (Object rental : (List<?>) rawRentals) {
            if (rental == null) continue;
            String owner = value(
                    rental, "getUserId", "getCustomerId"
            );
            if (owner.isEmpty() || owner.equals(userId))
                rentals.add(rental);
        }
    }
    // ==================================================
    // MOVIE RECORDS
    // ==================================================
    Map<String, Movie> moviesById = new HashMap<>();
    Object movieData =
            request.getAttribute("moviesById");
    if (movieData instanceof Map<?, ?>) {
        for (Object obj :
                ((Map<?, ?>) movieData).values()) {
            if (obj instanceof Movie) {
                Movie m = (Movie) obj;
                moviesById.put(m.getMovieId(), m);
            }
        }
    }
    Object rawMovies = request.getAttribute("movies");
    if (rawMovies instanceof List<?>) {
        for (Object obj : (List<?>) rawMovies) {
            if (obj instanceof Movie) {
                Movie m = (Movie) obj;
                moviesById.put(m.getMovieId(), m);
            }
        }
    }
    // ==================================================
    // PAYMENT RECORDS
    // ==================================================
    Object rawPayments =
            request.getAttribute("payments");
    if (!(rawPayments instanceof List<?>))
        rawPayments = request.getAttribute("myPayments");
    boolean paymentsLoaded =
            rawPayments instanceof List<?>;
    List<Payment> unlinkedPayments =
            new ArrayList<>();
    Map<String, Payment> paymentsByRental =
            new HashMap<>();
    int pendingCount = 0;
    if (rawPayments instanceof List<?>) {
        for (Object obj : (List<?>) rawPayments) {
            if (!(obj instanceof Payment))
                continue;
            Payment p = (Payment) obj;
            if (!userId.equals(p.getUserId()))
                continue;
            if (p.isPending())
                pendingCount++;
            if (p.hasRental()) {
                paymentsByRental.put(
                        p.getRentalId(), p
                );
            } else {
                unlinkedPayments.add(p);
            }
        }
    }
    // ==================================================
    // DASHBOARD STATISTICS
    // ==================================================
    int activeCount = 0;
    int returnedCount = 0;
    for (Object rental : rentals) {
        String s = status(rental);
        if (active(s))
            activeCount++;
        else if (returned(s))
            returnedCount++;
    }
    String csrf =
            (String) request.getAttribute("rentalCsrfToken");
    if (csrf == null) {
        Object token =
                session.getAttribute("rentalCsrfToken");
        csrf = token instanceof String
                ? (String) token : "";
    }
    String message =
            (String) request.getAttribute("message");
    String error =
            request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Rentals &amp; Payments | CineRent</title>
    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >
    <style>
        :root {
            color-scheme: dark;
            --bg: #070913;
            --panel: #12192a;
            --line: #283148;
            --muted: #94a3b8;
        }
        * {
            box-sizing: border-box;
        }
        body {
            margin: 0;
            background: var(--bg);
            color: #f8fafc;
            font-family: Inter, system-ui, Arial, sans-serif;
        }
        a {
            color: inherit;
            text-decoration: none;
        }
        .mr-nav {
            background: #090e1a;
            border-bottom: 1px solid var(--line);
            position: sticky;
            top: 0;
            z-index: 10;
        }
        .mr-nav-inner {
            max-width: 1300px;
            margin: auto;
            padding: 16px 22px;
            display: flex;
            gap: 24px;
            align-items: center;
            flex-wrap: wrap;
        }
        .mr-brand {
            font-size: 22px;
            font-weight: 900;
            color: #c4b5fd;
        }
        .mr-links {
            margin-left: auto;
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 20px;
            font-size: 13px;
        }
        .mr-links a {
            color: #cbd5e1;
        }
        .mr-links a:hover,
        .mr-links a.current {
            color: #c4b5fd;
        }
        .mr-wrap {
            max-width: 1300px;
            margin: auto;
            padding: 35px 22px 70px;
        }
        .mr-hero {
            border: 1px solid var(--line);
            border-radius: 20px;
            padding: 30px;
            display: flex;
            gap: 22px;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(
                    120deg,
                    #1c1740,
                    #10192c 75%
            );
        }
        .mr-hero h1 {
            font-size: clamp(29px, 4vw, 44px);
            margin: 8px 0;
        }
        .mr-hero h1 span {
            color: #a78bfa;
        }
        .mr-hero p,
        .mr-sub {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.6;
        }
        .mr-tag {
            color: #c4b5fd;
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        .mr-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border-radius: 9px;
            padding: 11px 15px;
            border: 1px solid #39445b;
            background: #202b41;
            color: white;
            font-size: 12px;
            font-weight: 750;
            font-family: inherit;
            cursor: pointer;
            white-space: nowrap;
        }
        .mr-btn:hover {
            filter: brightness(1.15);
        }
        .mr-primary {
            background: #7c3aed;
            border-color: #7c3aed;
        }
        .mr-danger {
            background: #381e2d;
            color: #fecaca;
            border-color: #783344;
        }
        .mr-stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 14px;
            margin: 22px 0 34px;
        }
        .mr-stat {
            padding: 20px;
            border: 1px solid var(--line);
            background: var(--panel);
            border-radius: 15px;
        }
        .mr-stat small {
            color: var(--muted);
            font-size: 12px;
        }
        .mr-stat strong {
            display: block;
            font-size: 29px;
            margin-top: 7px;
        }
        .mr-section {
            margin-top: 34px;
        }
        .mr-section h2 {
            margin: 0 0 5px;
            font-size: 23px;
        }
        .mr-toolbar {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin: 18px 0;
        }
        .mr-toolbar input,
        .mr-toolbar select {
            border: 1px solid #37425a;
            background: #111a2c;
            color: white;
            padding: 12px;
            border-radius: 9px;
            font: inherit;
            font-size: 13px;
        }
        .mr-toolbar input {
            flex: 1;
            min-width: 220px;
        }
        .mr-toolbar select {
            min-width: 150px;
        }
        .mr-count {
            color: var(--muted);
            font-size: 12px;
            align-self: center;
        }
        .mr-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .mr-card {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 15px;
            overflow: hidden;
            display: grid;
            grid-template-columns: 132px minmax(0, 1fr);
        }
        .mr-poster {
            width: 132px;
            height: 100%;
            min-height: 240px;
            object-fit: cover;
            background: #202c40;
        }
        .mr-card-content {
            padding: 18px;
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 12px;
        }
        .mr-card-head {
            display: flex;
            gap: 10px;
            justify-content: space-between;
            align-items: flex-start;
        }
        .mr-card h3 {
            margin: 0 0 5px;
            font-size: 18px;
            overflow-wrap: anywhere;
        }
        .mr-meta {
            color: var(--muted);
            font-size: 11px;
            line-height: 1.6;
        }
        .mr-badge {
            display: inline-block;
            padding: 5px 9px;
            border-radius: 99px;
            font-size: 10px;
            font-weight: 800;
            border: 1px solid #465169;
            color: #cbd5e1;
            white-space: nowrap;
        }
        .mr-badge.active,
        .mr-badge.paid {
            color: #86efac;
            border-color: #166534;
            background: #102c25;
        }
        .mr-badge.returned {
            color: #93c5fd;
            border-color: #1e40af;
            background: #152445;
        }
        .mr-badge.pending {
            color: #fde68a;
            border-color: #92400e;
            background: #3a2816;
        }
        .mr-badge.failed,
        .mr-badge.rejected {
            color: #fca5a5;
            border-color: #991b1b;
            background: #391b25;
        }
        .mr-details {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 12px;
            border-top: 1px solid var(--line);
            border-bottom: 1px solid var(--line);
            padding: 13px 0;
        }
        .mr-details small {
            display: block;
            color: #94a3b8;
            font-size: 10px;
            margin-bottom: 5px;
        }
        .mr-details strong {
            display: block;
            font-size: 12px;
            font-weight: 650;
            overflow-wrap: anywhere;
        }
        .mr-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: auto;
        }
        .mr-actions form {
            margin: 0;
        }
        .mr-empty {
            text-align: center;
            padding: 45px 20px;
            background: #11192a;
            border: 1px dashed #3b465e;
            border-radius: 15px;
        }
        .mr-empty h3 {
            margin: 0 0 7px;
        }
        .mr-empty p {
            color: var(--muted);
            font-size: 13px;
        }
        .mr-payment-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 15px;
        }
        .mr-payment {
            background: var(--panel);
            border: 1px solid var(--line);
            border-radius: 15px;
            padding: 20px;
        }
        .mr-payment-top,
        .mr-payment-bottom {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .mr-payment h3 {
            margin: 12px 0 5px;
        }
        .mr-payment p {
            color: var(--muted);
            font-size: 12px;
        }
        .mr-payment-bottom {
            padding-top: 14px;
            border-top: 1px solid var(--line);
        }
        .mr-alert {
            padding: 14px;
            border: 1px solid #2e4770;
            background: #15233a;
            color: #bfdbfe;
            border-radius: 10px;
            margin: 18px 0;
            font-size: 13px;
        }
        .mr-alert.error {
            border-color: #7f1d1d;
            background: #351923;
            color: #fecaca;
        }
        @media (max-width: 900px) {
            .mr-grid {
                grid-template-columns: 1fr;
            }
        }
        @media (max-width: 680px) {
            .mr-links {
                margin-left: 0;
                width: 100%;
            }
            .mr-hero {
                align-items: flex-start;
                flex-direction: column;
            }
            .mr-stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
            .mr-payment-grid {
                grid-template-columns: 1fr;
            }
        }
        @media (max-width: 430px) {
            .mr-card {
                grid-template-columns: 95px minmax(0, 1fr);
            }
            .mr-poster {
                width: 95px;
            }
            .mr-card-content {
                padding: 12px;
            }
            .mr-card h3 {
                font-size: 15px;
            }
            .mr-details {
                grid-template-columns: 1fr;
            }
            .mr-btn {
                padding: 9px;
                font-size: 11px;
            }
        }
    </style>
</head>
<body>
<!-- NAVIGATION -->
<header class="mr-nav">
    <nav class="mr-nav-inner" aria-label="Customer navigation">
        <a href="<%= ctx %>/" class="mr-brand">
            🎬 CineRent
        </a>
        <div class="mr-links">
            <a href="<%= ctx %>/">Home</a>
            <a href="<%= ctx %>/catalog">
                Movies
            </a>
            <a
                    href="<%= ctx %>/rentals"
                    class="current"
                    aria-current="page"
            >
                My Rentals
            </a>
            <a href="<%= ctx %>/recently-watched">
                Recently Watched
            </a>
            <a href="<%= ctx %>/logout">
                Logout
            </a>
        </div>
    </nav>
</header>
<main class="mr-wrap">
    <!-- HEADER -->
    <section class="mr-hero">
        <div>
            <div class="mr-tag">
                Customer Dashboard
            </div>
            <h1>
                My <span>Rentals &amp; Payments</span>
            </h1>
            <p>
                Welcome, <%= esc(userName) %>.
                Manage your rentals, returns and payment activity.
            </p>
        </div>
        <a
                class="mr-btn mr-primary"
                href="<%= ctx %>/catalog"
        >
            + Browse Movies
        </a>
    </section>
    <!-- MESSAGES -->
    <% if (message != null && !message.isBlank()) { %>
    <div class="mr-alert" role="status">
        <%= esc(message) %>
    </div>
    <% } %>
    <% if (error != null && !error.isBlank()) { %>
    <div class="mr-alert error" role="alert">
        Your request could not be completed.
        Please try again.
    </div>
    <% } %>
    <!-- STATISTICS -->
    <section class="mr-stats" aria-label="Rental statistics">
        <div class="mr-stat">
            <small>Total Rentals</small>
            <strong><%= rentals.size() %></strong>
        </div>
        <div class="mr-stat">
            <small>Active Rentals</small>
            <strong style="color:#86efac">
                <%= activeCount %>
            </strong>
        </div>
        <div class="mr-stat">
            <small>Returned Movies</small>
            <strong><%= returnedCount %></strong>
        </div>
        <div class="mr-stat">
            <small>Pending Payments</small>
            <strong style="color:#fde68a">
                <%= pendingCount %>
            </strong>
        </div>
    </section>
    <!-- RENTALS -->
    <section class="mr-section">
        <h2>My Movie Rentals</h2>
        <p class="mr-sub">
            View your rental history and return active movies.
        </p>
        <!-- SEARCH -->
        <div class="mr-toolbar">
            <input
                    id="rentalSearch"
                    type="search"
                    placeholder="Search movie title or rental ID"
                    aria-label="Search rentals"
            >
            <select
                    id="rentalFilter"
                    aria-label="Filter by rental status"
            >
                <option value="ALL">All Rentals</option>
                <option value="ACTIVE">Active</option>
                <option value="RETURNED">Returned</option>
                <option value="OTHER">Other</option>
            </select>
            <span class="mr-count">
                Showing
                <strong id="visibleCount">
                    <%= rentals.size() %>
                </strong>
                rental(s)
            </span>
        </div>
        <% if (rentals.isEmpty()) { %>
        <div class="mr-empty">
            <h3>No rentals yet</h3>
            <p>
                Browse the catalogue and complete
                checkout to rent a movie.
            </p>
            <a
                    href="<%= ctx %>/catalog"
                    class="mr-btn mr-primary"
            >
                Explore Movies
            </a>
        </div>
        <% } else { %>
        <div class="mr-grid" id="rentalGrid">
            <%
                for (Object rental : rentals) {
                    String rentalId = value(
                            rental, "getRentalId", "getId"
                    );
                    String movieId = value(
                            rental, "getMovieId"
                    );
                    String rentalStatus = status(rental);
                    boolean isActive =
                            active(rentalStatus);
                    boolean isReturned =
                            returned(rentalStatus);
                    String filter = isActive
                            ? "ACTIVE"
                            : isReturned ? "RETURNED" : "OTHER";
                    String badge = isActive
                            ? "active"
                            : isReturned ? "returned" : "";
                    Movie movie =
                            moviesById.get(movieId);
                    String title = movie == null
                            ? "Movie " + movieId
                            : movie.getTitle();
                    String genre = movie == null
                            ? ""
                            : movie.getGenre();
                    Object rentedOn = read(
                            rental,
                            "getRentalDate",
                            "getRentedAt",
                            "getStartDate",
                            "getCreatedAt"
                    );
                    Object dueOn = read(
                            rental,
                            "getDueDate",
                            "getExpectedReturnDate",
                            "getReturnDate"
                    );
                    Object returnedOn = read(
                            rental,
                            "getActualReturnDate",
                            "getReturnedAt",
                            "getReturnDate"
                    );
                    Payment payment =
                            paymentsByRental.get(rentalId);
            %>
            <article
                    class="mr-card"
                    data-rental
                    data-status="<%= filter %>"
                    data-search="<%= esc(title + " " + movieId + " " + rentalId) %>"
            >
                <!-- POSTER -->
                <img
                        class="mr-poster"
                        loading="lazy"
                        alt="Poster for <%= esc(title) %>"
                        src="<%= ctx %>/movie-image?id=<%= esc(movieId) %>"
                        onerror="this.onerror=null;this.src='<%= ctx %>/images/posters/default.svg';"
                >
                <div class="mr-card-content">
                    <div class="mr-card-head">
                        <div>
                            <h3><%= esc(title) %></h3>
                            <div class="mr-meta">
                                <%= esc(genre) %>
                                · Rental #<%= esc(rentalId) %>
                            </div>
                        </div>
                        <span class="mr-badge <%= badge %>">
                                <%= esc(rentalStatus) %>
                            </span>
                    </div>
                    <!-- RENTAL DETAILS -->
                    <div class="mr-details">
                        <div>
                            <small>Rented On</small>
                            <strong>
                                <%= esc(date(rentedOn)) %>
                            </strong>
                        </div>
                        <div>
                            <small>
                                <%= isReturned
                                        ? "Returned On"
                                        : "Due Date" %>
                            </small>
                            <strong>
                                <%= esc(date(
                                        isReturned
                                                ? returnedOn
                                                : dueOn
                                )) %>
                            </strong>
                        </div>
                        <div>
                            <small>Movie ID</small>
                            <strong>
                                <%= esc(movieId) %>
                            </strong>
                        </div>
                        <div>
                            <small>Payment</small>
                            <% if (payment != null) { %>
                            <span class="mr-badge <%= payment.isPaid()
                                        ? "paid"
                                        : payment.isPending()
                                            ? "pending"
                                            : "" %>">
                                        <%= esc(
                                                payment.getPaymentStatus()
                                        ) %>
                                    </span>
                            <% } else { %>
                            <strong>
                                Not linked / legacy rental
                            </strong>
                            <% } %>
                        </div>
                    </div>
                    <!-- ACTIONS -->
                    <div class="mr-actions">
                        <a
                                class="mr-btn"
                                href="<%= ctx %>/reviews?movieId=<%= esc(movieId) %>"
                        >
                            ★ Reviews
                        </a>
                        <% if (payment != null) { %>
                        <a
                                class="mr-btn"
                                href="<%= ctx %>/payments?paymentId=<%= esc(payment.getPaymentId()) %>"
                        >
                            Payment Details
                        </a>
                        <% } %>
                        <% if (isActive && !rentalId.isEmpty()) { %>
                        <form
                                method="post"
                                action="<%= ctx %>/rentals"
                                onsubmit="return confirm('Return this movie?');"
                        >
                            <input
                                    type="hidden"
                                    name="action"
                                    value="return"
                            >
                            <input
                                    type="hidden"
                                    name="rentalId"
                                    value="<%= esc(rentalId) %>"
                            >
                            <input
                                    type="hidden"
                                    name="csrfToken"
                                    value="<%= esc(csrf) %>"
                            >
                            <button
                                    class="mr-btn mr-danger"
                                    type="submit"
                            >
                                Return Movie
                            </button>
                        </form>
                        <% } %>
                    </div>
                </div>
            </article>
            <% } %>
        </div>
        <div
                class="mr-empty"
                id="noMatches"
                style="display:none;margin-top:16px"
        >
            <h3>No matching rentals</h3>
            <p>
                Try a different search or status filter.
            </p>
        </div>
        <% } %>
    </section>
    <!-- PAYMENTS -->
    <section class="mr-section">
        <h2>Checkout &amp; Payment Activity</h2>
        <p class="mr-sub">
            Pending, rejected or paid payments not yet
            linked to a rental.
        </p>
        <% if (!paymentsLoaded) { %>
        <div class="mr-alert">
            Payment information has not been loaded
            by RentalServlet yet.
        </div>
        <% } else if (unlinkedPayments.isEmpty()) { %>
        <div class="mr-empty">
            <h3>No outstanding payments</h3>
            <p>
                Payments awaiting approval or rental
                activation will appear here.
            </p>
        </div>
        <% } else { %>
        <div class="mr-payment-grid">
            <%
                for (Payment p : unlinkedPayments) {
                    Movie m =
                            moviesById.get(p.getMovieId());
                    String title = m == null
                            ? "Movie " + p.getMovieId()
                            : m.getTitle();
                    String badge = p.isPaid()
                            ? "paid"
                            : p.isPending()
                            ? "pending"
                            : p.isRejected()
                            ? "rejected"
                            : p.isFailed()
                            ? "failed"
                            : "";
            %>
            <article class="mr-payment">
                <div class="mr-payment-top">
                        < span class="mr-meta">
                            Payment #<%= esc(p.getPaymentId()) %>
                        </span>
                    <span class="mr-badge <%= badge %>">
                            <%= esc(p.getPaymentStatus()) %>
                        </span>
                </div>
                <h3><%= esc(title) %></h3>
                <p>
                    <%= esc(
                            p.getPaymentMethodDisplay()
                    ) %>
                    ·
                    <%= esc(
                            p.getFormattedCreatedAt()
                    ) %>
                </p>
                <% if (p.isPending()) { %>
                <p>
                    Waiting for admin verification.
                    Rental is not active.
                </p>
                <% } else if (p.isPaid()) { %>
                <p>
                    Payment approved.
                    Rental activation is awaiting
                    backend processing.
                </p>
                <% } %>
                <div class="mr-payment-bottom">
                    <strong>
                        LKR <%= esc(
                            p.getFormattedAmount()
                    ) %>
                    </strong>
                    <a
                            class="mr-btn"
                            href="<%= ctx %>/payments?paymentId=<%= esc(p.getPaymentId()) %>"
                    >
                        View Payment
                    </a>
                </div>
            </article>
            <% } %>
        </div>
        <% } %>
    </section>
</main>
<!-- SEARCH AND FILTER -->
<script>
    (function () {
        const search =
            document.getElementById('rentalSearch');
        const filter =
            document.getElementById('rentalFilter');
        const cards = Array.from(
            document.querySelectorAll('[data-rental]')
        );
        const count =
            document.getElementById('visibleCount');
        const empty =
            document.getElementById('noMatches');
        if (!search || !filter) return;
        function update() {
            const query =
                search.value.trim().toLowerCase();
            let visible = 0;
            cards.forEach(function (card) {
                const matchText =
                    (card.dataset.search || '')
                        .toLowerCase()
                        .includes(query);
                const matchStatus =
                    filter.value === 'ALL'
                    || card.dataset.status === filter.value;
                const show = matchText && matchStatus;
                card.style.display =
                    show ? '' : 'none';
                if (show) visible++;
            });
            if (count)
                count.textContent = String(visible);
            if (empty)
                empty.style.display =
                    cards.length && !visible
                        ? 'block'
                        : 'none';
        }
        search.addEventListener('input', update);
        filter.addEventListener('change', update);
    })();
</script>
</body>
</html>
