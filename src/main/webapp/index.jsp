<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    String ctx =
            request.getContextPath();

    String userName =
            (String) session.getAttribute(
                    "userName"
            );

    String role =
            (String) session.getAttribute(
                    "role"
            );


    // =========================================================
    // LOGIN CHECK
    // =========================================================

    if (
            userName == null
                    ||
                    role == null
    ) {

        response.sendRedirect(
                ctx + "/login"
        );

        return;
    }


    // =========================================================
    // ADMIN REDIRECT
    // =========================================================

    if (
            "ADMIN".equalsIgnoreCase(
                    role
            )
    ) {

        response.sendRedirect(
                ctx + "/admin"
        );

        return;
    }


    // =========================================================
    // USER INITIAL
    // =========================================================

    String userInitial =
            "U";

    if (
            userName != null
                    &&
                    !userName.trim().isEmpty()
    ) {

        userInitial =
                userName
                        .trim()
                        .substring(
                                0,
                                1
                        )
                        .toUpperCase();
    }
%>


<!DOCTYPE html>

<html lang="en">


<head>

    <meta charset="UTF-8">

    <meta
            name="viewport"
            content="width=device-width, initial-scale=1.0"
    >

    <title>
        Home | CineRent
    </title>


    <link
            rel="stylesheet"
            href="<%= ctx %>/css/style.css"
    >


    <style>

        /* =====================================================
           ROOT
        ====================================================== */

        :root {

            --home-bg:
                    #050811;

            --home-card:
                    rgba(
                            20,
                            28,
                            47,
                            0.72
                    );

            --home-border:
                    rgba(
                            255,
                            255,
                            255,
                            0.08
                    );

            --home-text:
                    #ffffff;

            --home-muted:
                    #94a3b8;

            --home-purple:
                    #7c3aed;

            --home-purple-light:
                    #a78bfa;

            --home-blue:
                    #3b82f6;

        }


        * {
            box-sizing:
                    border-box;
        }


        html {
            scroll-behavior:
                    smooth;
        }


        body {

            margin: 0;

            min-height:
                    100vh;

            background:
                    var(--home-bg);

            color:
                    var(--home-text);

            overflow-x:
                    hidden;

        }


        /* =====================================================
           BACKGROUND
        ====================================================== */

        .home-background {

            position:
                    fixed;

            inset: 0;

            pointer-events:
                    none;

            z-index:
                    -1;

            background:

                    radial-gradient(
                            circle at 78% 15%,
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.18
                            ),
                            transparent 30%
                    ),

                    radial-gradient(
                            circle at 18% 55%,
                            rgba(
                                    37,
                                    99,
                                    235,
                                    0.11
                            ),
                            transparent 27%
                    ),

                    linear-gradient(
                            180deg,
                            #080b16 0%,
                            #050811 50%,
                            #04070e 100%
                    );

        }


        .home-background::after {

            content: "";

            position:
                    absolute;

            inset: 0;

            opacity:
                    0.20;

            background-image:

                    linear-gradient(
                            rgba(
                                    255,
                                    255,
                                    255,
                                    0.02
                            )
                            1px,
                            transparent
                            1px
                    ),

                    linear-gradient(
                            90deg,
                            rgba(
                                    255,
                                    255,
                                    255,
                                    0.02
                            )
                            1px,
                            transparent
                            1px
                    );

            background-size:
                    45px 45px;

            mask-image:
                    linear-gradient(
                            to bottom,
                            black,
                            transparent 75%
                    );

        }


        /* =====================================================
           NAVBAR
        ====================================================== */

        .customer-home-nav {

            position:
                    sticky;

            top: 0;

            z-index:
                    1000;

            border-bottom:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );

            background:
                    rgba(
                            4,
                            7,
                            14,
                            0.78
                    );

            backdrop-filter:
                    blur(18px);

        }


        .home-nav-inner {

            width:
                    92%;

            max-width:
                    1380px;

            min-height:
                    78px;

            margin:
                    0 auto;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    space-between;

            gap:
                    30px;

        }


        .home-brand {

            display:
                    flex;

            align-items:
                    center;

            gap:
                    11px;

            color:
                    #ffffff;

            text-decoration:
                    none;

            font-size:
                    21px;

            font-weight:
                    850;

            letter-spacing:
                    -0.6px;

        }


        .home-brand-logo {

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            width:
                    42px;

            height:
                    42px;

            border-radius:
                    14px;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6,
                            #4f46e5
                    );

            box-shadow:
                    0
                    10px
                    30px
                    rgba(
                            124,
                            58,
                            237,
                            0.28
                    );

        }


        .home-nav-links {

            display:
                    flex;

            align-items:
                    center;

            gap:
                    7px;

            margin-left:
                    auto;

        }


        .home-nav-link {

            padding:
                    10px
                    13px;

            border-radius:
                    10px;

            color:
                    #94a3b8;

            text-decoration:
                    none;

            font-size:
                    13px;

            font-weight:
                    650;

            transition:
                    all
                    0.2s ease;

        }


        .home-nav-link:hover,
        .home-nav-link.active {

            color:
                    #ffffff;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );

        }


        /* =====================================================
           USER
        ====================================================== */

        .home-user {

            display:
                    flex;

            align-items:
                    center;

            gap:
                    11px;

            margin-left:
                    10px;

        }


        .home-avatar {

            width:
                    38px;

            height:
                    38px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            flex-shrink:
                    0;

            border-radius:
                    50%;

            background:
                    linear-gradient(
                            135deg,
                            #8b5cf6,
                            #3b82f6
                    );

            color:
                    #ffffff;

            font-size:
                    14px;

            font-weight:
                    800;

        }


        .home-user-details {

            display:
                    flex;

            flex-direction:
                    column;

            line-height:
                    1.2;

        }


        .home-user-name {

            max-width:
                    150px;

            overflow:
                    hidden;

            text-overflow:
                    ellipsis;

            white-space:
                    nowrap;

            font-size:
                    12px;

            font-weight:
                    700;

        }


        .home-user-role {

            margin-top:
                    3px;

            color:
                    #64748b;

            font-size:
                    9px;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.8px;

        }


        .home-logout {

            padding:
                    9px
                    13px;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.10
                    );

            border-radius:
                    9px;

            color:
                    #cbd5e1;

            text-decoration:
                    none;

            font-size:
                    11px;

            font-weight:
                    700;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.04
                    );

            transition:
                    all
                    0.2s ease;

        }


        .home-logout:hover {

            border-color:
                    rgba(
                            239,
                            68,
                            68,
                            0.35
                    );

            color:
                    #fca5a5;

            background:
                    rgba(
                            239,
                            68,
                            68,
                            0.08
                    );

        }


        /* =====================================================
           HERO
        ====================================================== */

        .customer-hero {

            width:
                    92%;

            max-width:
                    1380px;

            margin:
                    0 auto;

            min-height:
                    610px;

            display:
                    grid;

            grid-template-columns:
                    minmax(
                            0,
                            1.08fr
                    )
                    minmax(
                            440px,
                            0.92fr
                    );

            align-items:
                    center;

            gap:
                    80px;

            padding:
                    75px
                    0
                    60px;

        }


        .welcome-chip {

            display:
                    inline-flex;

            align-items:
                    center;

            gap:
                    8px;

            margin-bottom:
                    22px;

            padding:
                    8px
                    13px;

            border:
                    1px solid
                    rgba(
                            139,
                            92,
                            246,
                            0.30
                    );

            border-radius:
                    999px;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.08
                    );

            color:
                    #c4b5fd;

            font-size:
                    11px;

            font-weight:
                    700;

        }


        .welcome-chip-dot {

            width:
                    7px;

            height:
                    7px;

            border-radius:
                    50%;

            background:
                    #8b5cf6;

            box-shadow:
                    0
                    0
                    13px
                    #8b5cf6;

        }


        .customer-hero-title {

            max-width:
                    720px;

            margin: 0;

            font-size:
                    clamp(
                            54px,
                            6.5vw,
                            94px
                    );

            line-height:
                    0.93;

            letter-spacing:
                    -5px;

            font-weight:
                    900;

        }


        .customer-hero-title .gradient-text {

            color:
                    transparent;

            background:
                    linear-gradient(
                            90deg,
                            #a78bfa,
                            #7c3aed,
                            #60a5fa
                    );

            -webkit-background-clip:
                    text;

            background-clip:
                    text;

        }


        .customer-hero-description {

            max-width:
                    620px;

            margin:
                    26px
                    0
                    0;

            color:
                    #9ca9bd;

            font-size:
                    17px;

            line-height:
                    1.8;

        }


        .hero-user-name {

            color:
                    #ffffff;

            font-weight:
                    700;

        }


        /* =====================================================
           HERO BUTTONS
        ====================================================== */

        .hero-actions {

            display:
                    flex;

            flex-wrap:
                    wrap;

            gap:
                    12px;

            margin-top:
                    31px;

        }


        .home-primary-button,
        .home-secondary-button {

            min-height:
                    49px;

            display:
                    inline-flex;

            align-items:
                    center;

            justify-content:
                    center;

            gap:
                    8px;

            padding:
                    0
                    19px;

            border-radius:
                    11px;

            text-decoration:
                    none;

            font-size:
                    13px;

            font-weight:
                    750;

            transition:
                    transform
                    0.2s ease,
                    box-shadow
                    0.2s ease,
                    border-color
                    0.2s ease;

        }


        .home-primary-button {

            color:
                    #ffffff;

            background:
                    linear-gradient(
                            135deg,
                            #6d28d9,
                            #8b5cf6
                    );

            box-shadow:
                    0
                    13px
                    34px
                    rgba(
                            124,
                            58,
                            237,
                            0.26
                    );

        }


        .home-primary-button:hover {

            transform:
                    translateY(-2px);

            box-shadow:
                    0
                    17px
                    40px
                    rgba(
                            124,
                            58,
                            237,
                            0.36
                    );

        }


        .home-secondary-button {

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.10
                    );

            color:
                    #e2e8f0;

            background:
                    rgba(
                            255,
                            255,
                            255,
                            0.04
                    );

        }


        .home-secondary-button:hover {

            transform:
                    translateY(-2px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.35
                    );

        }


        /* =====================================================
           HERO VISUAL
        ====================================================== */

        .hero-visual {

            position:
                    relative;

            min-height:
                    465px;

        }


        .hero-glow {

            position:
                    absolute;

            width:
                    390px;

            height:
                    390px;

            top:
                    18px;

            left:
                    50%;

            transform:
                    translateX(-50%);

            border-radius:
                    50%;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.22
                    );

            filter:
                    blur(100px);

        }


        .featured-card {

            position:
                    absolute;

            width:
                    min(
                            420px,
                            82%
                    );

            left:
                    50%;

            top:
                    35px;

            transform:
                    translateX(-50%)
                    rotate(2deg);

            padding:
                    13px;

            border-radius:
                    28px;

            background:
                    linear-gradient(
                            145deg,
                            rgba(
                                    30,
                                    41,
                                    59,
                                    0.92
                            ),
                            rgba(
                                    7,
                                    12,
                                    24,
                                    0.96
                            )
                    );

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.09
                    );

            box-shadow:
                    0
                    40px
                    90px
                    rgba(
                            0,
                            0,
                            0,
                            0.45
                    );

        }


        .featured-screen {

            position:
                    relative;

            height:
                    305px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            overflow:
                    hidden;

            border-radius:
                    19px;

            background:

                    radial-gradient(
                            circle at 70% 25%,
                            rgba(
                                    139,
                                    92,
                                    246,
                                    0.78
                            ),
                            transparent 28%
                    ),

                    radial-gradient(
                            circle at 20% 20%,
                            rgba(
                                    37,
                                    99,
                                    235,
                                    0.50
                            ),
                            transparent 35%
                    ),

                    linear-gradient(
                            145deg,
                            #132650,
                            #080e1c 70%
                    );

        }


        .featured-screen::after {

            content: "";

            position:
                    absolute;

            inset: 0;

            background:
                    linear-gradient(
                            to top,
                            rgba(
                                    3,
                                    7,
                                    18,
                                    0.75
                            ),
                            transparent 50%
                    );

        }


        .featured-play {

            position:
                    relative;

            z-index:
                    2;

            width:
                    75px;

            height:
                    75px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            border:
                    2px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.80
                    );

            border-radius:
                    50%;

            color:
                    #ffffff;

            font-size:
                    24px;

            background:
                    rgba(
                            0,
                            0,
                            0,
                            0.20
                    );

            backdrop-filter:
                    blur(8px);

        }


        .featured-film-icon {

            position:
                    absolute;

            z-index:
                    2;

            left:
                    24px;

            bottom:
                    22px;

            font-size:
                    37px;

        }


        .featured-content {

            padding:
                    19px
                    9px
                    7px;

        }


        .featured-small {

            margin-bottom:
                    6px;

            color:
                    #8b5cf6;

            font-size:
                    10px;

            font-weight:
                    800;

            letter-spacing:
                    1px;

            text-transform:
                    uppercase;

        }


        .featured-title {

            margin: 0;

            font-size:
                    20px;

            font-weight:
                    800;

        }


        .featured-text {

            margin:
                    6px
                    0
                    0;

            color:
                    #94a3b8;

            font-size:
                    12px;

        }


        .floating-card {

            position:
                    absolute;

            display:
                    flex;

            align-items:
                    center;

            gap:
                    10px;

            padding:
                    11px
                    14px;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.08
                    );

            border-radius:
                    14px;

            background:
                    rgba(
                            15,
                            23,
                            42,
                            0.84
                    );

            box-shadow:
                    0
                    15px
                    40px
                    rgba(
                            0,
                            0,
                            0,
                            0.30
                    );

            backdrop-filter:
                    blur(14px);

        }


        .floating-one {

            left:
                    0;

            top:
                    105px;

        }


        .floating-two {

            right:
                    -8px;

            bottom:
                    40px;

        }


        .floating-icon {

            width:
                    34px;

            height:
                    34px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            border-radius:
                    10px;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.15
                    );

        }


        .floating-label {

            color:
                    #64748b;

            font-size:
                    9px;

            text-transform:
                    uppercase;

            letter-spacing:
                    0.6px;

        }


        .floating-value {

            margin-top:
                    3px;

            font-size:
                    12px;

            font-weight:
                    750;

        }


        /* =====================================================
           QUICK ACCESS SECTION
        ====================================================== */

        .home-section {

            width:
                    92%;

            max-width:
                    1380px;

            margin:
                    0 auto;

            padding:
                    35px
                    0
                    80px;

        }


        .section-heading-home {

            display:
                    flex;

            justify-content:
                    space-between;

            align-items:
                    flex-end;

            gap:
                    20px;

            margin-bottom:
                    24px;

        }


        .section-heading-home h2 {

            margin: 0;

            font-size:
                    31px;

            letter-spacing:
                    -1px;

        }


        .section-heading-home p {

            margin:
                    7px
                    0
                    0;

            color:
                    #64748b;

            font-size:
                    13px;

        }


        .quick-access-grid {

            display:
                    grid;

            grid-template-columns:
                    repeat(
                            3,
                            1fr
                    );

            gap:
                    18px;

        }


        .quick-card {

            position:
                    relative;

            min-height:
                    245px;

            display:
                    flex;

            flex-direction:
                    column;

            padding:
                    26px;

            overflow:
                    hidden;

            border:
                    1px solid
                    var(--home-border);

            border-radius:
                    22px;

            color:
                    #ffffff;

            text-decoration:
                    none;

            background:
                    var(--home-card);

            transition:
                    transform
                    0.25s ease,
                    border-color
                    0.25s ease;

        }


        .quick-card::after {

            content: "";

            position:
                    absolute;

            width:
                    180px;

            height:
                    180px;

            right:
                    -90px;

            bottom:
                    -90px;

            border-radius:
                    50%;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.15
                    );

            filter:
                    blur(15px);

        }


        .quick-card:hover {

            transform:
                    translateY(-6px);

            border-color:
                    rgba(
                            139,
                            92,
                            246,
                            0.42
                    );

        }


        .quick-card-icon {

            width:
                    54px;

            height:
                    54px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            margin-bottom:
                    25px;

            border-radius:
                    15px;

            background:
                    rgba(
                            124,
                            58,
                            237,
                            0.14
                    );

            font-size:
                    25px;

        }


        .quick-card h3 {

            margin:
                    0
                    0
                    9px;

            font-size:
                    19px;

        }


        .quick-card p {

            max-width:
                    310px;

            margin:
                    0;

            color:
                    #94a3b8;

            font-size:
                    13px;

            line-height:
                    1.7;

        }


        .quick-card-action {

            margin-top:
                    auto;

            padding-top:
                    22px;

            color:
                    #c4b5fd;

            font-size:
                    12px;

            font-weight:
                    750;

        }


        /* =====================================================
           EXPERIENCE
        ====================================================== */

        .experience-section {

            width:
                    92%;

            max-width:
                    1380px;

            margin:
                    0 auto
                    80px;

            padding:
                    38px;

            display:
                    grid;

            grid-template-columns:
                    1.15fr
                    0.85fr;

            gap:
                    35px;

            align-items:
                    center;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.07
                    );

            border-radius:
                    26px;

            background:
                    linear-gradient(
                            135deg,
                            rgba(
                                    30,
                                    41,
                                    59,
                                    0.55
                            ),
                            rgba(
                                    124,
                                    58,
                                    237,
                                    0.06
                            )
                    );

        }


        .experience-badge {

            color:
                    #a78bfa;

            font-size:
                    11px;

            font-weight:
                    800;

            text-transform:
                    uppercase;

            letter-spacing:
                    1px;

        }


        .experience-section h2 {

            max-width:
                    660px;

            margin:
                    10px
                    0
                    13px;

            font-size:
                    clamp(
                            28px,
                            3vw,
                            42px
                    );

            letter-spacing:
                    -1.5px;

        }


        .experience-section p {

            max-width:
                    650px;

            margin: 0;

            color:
                    #94a3b8;

            line-height:
                    1.8;

        }


        .experience-list {

            display:
                    grid;

            gap:
                    12px;

        }


        .experience-item {

            display:
                    flex;

            align-items:
                    center;

            gap:
                    12px;

            padding:
                    14px;

            border:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );

            border-radius:
                    13px;

            background:
                    rgba(
                            2,
                            6,
                            23,
                            0.30
                    );

        }


        .experience-check {

            width:
                    31px;

            height:
                    31px;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    center;

            flex-shrink:
                    0;

            border-radius:
                    9px;

            background:
                    rgba(
                            34,
                            197,
                            94,
                            0.10
                    );

            color:
                    #4ade80;

        }


        .experience-item span:last-child {

            font-size:
                    12px;

            font-weight:
                    650;

        }


        /* =====================================================
           FOOTER
        ====================================================== */

        .customer-home-footer {

            border-top:
                    1px solid
                    rgba(
                            255,
                            255,
                            255,
                            0.06
                    );

        }


        .customer-footer-inner {

            width:
                    92%;

            max-width:
                    1380px;

            min-height:
                    82px;

            margin:
                    0 auto;

            display:
                    flex;

            align-items:
                    center;

            justify-content:
                    space-between;

            gap:
                    20px;

            color:
                    #475569;

            font-size:
                    11px;

        }


        /* =====================================================
           RESPONSIVE
        ====================================================== */

        @media (
        max-width: 1050px
        ) {

            .home-nav-links {

                display:
                        none;

            }


            .customer-hero {

                grid-template-columns:
                        1fr;

                gap:
                        30px;

                padding-top:
                        65px;

            }


            .hero-visual {

                width:
                        min(
                                620px,
                                100%
                        );

                margin:
                        0 auto;

            }


            .quick-access-grid {

                grid-template-columns:
                        1fr
                        1fr;

            }


            .experience-section {

                grid-template-columns:
                        1fr;

            }

        }


        @media (
        max-width: 700px
        ) {

            .home-user-details {

                display:
                        none;

            }


            .customer-hero {

                min-height:
                        auto;

                padding:
                        55px
                        0
                        30px;

            }


            .customer-hero-title {

                font-size:
                        58px;

                letter-spacing:
                        -3px;

            }


            .customer-hero-description {

                font-size:
                        14px;

            }


            .hero-visual {

                min-height:
                        400px;

            }


            .featured-card {

                width:
                        90%;

            }


            .floating-one {

                left:
                        -5px;

            }


            .floating-two {

                right:
                        -5px;

            }


            .quick-access-grid {

                grid-template-columns:
                        1fr;

            }


            .experience-section {

                padding:
                        24px;

            }


            .customer-footer-inner {

                flex-direction:
                        column;

                justify-content:
                        center;

                padding:
                        20px
                        0;

            }

        }


        @media (
        max-width: 480px
        ) {

            .home-nav-inner {

                width:
                        90%;

            }


            .home-brand {

                font-size:
                        18px;

            }


            .home-brand-logo {

                width:
                        38px;

                height:
                        38px;

            }


            .home-avatar {

                display:
                        none;

            }


            .customer-hero-title {

                font-size:
                        49px;

            }


            .hero-actions {

                flex-direction:
                        column;

            }


            .home-primary-button,
            .home-secondary-button {

                width:
                        100%;

            }


            .featured-screen {

                height:
                        255px;

            }


            .floating-card {

                display:
                        none;

            }

        }

    </style>

</head>


<body>


<div class="home-background"></div>


<!-- =========================================================
     NAVBAR
========================================================= -->

<header class="customer-home-nav">


    <div class="home-nav-inner">


        <!-- BRAND -->

        <a
                href="<%= ctx %>/"
                class="home-brand"
        >


            <span class="home-brand-logo">

                🎬

            </span>


            <span>

                CineRent

            </span>


        </a>


        <!-- LINKS -->

        <nav class="home-nav-links">


            <a
                    href="<%= ctx %>/"
                    class="home-nav-link active"
            >

                Home

            </a>


            <a
                    href="<%= ctx %>/catalog"
                    class="home-nav-link"
            >

                Movies

            </a>


            <a
                    href="<%= ctx %>/rentals"
                    class="home-nav-link"
            >

                My Rentals

            </a>


            <a
                    href="<%= ctx %>/recently-watched"
                    class="home-nav-link"
            >

                Recently Watched

            </a>


        </nav>


        <!-- USER -->

        <div class="home-user">


            <div class="home-avatar">

                <%= HtmlUtil.escape(
                        userInitial
                ) %>

            </div>


            <div class="home-user-details">


                <span class="home-user-name">

                    <%= HtmlUtil.escape(
                            userName
                    ) %>

                </span>


                <span class="home-user-role">

                    Customer

                </span>


            </div>


            <a
                    href="<%= ctx %>/logout"
                    class="home-logout"
            >

                Logout

            </a>


        </div>


    </div>


</header>


<!-- =========================================================
     HERO
========================================================= -->

<section class="customer-hero">


    <!-- LEFT -->

    <div class="customer-hero-content">


        <div class="welcome-chip">


            <span class="welcome-chip-dot"></span>


            Welcome back,

            <span class="hero-user-name">

                <%= HtmlUtil.escape(
                        userName
                ) %>

            </span>


        </div>


        <h1 class="customer-hero-title">

            Find it.<br>

            Rent it.<br>

            <span class="gradient-text">

                Love it.

            </span>

        </h1>


        <p class="customer-hero-description">

            Your next movie night starts here.
            Discover movies, rent your favourites,
            keep track of what you have watched and
            share your experience with the CineRent community.

        </p>


        <div class="hero-actions">


            <a
                    href="<%= ctx %>/catalog"
                    class="home-primary-button"
            >

                ▶ Browse Movies

                <span>
                    →
                </span>

            </a>


            <a
                    href="<%= ctx %>/rentals"
                    class="home-secondary-button"
            >

                📀 My Rentals

            </a>


        </div>


    </div>


    <!-- =====================================================
         HERO VISUAL
    ====================================================== -->

    <div class="hero-visual">


        <div class="hero-glow"></div>


        <div class="featured-card">


            <div class="featured-screen">


                <div class="featured-play">

                    ▶

                </div>


                <div class="featured-film-icon">

                    🎞️

                </div>


            </div>


            <div class="featured-content">


                <div class="featured-small">

                    CineRent Featured

                </div>


                <h3 class="featured-title">

                    Your next story is waiting.

                </h3>


                <p class="featured-text">

                    Browse • Rent • Return • Review

                </p>


            </div>


        </div>


        <!-- FLOATING CARD -->

        <div class="floating-card floating-one">


            <div class="floating-icon">

                ⭐

            </div>


            <div>


                <div class="floating-label">

                    Community

                </div>


                <div class="floating-value">

                    Rate & Review

                </div>


            </div>


        </div>


        <div class="floating-card floating-two">


            <div class="floating-icon">

                🎬

            </div>


            <div>


                <div class="floating-label">

                    CineRent

                </div>


                <div class="floating-value">

                    Movie Collection

                </div>


            </div>


        </div>


    </div>


</section>


<!-- =========================================================
     QUICK ACCESS
========================================================= -->

<section class="home-section">


    <div class="section-heading-home">


        <div>


            <h2>

                Continue your journey.

            </h2>


            <p>

                Everything you need for your movie experience.

            </p>


        </div>


    </div>


    <div class="quick-access-grid">


        <!-- MOVIES -->

        <a
                href="<%= ctx %>/catalog"
                class="quick-card"
        >


            <div class="quick-card-icon">

                🎬

            </div>


            <h3>

                Discover Movies

            </h3>


            <p>

                Explore the CineRent catalogue,
                compare ratings and discover
                something new to watch.

            </p>


            <div class="quick-card-action">

                Browse catalogue →

            </div>


        </a>


        <!-- RENTALS -->

        <a
                href="<%= ctx %>/rentals"
                class="quick-card"
        >


            <div class="quick-card-icon">

                📀

            </div>


            <h3>

                My Rentals

            </h3>


            <p>

                View active rentals,
                return your movies and keep
                track of your rental activity.

            </p>


            <div class="quick-card-action">

                View rentals →

            </div>


        </a>


        <!-- HISTORY -->

        <a
                href="<%= ctx %>/recently-watched"
                class="quick-card"
        >


            <div class="quick-card-icon">

                🕘

            </div>


            <h3>

                Recently Watched

            </h3>


            <p>

                Look back at movies you have
                returned and quickly find titles
                you enjoyed before.

            </p>


            <div class="quick-card-action">

                View history →

            </div>


        </a>


    </div>


</section>


<!-- =========================================================
     EXPERIENCE SECTION
========================================================= -->

<section class="experience-section">


    <div>


        <div class="experience-badge">

            CineRent Experience

        </div>


        <h2>

            One place for your complete
            movie rental journey.

        </h2>


        <p>

            CineRent keeps movie discovery,
            rentals, returns, recently watched
            titles and customer reviews together
            in one simple platform.

        </p>


    </div>


    <div class="experience-list">


        <div class="experience-item">


            <span class="experience-check">

                ✓

            </span>


            <span>

                Browse and discover available movies

            </span>


        </div>


        <div class="experience-item">


            <span class="experience-check">

                ✓

            </span>


            <span>

                Manage active rentals and returns

            </span>


        </div>


        <div class="experience-item">


            <span class="experience-check">

                ✓

            </span>


            <span>

                Track your recently watched movies

            </span>


        </div>


        <div class="experience-item">


            <span class="experience-check">

                ✓

            </span>


            <span>

                Rate and review movies after watching

            </span>


        </div>


    </div>


</section>


<!-- =========================================================
     FOOTER
========================================================= -->

<footer class="customer-home-footer">


    <div class="customer-footer-inner">


        <div>

            © 2026 CineRent
            • Movie Rental & Review Platform

        </div>


        <div>

            Rent • Watch • Return • Review

        </div>


    </div>


</footer>


<script
        src="<%= ctx %>/js/app.js"
        defer
></script>


</body>

</html>