package com.avcoe.backup;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;


public class RegisterServlet extends HttpServlet {
    private final String jdbcURL = "jdbc:mysql://mysql-2e1563aa-snehalsonawane984-3647.d.aivencloud.com:27386/defaultdb?sslMode=REQUIRED";
    private final String jdbcUsername = System.getenv("DB_USER");
    private final String jdbcPassword = System.getenv("DB_PASS");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password"); // In production: hash this
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");

        Connection con = null;
        PreparedStatement psCheck = null;
        PreparedStatement psInsert = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

            // Check if username or email already exists
            psCheck = con.prepareStatement("SELECT * FROM users WHERE username = ? OR email = ?");
            psCheck.setString(1, username);
            psCheck.setString(2, email);
            rs = psCheck.executeQuery();

            if (rs.next()) {
                request.setAttribute("msg", "error");
                request.setAttribute("errorDetail", "Username or Email already exists!");
                request.getRequestDispatcher("register.jsp").forward(request, response);
                return;
            }

            // Insert new user
            psInsert = con.prepareStatement(
                    "INSERT INTO users (username, password, full_name, email, phone) VALUES (?, ?, ?, ?, ?)"
            );
            psInsert.setString(1, username);
            psInsert.setString(2, password); // In production: hash using BCrypt
            psInsert.setString(3, fullName);
            psInsert.setString(4, email);
            psInsert.setString(5, phone);

            int row = psInsert.executeUpdate();
            if (row > 0) {
                // ✅ Optional: set username in session immediately after registration
                HttpSession session = request.getSession();
                session.setAttribute("username", username);

                request.setAttribute("msg", "registered");
                request.getRequestDispatcher("index.jsp").forward(request, response);
            } else {
                request.setAttribute("msg", "error");
                request.setAttribute("errorDetail", "Something went wrong! Try again.");
                request.getRequestDispatcher("register.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("msg", "error");
            request.setAttribute("errorDetail", "Database error: " + e.getMessage());
            request.getRequestDispatcher("register.jsp").forward(request, response);

        } finally {
            try { if(rs != null) rs.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if(psCheck != null) psCheck.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if(psInsert != null) psInsert.close(); } catch (Exception e) { e.printStackTrace(); }
            try { if(con != null) con.close(); } catch (Exception e) { e.printStackTrace(); }
        }
    }
} 