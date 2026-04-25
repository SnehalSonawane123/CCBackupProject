package com.avcoe.backup;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.*;
import com.amazonaws.services.s3.model.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.servlet.*;
import java.io.IOException;
import java.util.*;
public class ListBackupServlet extends HttpServlet {
    private static final String BUCKET_NAME = "backup-storage-system123";
    private static final String REGION = "ap-south-1";
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
                    System.getenv("AWS_ACCESS_KEY_ID"),
                    System.getenv("AWS_SECRET_ACCESS_KEY")
            );
            AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(creds))
                    .withRegion(REGION)
                    .build();
            List<String> userFiles = new ArrayList<>();
            ObjectListing objects = s3.listObjects(BUCKET_NAME);
            while (true) {
                for (S3ObjectSummary obj : objects.getObjectSummaries()) {
                    if (obj.getKey().startsWith(username + "/")) {
                        userFiles.add(obj.getKey().substring((username + "/").length()));
                    }
                }
                if (objects.isTruncated()) {
                    objects = s3.listNextBatchOfObjects(objects);
                } else {
                    break;
                }
            }
            request.setAttribute("files", userFiles);
            RequestDispatcher rd = request.getRequestDispatcher("/backupList.jsp");
            rd.forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}