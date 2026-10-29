
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.movierental.util.HtmlUtil" %>
<%@ page import="com.movierental.model.Payment" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>

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

    // The controller must also enforce ADMIN authorization.
    Object currentRole = session.getAttribute("role");
    if (!"ADMIN".equalsIgnoreCase(String.valueOf(currentRole))) {
        response.sendRedirect(ctx + "/login");
        return;
    }

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

    // ----------------------------------------------------------
    // Payment dashboard data, supplied by AdminServlet.
    // Do not query the file store directly from the JSP.
    // ----------------------------------------------------------
    Object paymentAttribute = request.getAttribute("payments");
    boolean paymentDataLoaded = paymentAttribute instanceof List<?>;

    List<Payment> allPayments = new ArrayList<>();
    if (paymentDataLoaded) {
        for (Object item : (List<?>) paymentAttribute) {
            if (item instanceof Payment) {
                allPayments.add((Payment) item);
            }
        }
    }

    int totalPayments = allPayments.size();
    int pendingPayments = 0;
    int paidPayments = 0;
    int rejectedPayments = 0;
    BigDecimal recordedPaidAmount = BigDecimal.ZERO;
    List<Payment> pendingTransfers = new ArrayList<>();

    for (Payment payment : allPayments) {
        if (payment.isPending()) {
            pendingPayments++;
            if (payment.isBankTransfer()) {
                pendingTransfers.add(payment);
            }
        } else if (payment.isPaid()) {
            paidPayments++;
            if (payment.getAmount() != null) {
                recordedPaidAmount = recordedPaidAmount.add(payment.getAmount());
            }
        } else if (payment.isRejected()) {
            rejectedPayments++;
        }
    }

    // Display the newest payment records first.
    List<Payment> recentPayments = new ArrayList<>(allPayments);
    recentPayments.sort((a, b) -> {
        if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
        if (a.getCreatedAt() == null) return 1;
        if (b.getCreatedAt() == null) return -1;
        return b.getCreatedAt().compareTo(a.getCreatedAt());
    });

    String formattedPaidAmount = String.format(
            Locale.US, "LKR %,.2f", recordedPaidAmount
    );
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
            grid-template-columns: repeat(5, minmax(0, 1fr));
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


        /* Payment overview */

        .payment-stats-grid {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 15px;
        }

        .payment-stat-card {
            min-width: 0;
            padding: 21px;
            border: 1px solid var(--dash-border);
            border-radius: 18px;
            background: linear-gradient(145deg, #1a2436, #111827);
        }

        .payment-stat-card .payment-stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            margin-bottom: 17px;
        }

        .payment-stat-icon {
            display: grid;
            place-items: center;
            width: 40px;
            height: 40px;
            border-radius: 12px;
            font-size: 19px;
        }

        .payment-stat-value {
            display: block;
            color: #f6f8ff;
            font-size: clamp(23px, 2.2vw, 31px);
            font-weight: 850;
            letter-spacing: -0.7px;
            font-variant-numeric: tabular-nums;
            overflow-wrap: anywhere;
        }

        .payment-stat-value.amount {
            font-size: clamp(18px, 1.7vw, 25px);
        }

        .payment-stat-label {
            margin-top: 8px;
            color: #a1aec4;
            font-size: 12px;
            font-weight: 650;
        }

        .payment-stat-note {
            margin-top: 12px;
            padding-top: 10px;
            border-top: 1px solid rgba(148, 163, 184, 0.1);
            color: #8290a8;
            font-size: 10px;
            line-height: 1.6;
        }

        .payment-action-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 14px;
            border: 1px solid rgba(135, 85, 255, 0.36);
            border-radius: 10px;
            background: rgba(135, 85, 255, 0.13);
            color: #d8ceff;
            font-size: 11px;
            font-weight: 800;
        }

        .payment-action-link:hover {
            background: rgba(135, 85, 255, 0.25);
        }

        .payment-ops-grid {
            display: grid;
            grid-template-columns: minmax(0, 0.95fr) minmax(0, 1.05fr);
            gap: 18px;
        }

        .payment-panel {
            min-width: 0;
            padding: 24px;
            border: 1px solid var(--dash-border);
            border-radius: 20px;
            background: rgba(20, 29, 44, 0.92);
        }

        .payment-panel-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            margin-bottom: 17px;
        }

        .payment-panel-heading h3 {
            margin: 0;
            color: #f0f3ff;
            font-size: 15px;
            font-weight: 800;
        }

        .payment-panel-heading a {
            color: #bca7ff;
            font-size: 11px;
            font-weight: 750;
        }

        .payment-queue-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            padding: 15px 0;
            border-bottom: 1px solid rgba(148, 163, 184, 0.11);
        }

        .payment-queue-item:last-child {
            border-bottom: 0;
        }

        .payment-queue-item strong {
            display: block;
            color: #e9edff;
            font-size: 12px;
            overflow-wrap: anywhere;
        }

        .payment-queue-item small {
            display: block;
            margin-top: 5px;
            color: #91a0b9;
            font-size: 10px;
            line-height: 1.6;
        }

        .payment-queue-amount {
            text-align: right;
            flex-shrink: 0;
        }

        .payment-queue-amount b {
            display: block;
            color: #e5e7eb;
            font-size: 12px;
        }

        .payment-status {
            display: inline-block;
            margin-top: 6px;
            padding: 4px 7px;
            border-radius: 999px;
            font-size: 9px;
            font-weight: 800;
            letter-spacing: 0.4px;
        }

        .payment-status.pending {
            color: #ffd16e;
            background: rgba(255, 190, 60, 0.13);
        }

        .payment-status.paid {
            color: #63e9b0;
            background: rgba(66, 223, 160, 0.13);
        }

        .payment-status.failed {
            color: #ff9fa7;
            background: rgba(255, 95, 112, 0.13);
        }

        .payment-empty {
            padding: 24px 14px;
            border: 1px dashed rgba(148, 163, 184, 0.19);
            border-radius: 12px;
            color: #94a3b8;
            font-size: 12px;
            line-height: 1.8;
            text-align: center;
        }

        .payment-note {
            margin-top: 17px;
            color: #8290a8;
            font-size: 11px;
            line-height: 1.7;
        }

        @media (max-width: 1100px) {
            .payment-stats-grid {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }
        }

        @media (max-width: 760px) {
            .payment-ops-grid {
                grid-template-columns: 1fr;
            }
            .payment-panel {
                padding: 18px;
            }
        }

        @media (max-width: 420px) {
            .payment-stats-grid {
                grid-template-columns: 1fr 1fr;
                gap: 10px;
            }
            .payment-stat-card {
                padding: 15px;
            }
            .payment-queue-item {
                align-items: flex-start;
            }
            .payment-queue-amount b {
                font-size: 11px;
            }
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
                rentals, reviews and payment approvals from one central workspace.
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


    <!-- Payment statistics: loaded by AdminServlet -->

    <section class="dashboard-section" aria-labelledby="payment-overview-title">

        <div class="section-heading">
            <div>
                <h2 class="section-title" id="payment-overview-title">Payment overview</h2>
                <p class="section-description">
                    Monitor checkout transactions, approvals and recorded payments.
                </p>
            </div>
            <a class="payment-action-link" href="<%= ctx %>/admin/payments">
                Manage payments &rarr;
            </a>
        </div>

        <div class="payment-stats-grid">

            <article class="payment-stat-card">
                <div class="payment-stat-top">
                    <span class="payment-stat-icon purple">&#128179;</span>
                    <span class="stat-tag">Transactions</span>
                </div>
                <strong class="payment-stat-value">
                    <%= paymentDataLoaded ? String.format(Locale.US, "%,d", totalPayments) : "—" %>
                </strong>
                <div class="payment-stat-label">Total payments</div>
                <div class="payment-stat-note">All recorded payment attempts</div>
            </article>

            <article class="payment-stat-card">
                <div class="payment-stat-top">
                    <span class="payment-stat-icon yellow">&#9203;</span>
                    <span class="stat-tag">Action needed</span>
                </div>
                <strong class="payment-stat-value">
                    <%= paymentDataLoaded ? String.format(Locale.US, "%,d", pendingPayments) : "—" %>
                </strong>
                <div class="payment-stat-label">Pending payments</div>
                <div class="payment-stat-note">Bank transfers may require verification</div>
            </article>

            <article class="payment-stat-card">
                <div class="payment-stat-top">
                    <span class="payment-stat-icon green">&#10003;</span>
                    <span class="stat-tag">Approved</span>
                </div>
                <strong class="payment-stat-value">
                    <%= paymentDataLoaded ? String.format(Locale.US, "%,d", paidPayments) : "—" %>
                </strong>
                <div class="payment-stat-label">Paid transactions</div>
                <div class="payment-stat-note">Includes simulated demo card payments</div>
            </article>

            <article class="payment-stat-card">
                <div class="payment-stat-top">
                    <span class="payment-stat-icon blue">&#128200;</span>
                    <span class="stat-tag">Recorded value</span>
                </div>
                <strong class="payment-stat-value amount">
                    <%= paymentDataLoaded ? HtmlUtil.escape(formattedPaidAmount) : "—" %>
                </strong>
                <div class="payment-stat-label">Total marked paid</div>
                <div class="payment-stat-note">Not verified cash revenue; demo payments included</div>
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

            <span class="section-kicker">5 modules</span>

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


            <!-- Payment management -->

            <a class="module-card" href="<%= ctx %>/admin/payments">

                <div class="module-top">
                    <div class="module-icon green">
                        <svg viewBox="0 0 24 24" aria-hidden="true">
                            <rect x="2" y="5" width="20" height="14" rx="3"/>
                            <path d="M2 10h20M6 15h4"/>
                        </svg>
                    </div>
                    <span class="module-badge">PAYMENTS</span>
                </div>

                <h3 class="module-title">Payment management</h3>

                <p class="module-description">
                    Review checkout records, verify bank transfers, approve or
                    reject pending payments and track linked rental references.
                </p>

                <div class="module-action">
                    <span>Manage payments</span>
                    <span>→</span>
                </div>

            </a>

        </div>

    </section>


    <!-- Payment operations -->

    <section class="dashboard-section" aria-labelledby="payment-operations-title">

        <div class="section-heading">
            <div>
                <h2 class="section-title" id="payment-operations-title">Payment operations</h2>
                <p class="section-description">
                    Bank transfer verification queue and latest transaction activity.
                </p>
            </div>
            <span class="section-kicker">Admin verification</span>
        </div>

        <div class="payment-ops-grid">

            <section class="payment-panel">
                <div class="payment-panel-heading">
                    <h3>Bank transfers awaiting approval</h3>
                    <a href="<%= ctx %>/admin/payments">View all &rarr;</a>
                </div>

                <% if (!paymentDataLoaded) { %>
                <div class="payment-empty">
                    Payment data has not been loaded by the dashboard servlet.
                    See the integration instructions below this file.
                </div>
                <% } else if (pendingTransfers.isEmpty()) { %>
                <div class="payment-empty">
                    No bank transfers are currently awaiting verification.
                </div>
                <% } else { %>
                <%
                    int queueLimit = Math.min(5, pendingTransfers.size());
                    for (int i = 0; i < queueLimit; i++) {
                        Payment payment = pendingTransfers.get(i);
                %>
                <div class="payment-queue-item">
                    <div>
                        <strong>Payment #<%= HtmlUtil.escape(payment.getPaymentId()) %></strong>
                        <small>
                            Customer <%= HtmlUtil.escape(payment.getUserId()) %>
                            &middot; Movie <%= HtmlUtil.escape(payment.getMovieId()) %>
                        </small>
                    </div>
                    <div class="payment-queue-amount">
                        <b><%= HtmlUtil.escape(payment.getFormattedAmount()) %></b>
                        <span class="payment-status pending">PENDING</span>
                    </div>
                </div>
                <% } %>
                <% } %>

                <p class="payment-note">
                    Approve transfers only after independently verifying the receipt
                    and bank transaction. Approval alone does not activate a rental
                    until rental creation is integrated into the backend.
                </p>
            </section>

            <section class="payment-panel">
                <div class="payment-panel-heading">
                    <h3>Recent payments</h3>
                    <a href="<%= ctx %>/admin/payments">View all &rarr;</a>
                </div>

                <% if (!paymentDataLoaded) { %>
                <div class="payment-empty">
                    Recent payment activity will appear when the servlet supplies
                    the <code>payments</code> request attribute.
                </div>
                <% } else if (recentPayments.isEmpty()) { %>
                <div class="payment-empty">
                    No payment records have been created yet.
                </div>
                <% } else { %>
                <%
                    int recentLimit = Math.min(6, recentPayments.size());
                    for (int i = 0; i < recentLimit; i++) {
                        Payment payment = recentPayments.get(i);
                        String paymentCss = payment.isPaid() ? "paid" :
                                payment.isPending() ? "pending" : "failed";
                %>
                <div class="payment-queue-item">
                    <div>
                        <strong>#<%= HtmlUtil.escape(payment.getPaymentId()) %></strong>
                        <small>
                            <%= HtmlUtil.escape(payment.getPaymentMethodDisplay()) %>
                            &middot; <%= HtmlUtil.escape(payment.getFormattedCreatedAt()) %>
                        </small>
                    </div>
                    <div class="payment-queue-amount">
                        <b><%= HtmlUtil.escape(payment.getFormattedAmount()) %></b>
                        <span class="payment-status <%= paymentCss %>">
                                    <%= HtmlUtil.escape(payment.getPaymentStatus()) %>
                                </span>
                    </div>
                </div>
                <% } %>
                <% } %>
            </section>

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

                    <a class="quick-link"
                       href="<%= ctx %>/admin/payments">
                        <span>Verify bank transfers</span>
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
