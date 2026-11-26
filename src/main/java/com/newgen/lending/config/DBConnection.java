package com.newgen.lending.config;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.io.InputStream;
import java.io.IOException;

public class DBConnection {

    private static final Properties properties =
            new Properties();

    static {
        try (InputStream input =
                DBConnection.class.getClassLoader()
                .getResourceAsStream("db.properties")) {

            if (input == null) {
                throw new RuntimeException(
                    "db.properties file not found"
                );
            }

            properties.load(input);

        } catch (IOException e) {
            throw new RuntimeException(
                "Unable to load DB configuration", e
            );
        }
    }

    public static Connection getConnection()
            throws SQLException {

        return DriverManager.getConnection(
            properties.getProperty("db.url"),
            properties.getProperty("db.username"),
            properties.getProperty("db.password")
        );
    }
}
