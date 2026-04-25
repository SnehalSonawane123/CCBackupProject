package com.avcoe.backup;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import com.amazonaws.services.s3.model.ObjectListing;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
public class DeletePageServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");
        try {
            BasicAWSCredentials creds = new BasicAWSCredentials(
                    System.getenv("AWS_ACCESS_KEY_ID"),
                    System.getenv("AWS_SECRET_ACCESS_KEY")
            );
            AmazonS3 s3 = AmazonS3ClientBuilder.standard()
                    .withCredentials(new AWSStaticCredentialsProvider(creds))
                    .withRegion("ap-south-1")
                    .build();
            List<String> files = new ArrayList<>();
            ObjectListing objects = s3.listObjects("main-backup-system123");
            for (S3ObjectSummary obj : objects.getObjectSummaries()) {
                String key = obj.getKey();
                if (key.startsWith(username + "/")) {
                    files.add(key.substring(username.length() + 1));
                }
            }
            request.setAttribute("mainFiles", files);
            request.getRequestDispatcher("delete.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("error.jsp");
        }
    }
}