
<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>

<%@ page import="java.util.Map" %>
<%@ page import="com.movierental.util.HtmlUtil" %>

<%
    Map<String, String> fields =
            (Map<String, String>)
                    request.getAttribute("payhereFields");

    String gatewayUrl =
            (String) request.getAttribute(
                    "payhereCheckoutUrl"
            );

    if (fields == null || gatewayUrl == null) {
        response.sendError(
                500,
                "Payment gateway form unavailable"
        );
        return;
    }

    response.setHeader(
            "Cache-Control",
            "no-store"
    );
%>

<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">

    <meta name="viewport"
          content="width=device-width, initial-scale=1">

    <title>Connecting to PayHere | CineRent</title>

    <style>
        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            background: #0b1020;
            color: #f8fafc;
            font-family: Arial, sans-serif;
        }

        .box {
            width: min(480px, 90vw);
            text-align: center;
            background: #151e32;
            padding: 36px;
            border: 1px solid #3b345b;
            border-radius: 20px;
        }

        button {
            background: #7c3aed;
            color: white;
            padding: 14px 25px;
            border: 0;
            border-radius: 10px;
            cursor: pointer;
            font-weight: 700;
        }

        p {
            color: #b8c2d6;
            line-height: 1.7;
        }
    </style>
</head>

<body>

<main class="box">

    <h1>Secure PayHere Checkout</h1>

    <p>
        You are being redirected to PayHere
        to complete your payment.
        Never enter card details on CineRent.
    </p>

    <form id="payhereForm"
          method="post"
          action="<%= HtmlUtil.escape(gatewayUrl) %>">

        <% for (Map.Entry<String, String> field
                : fields.entrySet()) { %>

        <input type="hidden"
               name="<%= HtmlUtil.escape(field.getKey()) %>"
               value="<%= HtmlUtil.escape(field.getValue()) %>">

        <% } %>

        <button type="submit">
            Continue to PayHere
        </button>

    </form>

    <noscript>
        <p>
            JavaScript is disabled.
            Click Continue to PayHere.
        </p>
    </noscript>

</main>

<script>
    document.getElementById(
        'payhereForm'
    ).submit();
</script>

</body>
</html>
