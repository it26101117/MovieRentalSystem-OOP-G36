package com.movierental.service;

import com.movierental.model.Admin;
import com.movierental.model.Customer;
import com.movierental.model.User;
import com.movierental.util.FileHandler;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class UserService {
    private final String userFilePath;
    public UserService(String userFilePath) {
        this.userFilePath = userFilePath;
    }


    // register customer

    public boolean registerCustomer(Customer customer) throws IOException {

        // Prevent duplicate email addresses
        if (emailExists(customer.getEmail())) {
            return false;
        }

        String line =convertCustomerToLine(customer);

        FileHandler.appendLine(userFilePath,line);
        return true;
    }


    // login

    public User login(String email,String password) throws IOException {
        List<User> users =getAllUsers();

        for (User user : users) {

            boolean emailMatches =user.getEmail().equalsIgnoreCase(email);

            boolean passwordMatches =user.getPassword().equals(password);

            if (emailMatches && passwordMatches) {
                return user;
            }
        }
        return null;
    }


    // read all users

    public List<User> getAllUsers()
            throws IOException {

        List<String> lines =FileHandler.readAllLines(userFilePath);

        List<User> users =new ArrayList<>();
        for (String line : lines) {

            if (line == null || line.trim().isEmpty()) {
                continue;
            }

            User user =convertLineToUser(line);
            if (user != null) {
                users.add(user);
            }
        }
        return users;
    }

    // check mails
    public boolean emailExists(String email) throws IOException {

        List<User> users =getAllUsers();
        for (User user : users) {
            if (user.getEmail().equalsIgnoreCase(email)) {
                return true;
            }
        }
        return false;
    }


    //get user ID
    public User getUserById(String userId) throws IOException {

        List<User> users =getAllUsers();
        for (User user : users) {
            if (user.getUserId().equals(userId)) {
                return user;
            }
        }
        return null;
    }


    // generate customer ID
    public String generateNextUserId()
            throws IOException {

        List<User> users =getAllUsers();
        int highestNumber = 0;

        for (User user : users) {
            String id =user.getUserId();
            if (id != null && id.startsWith("U")) {

                try {

                    int number =Integer.parseInt(id.substring(1));
                    if (number > highestNumber) {
                        highestNumber = number;
                    }

                } catch (NumberFormatException ignored) {

                    // Ignore invalid IDs
                }
            }
        }


        return String.format("U%03d",highestNumber + 1);
    }


    private String convertCustomerToLine(Customer customer) {

        return clean(customer.getUserId())+ "|"+ clean(customer.getName())+ "|"+ clean(customer.getEmail())+ "|"+ clean(customer.getPassword())+ "|"+ clean(customer.getPhoneNumber())+ "|"+ customer.getRole();
    }


    private User convertLineToUser(String line) {

        try {

            String[] data =line.split("\\|",-1);
            if (data.length != 6) {

                return null;
            }


            String userId =data[0];

            String name =data[1];

            String email =data[2];

            String password =data[3];

            String extraField =data[4];

            String role =data[5];



            if ("CUSTOMER".equalsIgnoreCase(role)) {

                return new Customer(userId,name,email,password,extraField);
            }

            if ("ADMIN".equalsIgnoreCase(role)) {

                return new Admin(userId,name,email,password,extraField);
            }


        } catch (Exception e) {

            System.out.println("Error reading user line: "+ line);

            return null;
        }

        return null;
    }

    private String clean(String value) {

        if (value == null) {

            return "";
        }
        return value.replace("|"," ");
    }
}