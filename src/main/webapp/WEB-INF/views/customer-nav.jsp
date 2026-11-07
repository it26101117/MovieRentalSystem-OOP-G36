<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.movierental.util.HtmlUtil" %>
<%
    String navCtx = request.getContextPath();
    Object navUserName = session.getAttribute("userName");
    String navDisplayName = navUserName == null ? "Customer" : navUserName.toString();
    String navPath = request.getRequestURI();
    String navSafeCtx = HtmlUtil.escape(navCtx);
%>
<style>
    .cr-customer-nav, .cr-customer-nav * { box-sizing: border-box; }
    .cr-customer-nav {
        background: #080c16;
        border-bottom: 1px solid #253049;
        color: #f4f6fc;
        font-family: Inter, system-ui, -apple-system, "Segoe UI", Arial, sans-serif;
    }
    .cr-customer-nav__inner {
        max-width: 1420px;
        margin: 0 auto;
        padding: 12px 24px;
        min-height: 70px;
        display: flex;
        align-items: center;
        gap: 28px;
        flex-wrap: wrap;
    }
    .cr-customer-nav__brand {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        color: #fff;
        font-size: 20px;
        font-weight: 800;
        text-decoration: none;
        white-space: nowrap;
    }
    .cr-customer-nav__logo {
        display: inline-grid;
        place-items: center;
        width: 38px;
        height: 38px;
        border-radius: 11px;
        background: linear-gradient(135deg, #6d28d9, #8b5cf6);
        color: #fff;
    }
    .cr-customer-nav__links {
        display: flex;
        align-items: center;
        gap: 20px;
        flex: 1;
        flex-wrap: wrap;
    }
    .cr-customer-nav__links a {
        color: #aebbd0;
        text-decoration: none;
        font-size: 13px;
        font-weight: 650;
        padding: 10px 0;
    }
    .cr-customer-nav__links a:hover,
    .cr-customer-nav__links a[aria-current="page"] { color: #d8c4ff; }
    .cr-customer-nav__account {
        display: flex;
        align-items: center;
        gap: 12px;
        font-size: 12px;
        margin-left: auto;
    }
    .cr-customer-nav__avatar {
        display: inline-grid;
        place-items: center;
        width: 34px;
        height: 34px;
        border-radius: 50%;
        background: #5b4ae8;
        font-weight: 800;
    }
    .cr-customer-nav__logout {
        color: #f2f4fa;
        border: 1px solid #344055;
        border-radius: 7px;
        padding: 8px 11px;
        text-decoration: none;
        font-size: 12px;
    }
    .cr-customer-nav__logout:hover { background: #202940; }
    @media (max-width: 760px) {
        .cr-customer-nav__inner { gap: 12px; padding: 12px 16px; }
        .cr-customer-nav__links { order: 3; width: 100%; flex-basis: 100%; gap: 16px; }
        .cr-customer-nav__account { margin-left: auto; }
        .cr-customer-nav__account-name { display: none; }
    }
</style>
<nav class="cr-customer-nav" aria-label="Customer navigation">
    <div class="cr-customer-nav__inner">
        <a class="cr-customer-nav__brand" href="<%= navSafeCtx %>/">
            <span class="cr-customer-nav__logo">C</span>
            <span>CineRent</span>
        </a>
        <div class="cr-customer-nav__links">
            <a href="<%= navSafeCtx %>/">Home</a>
            <a href="<%= navSafeCtx %>/catalog" <%= navPath.endsWith("/catalog") ? "aria-current=\"page\"" : "" %>>Movies</a>
            <a href="<%= navSafeCtx %>/rentals" <%= navPath.endsWith("/rentals") ? "aria-current=\"page\"" : "" %>>My Rentals</a>
            <a href="<%= navSafeCtx %>/payments" <%= navPath.endsWith("/payments") ? "aria-current=\"page\"" : "" %>>My Payments</a>
            <a href="<%= navSafeCtx %>/recently-watched">Recently Watched</a>
        </div>
        <div class="cr-customer-nav__account">
            <span class="cr-customer-nav__avatar" aria-hidden="true">C</span>
            <span class="cr-customer-nav__account-name">Hi, <%= HtmlUtil.escape(navDisplayName) %></span>
            <a class="cr-customer-nav__logout" href="<%= navSafeCtx %>/logout">Logout</a>
        </div>
    </div>
</nav>
