package com.avcoe.backup;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.*;
import java.net.URLEncoder;
public class RestoreServlet extends HttpServlet {
    private static final String BACKUP_BUCKET = "backup-storage-system123";
    private static final String MAIN_BUCKET = "main-backup-system123";
    private static final String REGION = "ap-south-1";
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;
        String fileName = request.getParameter("fileName");
        if (fileName == null || fileName.isEmpty() || username == null) {
            response.sendRedirect("listBackup");
            return;
        }
        try {
            BasicAWSCredentials creds = new BasicAWSCredentials(
                    System.getenv("AWS_ACCESS_KEY_ID"),
                    System.getenv("AWS_SECRET_ACCESS_KEY")
            );
            AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(creds))
                    .withRegion(REGION)
                    .build();
            String userFileName = username + "/" + fileName;
            s3.copyObject(BACKUP_BUCKET, userFileName, MAIN_BUCKET, userFileName);
            response.sendRedirect("listBackup?msg=success&file=" + URLEncoder.encode(fileName, "UTF-8"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("listBackup?msg=error&file=" + URLEncoder.encode(fileName, "UTF-8"));
        }
    }
}