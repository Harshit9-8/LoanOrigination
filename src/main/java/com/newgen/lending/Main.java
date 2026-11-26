package com.newgen.lending;

import java.sql.Connection;

import com.newgen.lending.config.DBConnection;

public class Main {

    public static void main(String[] args) {

        try (Connection con =
                DBConnection.getConnection()) {

            if (con != null && !con.isClosed()) {

                System.out.println(
                    "================================"
                );

                System.out.println(
                    "Mini Loan Origination Application"
                );

                System.out.println(
                    "Database Connected Successfully!"
                );

                System.out.println(
                    "Database: " +
                    con.getCatalog()
                );

                System.out.println(
                    "================================"
                );
            }

        } catch (Exception e) {

            System.out.println(
                "Database Connection Failed!"
            );

            e.printStackTrace();
        }
    }
}
