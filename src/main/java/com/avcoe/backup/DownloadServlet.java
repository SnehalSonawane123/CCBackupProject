package com.avcoe.backup;

import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;
import com.amazonaws.services.s3.model.AmazonS3Exception;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;

public class DownloadServlet extends HttpServlet {

    private static final String ACCESS_KEY = "AWS_ACCESS_KEY_ID";
    private static final String SECRET_KEY = "AWS_SECRET_ACCESS_KEY";
    private static final String BUCKET_NAME = "main-backup-system123";
    private static final String REGION = "ap-south-1";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        String username = (String) session.getAttribute("username");
        String fileName = request.getParameter("fileName");

        if (fileName == null || fileName.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "File name is missing");
            return;
        }

        // Prepend username to get the correct S3 key
        String userFileName = username + "/" + fileName;

        BasicAWSCredentials creds = new BasicAWSCredentials(ACCESS_KEY, SECRET_KEY);
        AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(creds))
                .withRegion(REGION)
                .build();

        try (S3Object object = s3.getObject(BUCKET_NAME, userFileName);
             S3ObjectInputStream inputStream = object.getObjectContent()) {

            // Set headers for download
            response.setContentType("application/octet-stream");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
            response.setHeader("Content-Length", String.valueOf(object.getObjectMetadata().getContentLength()));

            OutputStream out = response.getOutputStream();
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = inputStream.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();

            // ✅ After sending the file, send a small JS snippet to show toast
            // This works if the download is opened in a new tab/window
            // Otherwise, JS cannot detect native download completion
            // Alternative: Use your existing 'download toast' in list.jsp when button is clicked

        } catch (AmazonS3Exception e) {
            e.printStackTrace();
            response.sendRedirect("list.jsp?msg=error&file=" + java.net.URLEncoder.encode(fileName, "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("list.jsp?msg=error&file=" + java.net.URLEncoder.encode(fileName, "UTF-8"));
        }
    }
} 