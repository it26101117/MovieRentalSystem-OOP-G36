package com.movierental.servlet;

import com.movierental.model.Customer;
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
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin/customers")
public class AdminCustomerServlet extends HttpServlet {

    private UserService userService;

    @Override
    public void init() throws ServletException {

        try {

            String userFilePath = DataPathUtil.getFilePath("users.txt");

            userService = new UserService(userFilePath);

            System.out.println("AdminCustomerServlet users file: " + userFilePath);

        } catch (Exception e) {

            throw new ServletException("Failed to initialize AdminCustomerServlet", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = (String) session.getAttribute("role");

        if (role == null || !"ADMIN".equalsIgnoreCase(role)) {

            response.sendRedirect(request.getContextPath() + "/catalog");

            return;
        }

        // get all users
        List<User> allUsers = userService.getAllUsers();

        // filter customer users
        List<Customer> customers = new ArrayList<>();


        for (User user : allUsers) {
            if (user instanceof Customer) {
                customers.add((Customer) user);
            }
        }


        String search = request.getParameter("search");

        if (search != null && !search.trim().isEmpty()) {

            String searchText = search.trim().toLowerCase();

            List<Customer> filteredCustomers = new ArrayList<>();

            for (Customer customer : customers) {

                boolean matchesId = customer.getUserId() != null && customer.getUserId().toLowerCase().contains(searchText);

                boolean matchesName = customer.getName() != null && customer.getName().toLowerCase().contains(searchText);

                boolean matchesEmail = customer.getEmail() != null && customer.getEmail().toLowerCase().contains(searchText);

                boolean matchesPhone = customer.getPhoneNumber() != null && customer.getPhoneNumber().toLowerCase().contains(searchText);

                if (matchesId || matchesName || matchesEmail || matchesPhone) {
                    filteredCustomers.add(customer);
                }
            }

            customers = filteredCustomers;
        }

        // sent data to jsp
        request.setAttribute("customers", customers);

        request.setAttribute("customerCount", customers.size() );
        request.setAttribute("search", search);

        request.getRequestDispatcher("/WEB-INF/views/admin-customers.jsp").forward(request, response);
    }
}