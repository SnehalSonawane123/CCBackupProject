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
                if (obj.getKey().startsWith(username + "/")) {
                    files.add(obj.getKey().substring((username + "/").length()));
                }
            }
            request.setAttribute("mainFiles", files);
            String page = request.getParameter("page");
            if ("delete".equalsIgnoreCase(page)) {
                request.getRequestDispatcher("delete.jsp").forward(request, response);
            } else {
                request.getRequestDispatcher("home.jsp").forward(request, response);
            }
       	    } catch (Exception e) {
    		e.printStackTrace();
    		response.setContentType("text/plain");
    		response.getWriter().println("ERROR: " + e.getClass().getName() + ": " + e.getMessage());
    		// temporarily comment out the error.jsp redirect
    		// response.sendRedirect("error.jsp");
	}
    }
}