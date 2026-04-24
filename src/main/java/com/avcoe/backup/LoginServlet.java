package com.avcoe.backup;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;


public class LoginServlet extends HttpServlet {

    private final String jdbcURL = "jdbc:mysql://localhost:3306/s3backupdb";
    private final String jdbcUsername = "root";
    private final String jdbcPassword = "root";

    // 🔹 Handle GET request
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to login page
        response.sendRedirect("index.jsp");
    }

    // 🔹 Handle POST (login logic)
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

            String sql = "SELECT * FROM users WHERE username=? AND password=?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // ✅ Login successful
                HttpSession session = request.getSession();
                session.setAttribute("username", username);
                session.setAttribute("fullName", rs.getString("full_name"));

                // Send msg parameter to trigger toast in home.jsp
                response.sendRedirect("home.jsp?msg=loginSuccess");
            } else {
                // Invalid login
                response.sendRedirect("index.jsp?msg=invalid");
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?msg=error");
        }
    }
} 