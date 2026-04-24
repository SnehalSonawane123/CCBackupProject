<%@ page import="java.util.*, com.amazonaws.auth.*, com.amazonaws.services.s3.*, com.amazonaws.services.s3.model.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page pageEncoding="UTF-8" %>
<%
    String ACCESS_KEY = System.getenv("AWS_ACCESS_KEY_ID");
    String SECRET_KEY = System.getenv("AWS_SECRET_ACCESS_KEY");
    String BUCKET_NAME = System.getenv("S3_BUCKET");
    String REGION = System.getenv("AWS_REGION");

    String username = (String) session.getAttribute("username");
    if(username == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    BasicAWSCredentials creds = new BasicAWSCredentials(ACCESS_KEY, SECRET_KEY);
    AmazonS3 s3 = AmazonS3ClientBuilder.standard()
            .withCredentials(new AWSStaticCredentialsProvider(creds))
            .withRegion(REGION)
            .build();

    List<S3ObjectSummary> summaries = s3.listObjectsV2(BUCKET_NAME).getObjectSummaries();
    List<String> files = new ArrayList<>();
    Map<String, String> fileSizes = new HashMap<>();
    Map<String, String> fileDates = new HashMap<>();

    for(S3ObjectSummary obj : summaries){
        String key = obj.getKey();
        if(!key.startsWith(username + "/")) continue;

        files.add(key);
        fileSizes.put(key, String.format("%.2f KB", obj.getSize()/1024.0));
        fileDates.put(key, new java.text.SimpleDateFormat("yyyy-MM-dd").format(obj.getLastModified()));
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Files - AWS S3 Backup System</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet"> 
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">
<style>
body {
    background: linear-gradient(135deg, #eef2f7, #d9e4f5);
    font-family: 'Segoe UI', sans-serif;
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}
.navbar {
    background: linear-gradient(90deg, #007bff, #0056b3);
}
h2 {
    font-weight: 600;
    animation: fadeInDown 0.8s ease;
}
.search-box {
    margin-bottom: 15px;
    border-radius: 10px;
    padding: 10px;
}
.table-container {
    background: white;
    border-radius: 15px;
    padding: 20px;
    animation: fadeInUp 0.8s ease;
    box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}
.table thead {
    background: #343a40;
    color: white;
}
.badge-file {
    background: linear-gradient(135deg, #0d6efd, #0a58ca);
    color: white;
    padding: 6px 12px;
    border-radius: 8px;
}
footer {
    margin-top: auto;
    padding: 10px;
    text-align: center;
    background: #fff;
}
@media (max-width: 768px) {
    h2 { font-size: 20px; }
    .table { font-size: 12px; }
    .btn { padding: 5px 8px; }
    .table-container { padding: 10px; }
}
@keyframes fadeInDown {
    from { opacity: 0; transform: translateY(-20px);}
    to { opacity: 1; transform: translateY(0);}
}
@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(20px);}
    to { opacity: 1; transform: translateY(0);}
}
</style>
<script>
function searchFiles() {
    let input = document.getElementById("search").value.toLowerCase();
    let rows = document.querySelectorAll("tbody tr");
    rows.forEach(row => {
        row.style.display = row.innerText.toLowerCase().includes(input) ? "" : "none";
    });
}
function downloadFile(fileName) {
    const shortName = fileName.substring(fileName.indexOf('/') + 1);
    fetch("download?fileName=" + encodeURIComponent(shortName))
    .then(response => {
        if (!response.ok) throw new Error("Download failed");
        return response.blob();
    })
    .then(blob => {
        const url = window.URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = shortName;
        document.body.appendChild(a);
        a.click();
        a.remove();
        showToast("✅ File '" + shortName + "' downloaded!", "success");
    })
    .catch(error => {
        showToast("❌ Download failed!", "danger");
    });
}
function showToast(msg, type) {
    const toastEl = document.getElementById("toast");
    const toastBody = document.getElementById("toastBody");
    toastEl.className = "toast align-items-center border-0";
    if(type === "success") toastEl.classList.add("text-bg-success");
    else toastEl.classList.add("text-bg-danger");
    toastBody.innerText = msg;
    new bootstrap.Toast(toastEl, { delay: 3000 }).show();
}
</script>
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark shadow">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">Backup & Recovery System using AWS S3</a>
        <button class="navbar-toggler" data-bs-toggle="collapse" data-bs-target="#nav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="nav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="home">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="upload">Upload</a></li>
                <li class="nav-item"><a class="nav-link" href="deletePage">Delete</a></li>
                <li class="nav-item"><a class="nav-link active" href="listFiles">Files</a></li>
                <li class="nav-item"><a class="nav-link" href="listBackup">Backup</a></li>
                <li class="nav-item">
                    <span class="nav-link text-warning fw-bold">
                        <i class="bi bi-person-circle"></i> <%= username %>
                    </span>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-danger" href="logout">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>
<div class="container mt-4" style="flex:1;">
<h2 class="text-center mb-4">📂 Current Files</h2>
<div class="table-container">
<input type="text" id="search" class="form-control search-box"
placeholder="🔍 Search file..." onkeyup="searchFiles()">
<div class="table-responsive">
<table class="table table-hover text-center align-middle">
<thead>
<tr>
<th>File</th>
<th>Size</th>
<th>Date</th>
<th>Download</th>
</tr>
</thead>
<tbody>
<%
if(files != null && !files.isEmpty()){
    for(String f : files){
        String displayName = f.substring(f.indexOf('/') + 1);
%>
<tr>
<td><span class="badge-file"><i class="bi bi-file-earmark"></i> <%= displayName %></span></td>
<td><%= fileSizes.get(f) %></td>
<td><%= fileDates.get(f) %></td>
<td>
<button class="btn btn-success btn-sm" onclick="downloadFile('<%= f %>')">
<i class="bi bi-download"></i>
</button>
</td>
</tr>
<%
    }
}else{
%>
<tr><td colspan="4" class="text-muted">No files available</td></tr>
<%
}
%>
</tbody>
</table>
</div>
</div>
<div class="text-center mt-4">
<a href="home.jsp" class="btn btn-secondary btn-lg">
<i class="bi bi-arrow-left-circle"></i> Back
</a>
</div>
</div>
<div class="position-fixed p-3" style="top:20px;left:50%;transform:translateX(-50%);z-index:1055;">
<div id="toast" class="toast">
<div class="d-flex">
<div class="toast-body" id="toastBody"></div>
<button class="btn-close" data-bs-dismiss="toast"></button>
</div>
</div>
</div>
<footer>
© 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>