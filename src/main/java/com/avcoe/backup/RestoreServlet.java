package com.avcoe.backup;

import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;


public class RestoreServlet extends HttpServlet {

    // AWS Credentials and Buckets
    private static final String ACCESS_KEY = "AWS_ACCESS_KEY_ID";
    private static final String SECRET_KEY = "AWS_SECRET_ACCESS_KEY";
    private static final String BACKUP_BUCKET = "backup-storage-system123";
    private static final String MAIN_BUCKET = "main-backup-system123";
    private static final String REGION = "ap-south-1";

    // Local temp folder
    private static final String LOCAL_TEMP_PATH = "C:\\temp\\";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get logged-in username from session
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;

        String fileName = request.getParameter("fileName");
        if(fileName == null || fileName.isEmpty() || username == null) {
            response.sendRedirect("listBackup");
            return;
        }

        try {
            BasicAWSCredentials creds = new BasicAWSCredentials(ACCESS_KEY, SECRET_KEY);

            AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(creds))
                    .withRegion(REGION)
                    .build();

            // ✅ Use username prefix for per-user files
            String userFileName = username + "/" + fileName;

            // 1️⃣ Restore to main bucket (user-specific folder)
            s3.copyObject(BACKUP_BUCKET, userFileName,
                          MAIN_BUCKET, userFileName);

            // 2️⃣ Download to local folder (keep original file name)
            S3Object obj = s3.getObject(BACKUP_BUCKET, userFileName);
            InputStream in = obj.getObjectContent();

            File localFile = new File(LOCAL_TEMP_PATH + fileName);
            try (FileOutputStream out = new FileOutputStream(localFile)) {
                byte[] buffer = new byte[1024];
                int length;
                while ((length = in.read(buffer)) > 0) {
                    out.write(buffer, 0, length);
                }
            }
            in.close();

            // 3️⃣ Redirect with success message
            response.sendRedirect("listBackup?msg=success&file=" + URLEncoder.encode(fileName, "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listBackup?msg=error&file=" + URLEncoder.encode(fileName, "UTF-8"));
        }
    }
} 