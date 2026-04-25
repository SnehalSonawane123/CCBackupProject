package com.avcoe.backup;

import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.ObjectMetadata;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.*;
import java.io.*;
import java.util.Collection;

@MultipartConfig
public class UploadServlet extends HttpServlet {

    private static final String REGION = "ap-south-1";
    private static final String MAIN_BUCKET = "main-backup-system123";
    private static final String BACKUP_BUCKET = "backup-storage-system123";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("upload.jsp").forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : "guest";

        BasicAWSCredentials creds = new BasicAWSCredentials(
                System.getenv("AWS_ACCESS_KEY_ID"),
                System.getenv("AWS_SECRET_ACCESS_KEY")
        );

        AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(creds))
                .withRegion(REGION)
                .build();

        try {
            Collection<Part> parts = request.getParts();

            for (Part part : parts) {
                if (part.getName().equals("file") && part.getSize() > 0) {
                    String fileName = part.getSubmittedFileName();
                    String userFileKey = username + "/" + fileName;

                    InputStream inputStream = part.getInputStream();
                    ObjectMetadata metadata = new ObjectMetadata();
                    metadata.setContentLength(part.getSize());
                    metadata.setContentType(part.getContentType());

                    s3.putObject(MAIN_BUCKET, userFileKey, inputStream, metadata);
                    s3.copyObject(MAIN_BUCKET, userFileKey, BACKUP_BUCKET, userFileKey);
                }
            }

            response.sendRedirect("success.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}