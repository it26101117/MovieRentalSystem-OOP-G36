package com.movierental.model;

public class Admin extends User {
    private String adminLevel;

    public Admin() {
        super();
    }
    public Admin(String userId,String name,String email,String password, String adminLevel){
        super(userId,name,email, password );
        this.adminLevel = adminLevel;
    }
    public String getAdminLevel() {
        return adminLevel;
    }
    public void setAdminLevel(String adminLevel){
        this.adminLevel = adminLevel;
    }
    @Override
    public String getRole() {
        return "ADMIN";
    }
}