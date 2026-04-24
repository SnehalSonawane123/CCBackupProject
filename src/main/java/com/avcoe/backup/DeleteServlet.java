package com.avcoe.backup;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.ListObjectsV2Request;
import com.amazonaws.services.s3.model.ListObjectsV2Result;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
public class DeleteServlet extends HttpServlet {
    private static final String BUCKET_NAME = "main-backup-system123";
    private AmazonS3 getS3Client() {
        BasicAWSCredentials creds = new BasicAWSCredentials(
            System.getenv("AWS_ACCESS_KEY_ID"),
            System.getenv("AWS_SECRET_ACCESS_KEY")
        );
        return AmazonS3ClientBuilder.standard()
                .withCredentials(new AWSStaticCredentialsProvider(creds))
                .withRegion(System.getenv("AWS_REGION"))
                .build();
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");
        AmazonS3 s3 = getS3Client();
        ListObjectsV2Request req = new ListObjectsV2Request()
                .withBucketName(BUCKET_NAME)
                .withPrefix(username + "/");
        ListObjectsV2Result result = s3.listObjectsV2(req);
        List<String> userFiles = new ArrayList<>();
        for (S3ObjectSummary summary : result.getObjectSummaries()) {
            String fileName = summary.getKey().substring((username + "/").length());
            if (!fileName.isEmpty()) {
                userFiles.add(fileName);
            }
        }
        request.setAttribute("userFiles", userFiles);
        request.getRequestDispatcher("delete.jsp").forward(request, response);
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("index.jsp");
            return;
        }
        String username = (String) session.getAttribute("username");
        String fileName = request.getParameter("fileName");
        if (fileName == null || fileName.isEmpty()) {
            response.sendRedirect("delete?msg=error");
            return;
        }
        String userFileName = username + "/" + fileName;
        AmazonS3 s3 = getS3Client();
        try {
            if (s3.doesObjectExist(BUCKET_NAME, userFileName)) {
                s3.deleteObject(BUCKET_NAME, userFileName);
                response.sendRedirect("delete?msg=deleted&file=" + URLEncoder.encode(fileName, "UTF-8"));
            } else {
                response.sendRedirect("delete?msg=error&file=" + URLEncoder.encode(fileName, "UTF-8"));
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("delete?msg=error&file=" + URLEncoder.encode(fileName, "UTF-8"));
        }
    }
}
