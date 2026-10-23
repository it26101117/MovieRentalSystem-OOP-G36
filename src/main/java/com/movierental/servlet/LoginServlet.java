package com.movierental.servlet;

import com.movierental.model.User;
import com.movierental.service.UserService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserService userService;

    @Override
    public void init() throws ServletException {

        try {

            String filePath =DataPathUtil.getFilePath("users.txt");
            userService =new UserService(filePath);

            System.out.println("LoginServlet users file: " + filePath);

        } catch (Exception e) {
            throw new ServletException("Failed to initialize LoginServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // If fully logging, redirect based on role
        if (session != null && session.getAttribute("loggedUser") != null) {
            String role = (String) session.getAttribute("role");

            if ("ADMIN".equalsIgnoreCase(role)) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/catalog");
            }
            return;
        }


        // Show login page
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request,response);
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String email = request.getParameter("email");

        String password = request.getParameter("password");

        User user = userService.login(email, password);



        if (user == null) {

            request.setAttribute("error", "Invalid email or password.");

            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request,response);

            return;
        }

        // Create session
        HttpSession session = request.getSession(true);

        session.setAttribute("loggedUser", user);

        session.setAttribute("userId", user.getUserId());

        session.setAttribute("userName", user.getName());

        session.setAttribute("role", user.getRole());


        // Admin
        if ("ADMIN".equalsIgnoreCase(user.getRole())) {
            response.sendRedirect(request.getContextPath() + "/admin");

            return;
        }

        // Customer
        response.sendRedirect(request.getContextPath()+ "/catalog");
    }
}