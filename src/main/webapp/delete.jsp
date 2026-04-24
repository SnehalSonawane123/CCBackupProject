<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if(username == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    List<String> userFiles = (List<String>) request.getAttribute("mainFiles");
    if(userFiles == null) {
        userFiles = new ArrayList<>();
    }

    String msg = request.getParameter("msg");
    String deletedFile = request.getParameter("file");
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0"> <!-- ✅ Mobile fix -->
<title>Delete File - AWS S3</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

<style>
body {
    background: linear-gradient(135deg, #eef2f7, #d9e4f5);
    font-family: 'Segoe UI', sans-serif;
}

.page-wrapper {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
}

.content {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.navbar {
    background: linear-gradient(90deg, #007bff, #0056b3);
}

h2 {
    font-weight: 600;
    margin-top: 25px;
    animation: fadeDown 0.7s ease;
}

/* ✅ Responsive center box */
.center-box {
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 20px;
}

/* ✅ Card responsive */
.delete-card {
    width: 100%;
    max-width: 420px;
    padding: 35px 25px;
    border-radius: 20px;
    background: white;
    box-shadow: 0 15px 40px rgba(0,0,0,0.1);
    transition: 0.3s;
    animation: fadeUp 0.8s ease;
}

.delete-card:hover {
    transform: translateY(-6px);
}

/* Icon */
.icon-circle {
    width: 70px;
    height: 70px;
    margin: 0 auto 20px;
    border-radius: 50%;
    background: linear-gradient(135deg, #dc3545, #a71d2a);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 28px;
    transition: 0.3s;
}

.icon-circle:hover {
    transform: scale(1.1);
}

/* Inputs */
.form-control, .form-select {
    border-radius: 10px;
    padding: 10px;
}

/* Buttons */
.btn-danger {
    border-radius: 10px;
    padding: 10px;
    transition: 0.3s;
}

.btn-danger:hover {
    transform: translateY(-2px);
}

.btn-outline-secondary {
    border-radius: 10px;
    padding: 10px;
}

/* Loader */
#loader {
    display: none;
    margin-top: 15px;
}

/* Footer */
footer {
    margin-top: auto;
    padding: 10px;
    text-align: center;
    color: #555;
    background: #fff;
    box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
}

/* Animations */
@keyframes fadeUp {
    from {opacity: 0; transform: translateY(30px);}
    to {opacity: 1; transform: translateY(0);}
}

@keyframes fadeDown {
    from {opacity: 0; transform: translateY(-20px);}
    to {opacity: 1; transform: translateY(0);}
}

/* ✅ Mobile adjustments */
@media (max-width: 576px) {
    .delete-card {
        padding: 25px 15px;
    }
}
</style>
</head>

<body>
<div class="page-wrapper">


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
                <li class="nav-item"><a class="nav-link active" href="deletePage">Delete</a></li>
                <li class="nav-item"><a class="nav-link" href="listFiles">Files</a></li>
                <li class="nav-item"><a class="nav-link" href="listBackup">Backup</a></li>

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

<div class="content">
<h2 class="text-center mb-4">🗑️ Delete Files</h2>

<div class="center-box">
<div class="delete-card text-center">

<div class="icon-circle"><i class="bi bi-trash"></i></div>
<h4 class="mb-4">Delete File</h4>

<input type="text" class="form-control mb-3" placeholder="🔍 Search file..." onkeyup="filterFiles(this.value)">

<form id="deleteForm" action="delete" method="post">

<select name="fileName" id="fileName" class="form-select mb-3" required>
<option value="">-- Select File --</option>

<%
if(userFiles != null && !userFiles.isEmpty()) {
    for(String f : userFiles){
        if(f != null && !f.trim().isEmpty()) {
%>
<option value="<%= f %>"><%= f %></option>
<%
        }
    }
} else {
%>
<option disabled>No files available</option>
<%
}
%>

</select>

<button type="button" class="btn btn-danger w-100" onclick="openModal()">
<i class="bi bi-trash"></i> Delete File
</button>

</form>

<div id="loader">
    <div class="spinner-border text-danger mt-3"></div>
    <p class="mt-2">Deleting...</p>
</div>

<a href="home" class="btn btn-outline-secondary w-100 mt-3">
    <i class="bi bi-arrow-left"></i> Back
</a>

</div>
</div>
</div>

<!-- Modal -->
<div class="modal fade" id="confirmModal">
<div class="modal-dialog">
<div class="modal-content">

<div class="modal-header bg-danger text-white">
<h5 class="modal-title">Confirm Delete</h5>
<button class="btn-close" data-bs-dismiss="modal"></button>
</div>

<div class="modal-body">
Are you sure you want to delete:
<strong id="selectedFile"></strong> ?
</div>

<div class="modal-footer">
<button class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
<button class="btn btn-danger" onclick="deleteNow()">Delete</button>
</div>

</div>
</div>
</div>

<!-- Toast -->
<div id="toastContainer" style="position: fixed; top: 20px; left: 50%; transform: translateX(-50%); z-index: 1100;">
  <div id="toastMsg" class="toast align-items-center text-white bg-success border-0">
    <div class="d-flex">
      <div class="toast-body">✅ File deleted successfully!</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  </div>
</div>

<footer>© 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group</footer>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
function filterFiles(text){
    let options = document.querySelectorAll("#fileName option");
    options.forEach(opt => {
        opt.style.display = opt.text.toLowerCase().includes(text.toLowerCase()) ? "" : "none";
    });
}

function openModal(){
    let file = document.getElementById("fileName").value;
    if(file === ""){
        alert("Select a file!");
        return;
    }
    document.getElementById("selectedFile").innerText = file;
    new bootstrap.Modal(document.getElementById('confirmModal')).show();
}

function deleteNow(){
    document.getElementById("loader").style.display = "block";
    document.getElementById("deleteForm").submit();
}

<% if("deleted".equals(msg)) { %>
window.addEventListener('DOMContentLoaded', () => {
    const toastEl = document.getElementById('toastMsg');
    const toast = new bootstrap.Toast(toastEl, { delay: 3000 });
    <% if(deletedFile != null) { %>
        toastEl.querySelector('.toast-body').innerText = "✅ '<%= deletedFile %>' deleted successfully!";
    <% } %>
    toast.show();
});
<% } %>
</script>

</body>
</html>