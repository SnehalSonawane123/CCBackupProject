<%@ page import="java.util.*" pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String username = (String) session.getAttribute("username");
    if(username == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    List<String> allFiles = (List<String>) request.getAttribute("files");
    List<String> userFiles = new ArrayList<>();

    if(allFiles != null){
        for(String f : allFiles){
            userFiles.add(f);
        }
    }

    String msg = request.getParameter("msg");
    String restoredFile = request.getParameter("file");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<!-- ✅ MOBILE FIX -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Backup Files - AWS S3 System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

<style>
body { background: linear-gradient(135deg, #eef2f7, #d9e4f5); font-family: 'Segoe UI', sans-serif; min-height: 100vh; display: flex; flex-direction: column;}
.navbar { background: linear-gradient(90deg, #007bff, #0056b3);}
h2 { font-weight: 600; animation: fadeInDown 0.8s ease;}
.search-box { margin-bottom: 15px; border-radius: 10px; padding: 10px; transition: 0.3s;}
.search-box:focus { border-color: #198754; box-shadow: 0 0 10px rgba(25,135,84,0.4);}
.table-card { border-radius: 15px; overflow: hidden; animation: fadeInUp 0.8s ease;}
.table thead { background: #343a40; color: white;}
.table-hover tbody tr { transition: 0.3s;}
.table-hover tbody tr:hover { background-color: #e9f3ff; transform: scale(1.01);}
.badge-file { background: linear-gradient(135deg, #0d6efd, #0a58ca); color: white; padding: 6px 12px; border-radius: 8px;}
.btn-restore { background: linear-gradient(135deg, #198754, #146c43); color: white; border-radius: 20px; padding: 5px 15px; transition: 0.3s;}
.btn-restore:hover { transform: scale(1.08); box-shadow: 0 5px 15px rgba(25,135,84,0.4);}
#toastContainer { position: fixed; top: 20px; left: 50%; transform: translateX(-50%); z-index: 1100;}
@keyframes fadeInDown { from { opacity: 0; transform: translateY(-20px);} to { opacity: 1; transform: translateY(0);}}
@keyframes fadeInUp { from { opacity: 0; transform: translateY(20px);} to { opacity: 1; transform: translateY(0);}}
footer { margin-top: auto; padding: 10px; text-align: center; color: #555; background: #fff; box-shadow: 0 -2px 10px rgba(0,0,0,0.1);}
</style>

<script>
function searchFiles() {
    let input = document.getElementById("search").value.toLowerCase();
    let rows = document.querySelectorAll("tbody tr");
    rows.forEach(row => { row.style.display = row.innerText.toLowerCase().includes(input) ? "" : "none"; });
}

function confirmRestore(fileName) {
    if(confirm("Restore file: " + fileName + " ?")) {
        window.location = "restore?fileName=" + encodeURIComponent(fileName);
    }
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
                <li class="nav-item"><a class="nav-link" href="listFiles">Files</a></li>
                <li class="nav-item"><a class="nav-link active" href="listBackup">Backup</a></li>

                <!-- 👤 Username -->
                <li class="nav-item">
                    <span class="nav-link text-warning fw-bold">
                        <i class="bi bi-person-circle"></i> <%= username %>
                    </span>
                </li>

                <!-- 🚪 Logout -->
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
<h2 class="text-center mb-4">🔄 Backup Files</h2>

<!-- ✅ MOBILE RESPONSIVE TABLE -->
<div class="table-card shadow bg-white p-4 table-responsive">

<input type="text" id="search" class="form-control search-box"
       placeholder="🔍 Search backup file..." onkeyup="searchFiles()">

<table class="table table-hover text-center align-middle">
<thead>
<tr>
<th>📄 File Name</th>
<th>🔄 Restore</th>
</tr>
</thead>

<tbody>
<%
if(userFiles != null && !userFiles.isEmpty()){
    for(String f : userFiles){
%>
<tr>
<td>
<span class="badge-file">
<i class="bi bi-file-earmark"></i> <%= f %>
</span>
</td>
<td>
<button class="btn btn-restore btn-sm px-3"
        onclick="confirmRestore('<%= f %>')">
    <i class="bi bi-arrow-clockwise"></i> Restore
</button>
</td>
</tr>
<%
    }
} else {
%>
<tr>
<td colspan="2" class="text-muted">No backup files available.</td>
</tr>
<%
}
%>
</tbody>
</table>
</div>

<div class="text-center mt-4">
<a href="home" class="btn btn-secondary btn-lg">
<i class="bi bi-arrow-left-circle"></i> Back
</a>
</div>
</div>

<div id="toastContainer">
  <div id="toastMsg" class="toast align-items-center text-white bg-success border-0">
    <div class="d-flex">
      <div class="toast-body">✅ File restored successfully!</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  </div>
</div>

<footer>
    © 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
<% if("success".equals(msg)) { %>
window.addEventListener('DOMContentLoaded', () => {
    const toastEl = document.getElementById('toastMsg');
    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
    <% if(restoredFile != null) { %>
        toastEl.querySelector('.toast-body').innerText = "✅ '<%= restoredFile %>' restored successfully!";
    <% } %>
    toast.show();
});
<% } %>
</script>

</body>
</html>