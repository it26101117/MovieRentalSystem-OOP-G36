package com.movierental.model;

public class Customer extends User {
    private String phoneNumber;

    public Customer() {
        super();
    }
    public Customer(String userId,String name, String email,String password,String phoneNumber) {
        super(userId, name, email, password);
        this.phoneNumber = phoneNumber;
    }
    public String getPhoneNumber() {
        return phoneNumber;
    }
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    @Override
    public String getRole() {
        return "CUSTOMER";
    }
}

