package com.movierental.servlet;

import com.movierental.model.Customer;
import com.movierental.service.UserService;
import com.movierental.util.DataPathUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserService userService;

    @Override
    public void init() throws ServletException {

        try {

            String filePath =DataPathUtil.getFilePath("users.txt");
            userService =new UserService(filePath);
            System.out.println("RegisterServlet users file: "+ filePath);

        } catch (Exception e) {
            throw new ServletException("Failed to initialize RegisterServlet",e);
        }
    }


    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request,response);
    }


    @Override
    protected void doPost(HttpServletRequest request,HttpServletResponse response) throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String name =request.getParameter("name");

        String email =request.getParameter("email");

        String password =request.getParameter("password");

        String phone =request.getParameter("phone");

        String userId =userService.generateNextUserId();

        Customer customer =new Customer(userId,name,email,password,phone);

        boolean registered =userService.registerCustomer(customer);

        if (!registered) {

            request.setAttribute("error","An account with this email already exists.");

            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request,response);

            return;
        }
        response.sendRedirect(request.getContextPath()+ "/login?registered=true");
    }
}