package com.avcoe.backup;

import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class HomeServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;

        if (username == null) {
            response.sendRedirect("index.jsp?msg=loginRequired");
            return;
        }

        try {
            BasicAWSCredentials creds = new BasicAWSCredentials(
                    "AWS_ACCESS_KEY_ID",
                    "AWS_SECRET_ACCESS_KEY"
            );

            AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(creds))
                    .withRegion("ap-south-1")
                    .build();

            // Fetch files from main bucket
            List<String> files = new ArrayList<>();
            ObjectListing objects = s3.listObjects("main-backup-system123");

            for (S3ObjectSummary obj : objects.getObjectSummaries()) {
                // ✅ Only include files for the logged-in user
                if (obj.getKey().startsWith(username + "/")) {
                    // Strip username prefix for display
                    files.add(obj.getKey().substring((username + "/").length()));
                }
            }

            // Pass user-specific files to JSP
            request.setAttribute("mainFiles", files);

            // Decide which page to forward
            String page = request.getParameter("page"); // e.g., /home?page=delete
            if ("delete".equalsIgnoreCase(page)) {
                request.getRequestDispatcher("delete.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("home.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
} 