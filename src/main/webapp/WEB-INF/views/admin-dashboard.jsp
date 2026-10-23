
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%!
    private int dashboardNumber(Object value) {
        if (value instanceof Number) {
            return ((Number) value).intValue();
        }

        if (value != null) {
            try {
                return Integer.parseInt(value.toString().trim());
            } catch (NumberFormatException ignored) {
                return 0;
            }
        }

        return 0;
    }
%>

<%
    String ctx = request.getContextPath();

    String adminName = (String) session.getAttribute("userName");

    if (adminName == null || adminName.trim().isEmpty()) {
        adminName = "Administrator";
    }

    int movieCount =
            dashboardNumber(request.getAttribute("movieCount"));

    int customerCount =
            dashboardNumber(request.getAttribute("customerCount"));

    int activeRentalCount =
            dashboardNumber(request.getAttribute("activeRentalCount"));

    int returnedRentalCount =
            dashboardNumber(request.getAttribute("returnedRentalCount"));

    int totalRentalCount =
            dashboardNumber(request.getAttribute("totalRentalCount"));

    int reviewCount =
            dashboardNumber(request.getAttribute("reviewCount"));

    int availableCopies =
            dashboardNumber(request.getAttribute("availableCopies"));

    if (totalRentalCount <= 0) {
        totalRentalCount = activeRentalCount + returnedRentalCount;
    }

    int activePercent = totalRentalCount > 0
            ? Math.min(100,
            (int) Math.round(activeRentalCount * 100.0 / totalRentalCount))
            : 0;

    int returnedPercent = totalRentalCount > 0
            ? Math.min(100,
            (int) Math.round(returnedRentalCount * 100.0 / totalRentalCount))
            : 0;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Admin Dashboard | CineRent</title>

    <link rel="stylesheet"
          href="<%= ctx %>/css/style.css">

    <style>
        :root {
            --dash-bg: #080b14;
            --dash-surface: #101624;
            --dash-card: #151e2e;
            --dash-border: rgba(148, 163, 184, 0.14);
            --dash-text: #f4f7ff;
            --dash-muted: #8e9bb2;
            --dash-purple: #8755ff;
            --dash-blue: #59a1ff;
            --dash-green: #42dfa0;
            --dash-yellow: #ffc857;
        }

        * {
            box-sizing: border-box;
        }

        body.admin-dashboard-page {
            margin: 0;
            min-height: 100vh;
            color: var(--dash-text);
            background:
                    radial-gradient(
                            ellipse at 8% 0%,
                            rgba(102, 62, 220, 0.12),
                            transparent 35%
                    ),
                    radial-gradient(
                            ellipse at 95% 15%,
                            rgba(40, 120, 220, 0.09),
                            transparent 32%
                    ),
                    var(--dash-bg);
            font-family:
                    Inter,
                    -apple-system,
                    BlinkMacSystemFont,
                    "Segoe UI",
                    sans-serif;
        }

        .dashboard-main {
            width: min(1500px, 100%);
            margin: 0 auto;
            padding: 34px 30px 56px;
        }

        .dashboard-main a {
            text-decoration: none;
        }

        /* Welcome banner */

        .dashboard-hero {
            position: relative;
            isolation: isolate;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 28px;
            min-height: 220px;
            padding: 38px 40px;
            margin-bottom: 36px;
            overflow: hidden;
            border: 1px solid rgba(157, 126, 255, 0.19);
            border-radius: 25px;
            background:
                    radial-gradient(
                            circle at 88% 10%,
                            rgba(133, 85, 255, 0.24),
                            transparent 32%
                    ),
                    linear-gradient(
                            120deg,
                            #111827 0%,
                            #11172a 54%,
                            #1b193b 100%
                    );
            box-shadow: 0 24px 65px rgba(0, 0, 0, 0.20);
        }

        .dashboard-hero::before {
            content: "";
            position: absolute;
            z-index: -1;
            width: 270px;
            height: 270px;
            right: 9%;
            top: -175px;
            border: 1px solid rgba(178, 153, 255, 0.22);
            border-radius: 50%;
            box-shadow:
                    0 0 0 35px rgba(153, 119, 255, 0.035),
                    0 0 0 70px rgba(153, 119, 255, 0.025);
        }

        .hero-copy {
            max-width: 760px;
        }

        .hero-eyebrow {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 8px 12px;
            margin-bottom: 18px;
            border: 1px solid rgba(155, 117, 255, 0.30);
            border-radius: 999px;
            color: #c6b3ff;
            background: rgba(118, 75, 235, 0.12);
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 1.1px;
            text-transform: uppercase;
        }

        .eyebrow-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--dash-purple);
            box-shadow: 0 0 12px rgba(135, 85, 255, 0.8);
        }

        .hero-title {
            margin: 0;
            font-size: clamp(29px, 3.2vw, 43px);
            font-weight: 800;
            line-height: 1.15;
            letter-spacing: -1.5px;
        }

        .hero-title span {
            color: #a98aff;
        }

        .hero-description {
            max-width: 650px;
            margin: 15px 0 0;
            color: #a6b4cc;
            font-size: 14px;
            line-height: 1.9;
        }

        .hero-status {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            align-items: flex-end;
            gap: 15px;
            flex-shrink: 0;
        }

        .system-status {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            padding: 13px 16px;
            border: 1px solid rgba(66, 223, 160, 0.20);
            border-radius: 13px;
            background: rgba(27, 154, 106, 0.10);
            color: #6cf0b7;
            font-size: 12px;
            font-weight: 750;
        }

        .system-status span {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: var(--dash-green);
            box-shadow: 0 0 12px rgba(66, 223, 160, 0.6);
        }

        .hero-summary {
            text-align: right;
            color: var(--dash-muted);
            font-size: 12px;
            line-height: 1.8;
        }

        .hero-summary strong {
            display: block;
            color: #f2f5ff;
            font-size: 17px;
        }

        /* Section headings */

        .dashboard-section {
            margin-top: 36px;
        }

        .section-heading {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 18px;
            margin-bottom: 19px;
        }

        .section-title {
            margin: 0;
            color: var(--dash-text);
            font-size: 21px;
            font-weight: 800;
            letter-spacing: -0.5px;
        }

        .section-description {
            margin: 7px 0 0;
            color: var(--dash-muted);
            font-size: 12px;
            line-height: 1.7;
        }

        .section-kicker {
            color: #8794ad;
            font-size: 10px;
            font-weight: 800;
            letter-spacing: 1.3px;
            text-transform: uppercase;
        }

        /* Statistic cards */

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(6, minmax(0, 1fr));
            gap: 15px;
        }

        .stat-card {
            position: relative;
            min-width: 0;
            padding: 21px 19px 19px;
            overflow: hidden;
            border: 1px solid var(--dash-border);
            border-radius: 19px;
            background:
                    linear-gradient(
                            145deg,
                            rgba(26, 36, 54, 0.97),
                            rgba(17, 24, 38, 0.98)
                    );
            transition:
                    transform 180ms ease,
                    border-color 180ms ease,
                    box-shadow 180ms ease;
        }

        .stat-card:hover {
            transform: translateY(-4px);
            border-color: rgba(150, 124, 255, 0.36);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.20);
        }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 8px;
            margin-bottom: 20px;
        }

        .stat-icon {
            display: grid;
            place-items: center;
            width: 43px;
            height: 43px;
            flex-shrink: 0;
            border-radius: 13px;
        }

        .stat-icon svg {
            width: 21px;
            height: 21px;
            stroke: currentColor;
            stroke-width: 1.8;
            stroke-linecap: round;
            stroke-linejoin: round;
            fill: none;
        }

        .purple {
            color: #b8a1ff;
            background: rgba(135, 85, 255, 0.16);
        }

        .blue {
            color: #76b7ff;
            background: rgba(76, 151, 255, 0.14);
        }

        .yellow {
            color: #ffd16e;
            background: rgba(255, 190, 60, 0.13);
        }

        .green {
            color: #63e9b0;
            background: rgba(66, 223, 160, 0.13);
        }

        .pink {
            color: #ff9bc2;
            background: rgba(255, 100, 165, 0.13);
        }

        .stat-tag {
            color: #8492aa;
            font-size: 10px;
            font-weight: 750;
            letter-spacing: 0.5px;
            text-transform: uppercase;
        }

        .stat-value {
            display: block;
            overflow-wrap: anywhere;
            color: #f6f8ff;
            font-size: clamp(25px, 2.2vw, 33px);
            font-weight: 850;
            line-height: 1.2;
            letter-spacing: -1px;
            font-variant-numeric: tabular-nums;
        }

        .stat-value.compact {
            font-size: clamp(21px, 1.9vw, 28px);
        }

        .stat-label {
            margin-top: 9px;
            color: #a1aec4;
            font-size: 12px;
            font-weight: 650;
            line-height: 1.5;
        }

        .stat-note {
            margin-top: 15px;
            padding-top: 12px;
            border-top: 1px solid rgba(148, 163, 184, 0.10);
            color: #78869f;
            font-size: 10px;
        }

        /* Management modules */

        .modules-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 17px;
        }

        .module-card {
            display: flex;
            flex-direction: column;
            min-width: 0;
            min-height: 265px;
            padding: 23px;
            border: 1px solid var(--dash-border);
            border-radius: 20px;
            color: inherit;
            background: var(--dash-card);
            transition:
                    transform 180ms ease,
                    border-color 180ms ease,
                    background 180ms ease;
        }

        .module-card:hover {
            transform: translateY(-5px);
            border-color: rgba(135, 85, 255, 0.45);
            background: #192337;
        }

        .module-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 22px;
        }

        .module-icon {
            display: grid;
            place-items: center;
            width: 49px;
            height: 49px;
            border-radius: 15px;
        }

        .module-icon svg {
            width: 23px;
            height: 23px;
            stroke: currentColor;
            stroke-width: 1.8;
            stroke-linecap: round;
            stroke-linejoin: round;
            fill: none;
        }

        .module-badge {
            padding: 6px 9px;
            border: 1px solid rgba(66, 223, 160, 0.18);
            border-radius: 999px;
            color: #6beab3;
            background: rgba(66, 223, 160, 0.08);
            font-size: 9px;
            font-weight: 800;
            letter-spacing: 0.7px;
        }

        .module-title {
            margin: 0;
            color: #f1f4ff;
            font-size: 16px;
            font-weight: 800;
            letter-spacing: -0.3px;
        }

        .module-description {
            flex: 1;
            margin: 11px 0 22px;
            color: #99a8c0;
            font-size: 12px;
            line-height: 1.85;
        }

        .module-action {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            padding: 12px 14px;
            border: 1px solid rgba(150, 125, 255, 0.18);
            border-radius: 11px;
            color: #d8ceff;
            background: rgba(135, 85, 255, 0.11);
            font-size: 11px;
            font-weight: 800;
            transition: background 180ms ease;
        }

        .module-card:hover .module-action {
            background: rgba(135, 85, 255, 0.20);
        }

        .module-action span:last-child {
            font-size: 17px;
            transition: transform 180ms ease;
        }

        .module-card:hover .module-action span:last-child {
            transform: translateX(3px);
        }

        /* Lower dashboard panels */

        .bottom-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.1fr) minmax(0, 0.9fr);
            gap: 18px;
        }

        .dashboard-panel {
            min-width: 0;
            padding: 25px;
            border: 1px solid var(--dash-border);
            border-radius: 20px;
            background: rgba(20, 29, 44, 0.92);
        }

        .panel-heading {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 24px;
        }

        .panel-heading h3 {
            margin: 0;
            color: #f0f3ff;
            font-size: 15px;
            font-weight: 800;
        }

        .panel-heading span {
            color: #8391a9;
            font-size: 10px;
        }

        .rental-summary {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .rental-stat {
            padding: 16px;
            border: 1px solid rgba(148, 163, 184, 0.11);
            border-radius: 14px;
            background: rgba(7, 12, 22, 0.28);
        }

        .rental-stat-label {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #a2aec3;
            font-size: 11px;
        }

        .rental-stat-label i {
            display: inline-block;
            width: 7px;
            height: 7px;
            border-radius: 50%;
        }

        .rental-stat strong {
            display: block;
            margin-top: 12px;
            color: #f4f7ff;
            font-size: 28px;
            font-weight: 850;
            font-variant-numeric: tabular-nums;
        }

        .rental-stat small {
            display: block;
            margin-top: 5px;
            color: #8290a8;
            font-size: 10px;
        }

        .rental-progress {
            display: flex;
            height: 9px;
            gap: 4px;
            margin-top: 23px;
            overflow: hidden;
            border-radius: 999px;
            background: #242d3d;
        }

        .progress-active {
            min-width: 0;
            border-radius: 999px;
            background: linear-gradient(90deg, #8755ff, #b18aff);
        }

        .progress-returned {
            min-width: 0;
            border-radius: 999px;
            background: linear-gradient(90deg, #20b985, #58e5ad);
        }

        .progress-legend {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            margin-top: 13px;
            color: #96a3b8;
            font-size: 10px;
        }

        .legend-item {
            display: inline-flex;
            align-items: center;
            gap: 7px;
        }

        .legend-item i {
            width: 7px;
            height: 7px;
            border-radius: 50%;
        }

        .quick-links {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }

        .quick-link {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            min-width: 0;
            padding: 15px;
            border: 1px solid rgba(148, 163, 184, 0.12);
            border-radius: 13px;
            color: #d8e0f1;
            background: rgba(7, 12, 22, 0.25);
            font-size: 11px;
            font-weight: 700;
            transition:
                    border-color 180ms ease,
                    background 180ms ease;
        }

        .quick-link:hover {
            border-color: rgba(135, 85, 255, 0.4);
            background: rgba(135, 85, 255, 0.08);
        }

        .quick-link span:last-child {
            color: #aa91ff;
            font-size: 16px;
        }

        .dashboard-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin-top: 35px;
            padding-top: 20px;
            border-top: 1px solid rgba(148, 163, 184, 0.10);
            color: #77849b;
            font-size: 10px;
        }

        .footer-brand {
            color: #b9a5ff;
            font-weight: 850;
        }

        /* Responsive layout */

        @media (max-width: 1200px) {
            .stats-grid {
                grid-template-columns: repeat(3, minmax(0, 1fr));
            }

            .modules-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .dashboard-main {
                padding: 23px 17px 38px;
            }

            .dashboard-hero {
                align-items: flex-start;
                flex-direction: column;
                min-height: auto;
                padding: 27px 24px;
            }

            .hero-status {
                align-items: flex-start;
                width: 100%;
            }

            .hero-summary {
                text-align: left;
            }

            .hero-title {
                letter-spacing: -0.8px;
            }

            .stats-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
                gap: 11px;
            }

            .stat-card {
                padding: 17px 15px;
            }

            .stat-top {
                margin-bottom: 16px;
            }

            .stat-icon {
                width: 38px;
                height: 38px;
            }

            .modules-grid {
                grid-template-columns: 1fr;
            }

            .module-card {
                min-height: 0;
            }

            .bottom-grid {
                grid-template-columns: 1fr;
            }

            .section-heading {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (max-width: 420px) {
            .stats-grid {
                grid-template-columns: 1fr 1fr;
            }

            .stat-tag {
                display: none;
            }

            .stat-value {
                font-size: 24px;
            }

            .stat-value.compact {
                font-size: 20px;
            }

            .rental-summary,
            .quick-links {
                grid-template-columns: 1fr;
            }

            .dashboard-footer {
                align-items: flex-start;
                flex-direction: column;
            }
        }

        @media (prefers-reduced-motion: reduce) {
            *,
            *::before,
            *::after {
                scroll-behavior: auto !important;
                transition: none !important;
            }
        }
    </style>
</head>

<body class="admin-dashboard-page">

<jsp:include page="/WEB-INF/views/partials/admin-nav.jsp" />

<main class="dashboard-main">

    <!-- Welcome banner -->

    <section class="dashboard-hero">

        <div class="hero-copy">

            <div class="hero-eyebrow">
                <span class="eyebrow-dot"></span>
                CineRent Control Center
            </div>

            <h1 class="hero-title">
                Welcome back,
                <span><%= HtmlUtil.escape(adminName) %></span>
            </h1>

            <p class="hero-description">
                Manage your movie catalogue, customer accounts,
                rentals and reviews from one central workspace.
                Everything you need to operate CineRent is right here.
            </p>

        </div>

        <div class="hero-status">

            <div class="system-status">
                <span></span>
                Dashboard ready
            </div>

            <div class="hero-summary">
                Your platform at a glance
                <strong>
                    <%= String.format(java.util.Locale.US, "%,d", totalRentalCount) %>
                    total rentals
                </strong>
            </div>

        </div>

    </section>


    <!-- Statistics -->

    <section class="dashboard-section">

        <div class="section-heading">

            <div>
                <h2 class="section-title">Platform overview</h2>
                <p class="section-description">
                    A summary of your current CineRent data.
                </p>
            </div>

            <span class="section-kicker">Live statistics</span>

        </div>


        <div class="stats-grid">

            <!-- Movies -->

            <article class="stat-card">

                <div class="stat-top">
                    <div class="stat-icon purple">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="5" width="18" height="14" rx="2"/>
                            <path d="M7 5v14M17 5v14M3 9h4M17 9h4M3 15h4M17 15h4"/>
                        </svg>
                    </div>
                    <span class="stat-tag">Catalogue</span>
                </div>

                <strong class="stat-value">
                    <%= String.format(java.util.Locale.US, "%,d", movieCount) %>
                </strong>

                <div class="stat-label">Total movies</div>
                <div class="stat-note">Titles in your catalogue</div>

            </article>


            <!-- Customers -->

            <article class="stat-card">

                <div class="stat-top">
                    <div class="stat-icon blue">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="9" cy="8" r="3.5"/>
                            <path d="M2.8 19a6.2 6.2 0 0 1 12.4 0"/>
                            <path d="M16 5a3.5 3.5 0 0 1 0 6.8M17 13.5a5.5 5.5 0 0 1 4.2 5.3"/>
                        </svg>
                    </div>
                    <span class="stat-tag">Community</span>
                </div>

                <strong class="stat-value">
                    <%= String.format(java.util.Locale.US, "%,d", customerCount) %>
                </strong>

                <div class="stat-label">Registered customers</div>
                <div class="stat-note">Customer accounts</div>

            </article>


            <!-- Active rentals -->

            <article class="stat-card">

                <div class="stat-top">
                    <div class="stat-icon yellow">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="m10 8 6 4-6 4z"/>
                        </svg>
                    </div>
                    <span class="stat-tag">In progress</span>
                </div>

                <strong class="stat-value">
                    <%= String.format(java.util.Locale.US, "%,d", activeRentalCount) %>
                </strong>

                <div class="stat-label">Active rentals</div>
                <div class="stat-note">Movies currently rented</div>

            </article>


            <!-- Returned rentals -->

            <article class="stat-card">

                <div class="stat-top">
                    <div class="stat-icon green">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="m8 12 2.7 2.7L16.5 9"/>
                        </svg>
                    </div>
                    <span class="stat-tag">Completed</span>
                </div>

                <strong class="stat-value">
                    <%= String.format(java.util.Locale.US, "%,d", returnedRentalCount) %>
                </strong>

                <div class="stat-label">Returned rentals</div>
                <div class="stat-note">Completed rental records</div>

            </article>


            <!-- Reviews -->

            <article class="stat-card">

                <div class="stat-top">
                    <div class="stat-icon pink">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="m12 3 2.7 5.5 6.1.9-4.4 4.3 1 6.1-5.4-2.9-5.4 2.9 1-6.1-4.4-4.3 6.1-.9z"/>
                        </svg>
                    </div>
                    <span class="stat-tag">Feedback</span>
                </div>

                <strong class="stat-value">
                    <%= String.format(java.util.Locale.US, "%,d", reviewCount) %>
                </strong>

                <div class="stat-label">Customer reviews</div>
                <div class="stat-note">Ratings and comments</div>

            </article>


            <!-- Available copies -->

            <article class="stat-card">

                <div class="stat-top">
                    <div class="stat-icon purple">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="m12 3 9 5-9 5-9-5z"/>
                            <path d="m3 8 9 5 9-5M3 8v9l9 5 9-5V8"/>
                            <path d="M12 13v9"/>
                        </svg>
                    </div>
                    <span class="stat-tag">Inventory</span>
                </div>

                <strong class="stat-value compact">
                    <%= String.format(java.util.Locale.US, "%,d", availableCopies) %>
                </strong>

                <div class="stat-label">Available copies</div>
                <div class="stat-note">Copies available for rental</div>

            </article>

        </div>

    </section>


    <!-- Management modules -->

    <section class="dashboard-section">

        <div class="section-heading">

            <div>
                <h2 class="section-title">Management workspace</h2>
                <p class="section-description">
                    Select a module to manage a part of your platform.
                </p>
            </div>

            <span class="section-kicker">4 modules</span>

        </div>


        <div class="modules-grid">

            <!-- Movie management -->

            <a class="module-card" href="<%= ctx %>/movies">

                <div class="module-top">

                    <div class="module-icon purple">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="3" y="5" width="18" height="14" rx="2"/>
                            <path d="M7 5v14M17 5v14M3 9h4M17 9h4M3 15h4M17 15h4"/>
                        </svg>
                    </div>

                    <span class="module-badge">MOVIES</span>

                </div>

                <h3 class="module-title">Movie management</h3>

                <p class="module-description">
                    Add new movies, update descriptions and rental prices,
                    manage ratings, upload posters and maintain available copies.
                </p>

                <div class="module-action">
                    <span>Manage movies</span>
                    <span>→</span>
                </div>

            </a>


            <!-- Customer management -->

            <a class="module-card" href="<%= ctx %>/admin/customers">

                <div class="module-top">

                    <div class="module-icon blue">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="9" cy="8" r="3.5"/>
                            <path d="M2.8 19a6.2 6.2 0 0 1 12.4 0"/>
                            <path d="M16 5a3.5 3.5 0 0 1 0 6.8M17 13.5a5.5 5.5 0 0 1 4.2 5.3"/>
                        </svg>
                    </div>

                    <span class="module-badge">CUSTOMERS</span>

                </div>

                <h3 class="module-title">Customer management</h3>

                <p class="module-description">
                    View registered customers and search by customer ID,
                    name, email address or phone number.
                </p>

                <div class="module-action">
                    <span>Manage customers</span>
                    <span>→</span>
                </div>

            </a>


            <!-- Rental management -->

            <a class="module-card" href="<%= ctx %>/admin/rentals">

                <div class="module-top">

                    <div class="module-icon yellow">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <circle cx="12" cy="12" r="9"/>
                            <path d="m10 8 6 4-6 4z"/>
                        </svg>
                    </div>

                    <span class="module-badge">RENTALS</span>

                </div>

                <h3 class="module-title">Rental management</h3>

                <p class="module-description">
                    Review active rentals, track returned movies and
                    inspect the complete customer rental history.
                </p>

                <div class="module-action">
                    <span>Manage rentals</span>
                    <span>→</span>
                </div>

            </a>


            <!-- Review management -->

            <a class="module-card" href="<%= ctx %>/admin/reviews">

                <div class="module-top">

                    <div class="module-icon pink">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <path d="m12 3 2.7 5.5 6.1.9-4.4 4.3 1 6.1-5.4-2.9-5.4 2.9 1-6.1-4.4-4.3 6.1-.9z"/>
                        </svg>
                    </div>

                    <span class="module-badge">REVIEWS</span>

                </div>

                <h3 class="module-title">Review management</h3>

                <p class="module-description">
                    Review customer ratings and comments, search feedback
                    and remove inappropriate reviews when required.
                </p>

                <div class="module-action">
                    <span>Manage reviews</span>
                    <span>→</span>
                </div>

            </a>

        </div>

    </section>


    <!-- Rental overview and shortcuts -->

    <section class="dashboard-section">

        <div class="section-heading">

            <div>
                <h2 class="section-title">Operations overview</h2>
                <p class="section-description">
                    Monitor rental status and access frequently used tools.
                </p>
            </div>

        </div>


        <div class="bottom-grid">

            <!-- Rental status -->

            <section class="dashboard-panel">

                <div class="panel-heading">
                    <h3>Rental status</h3>
                    <span>
                            <%= String.format(java.util.Locale.US, "%,d", totalRentalCount) %>
                            total records
                        </span>
                </div>


                <div class="rental-summary">

                    <div class="rental-stat">

                        <div class="rental-stat-label">
                            <i style="background:#a78bfa"></i>
                            Active rentals
                        </div>

                        <strong>
                            <%= String.format(java.util.Locale.US, "%,d", activeRentalCount) %>
                        </strong>

                        <small>Currently in progress</small>

                    </div>


                    <div class="rental-stat">

                        <div class="rental-stat-label">
                            <i style="background:#42dfa0"></i>
                            Returned rentals
                        </div>

                        <strong>
                            <%= String.format(java.util.Locale.US, "%,d", returnedRentalCount) %>
                        </strong>

                        <small>Successfully completed</small>

                    </div>

                </div>


                <div class="rental-progress"
                     role="img"
                     aria-label="Rental status distribution">

                    <div class="progress-active"
                         style="width:<%= activePercent %>%">
                    </div>

                    <div class="progress-returned"
                         style="width:<%= returnedPercent %>%">
                    </div>

                </div>


                <div class="progress-legend">

                        <span class="legend-item">
                            <i style="background:#a78bfa"></i>
                            Active: <%= activePercent %>%
                        </span>

                    <span class="legend-item">
                            <i style="background:#42dfa0"></i>
                            Returned: <%= returnedPercent %>%
                        </span>

                </div>

            </section>


            <!-- Quick links -->

            <section class="dashboard-panel">

                <div class="panel-heading">
                    <h3>Quick access</h3>
                    <span>Shortcuts</span>
                </div>


                <div class="quick-links">

                    <a class="quick-link"
                       href="<%= ctx %>/movies?action=add">
                        <span>Add a new movie</span>
                        <span>↗</span>
                    </a>

                    <a class="quick-link"
                       href="<%= ctx %>/admin/customers">
                        <span>Customer directory</span>
                        <span>↗</span>
                    </a>

                    <a class="quick-link"
                       href="<%= ctx %>/admin/rentals">
                        <span>Rental history</span>
                        <span>↗</span>
                    </a>

                    <a class="quick-link"
                       href="<%= ctx %>/admin/reviews">
                        <span>Customer feedback</span>
                        <span>↗</span>
                    </a>

                </div>

            </section>

        </div>

    </section>


    <!-- Footer -->

    <footer class="dashboard-footer">

            <span>
                <span class="footer-brand">CineRent</span>
                &nbsp; Administration workspace
            </span>

        <span>
                Movie Rental &amp; Review Platform
            </span>

    </footer>

</main>

</body>
</html>
