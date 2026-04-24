<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page session="true" %>
<%
    // Get logged-in username
    String username = (String) session.getAttribute("username");
    if(username == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // Check if login success parameter is passed
    String msg = request.getParameter("msg"); // e.g., "loginSuccess"
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Dashboard - AWS S3 Backup System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

<style>
/* Keep all your original CSS unchanged */
body {
    background: linear-gradient(135deg, #eef2f7, #d9e4f5);
    font-family: 'Segoe UI', sans-serif;
    display: flex;
    flex-direction: column;
    min-height: 100vh;
}

.content { flex: 1; }

/* Navbar */
.navbar { background: linear-gradient(90deg, #007bff, #0056b3); }

/* Heading Animation */
.welcome-text {
    font-weight: 600;
    margin-bottom: 30px;
    color: #333;
    animation: fadeDown 0.8s ease;
}

/* Cards */
.card-hover {
    border-radius: 18px;
    overflow: hidden;
    transition: all 0.4s ease;
    cursor: pointer;
    border: none;
    animation: fadeUp 0.8s ease;
}

.card-hover:hover {
    transform: translateY(-12px) scale(1.03);
    box-shadow: 0 20px 40px rgba(0,0,0,0.25);
}

/* Card Header */
.card-header { text-align: center; color: white; font-size: 1.1rem; font-weight: 600; padding: 15px; }

/* Card Body */
.card-body {
    min-height: 140px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
}

/* Icons */
.icon-circle {
    width: 65px;
    height: 65px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.6rem;
    color: white;
    margin-bottom: 12px;
    transition: 0.4s;
}

.card-hover:hover .icon-circle { transform: rotate(10deg) scale(1.1); }

/* Card Colors */
.upload { background: linear-gradient(135deg, #0d6efd, #0a58ca); }
.delete { background: linear-gradient(135deg, #dc3545, #a71d2a); }
.view { background: linear-gradient(135deg, #198754, #146c43); }
.backup { background: linear-gradient(135deg, #fd7e14, #ca6510); }

.upload-icon { background: #0d6efd; }
.delete-icon { background: #dc3545; }
.view-icon { background: #198754; }
.backup-icon { background: #fd7e14; }

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
@keyframes fadeUp { from { opacity: 0; transform: translateY(40px); } to { opacity: 1; transform: translateY(0); } }
@keyframes fadeDown { from { opacity: 0; transform: translateY(-30px); } to { opacity: 1; transform: translateY(0); } }

/* Delay animation for cards */
.card-hover:nth-child(1) { animation-delay: 0.2s; }
.card-hover:nth-child(2) { animation-delay: 0.4s; }
.card-hover:nth-child(3) { animation-delay: 0.6s; }
.card-hover:nth-child(4) { animation-delay: 0.8s; }

/* ✅ MOBILE RESPONSIVE ADDITION */
@media (max-width: 768px) {
    .welcome-text { font-size: 1.2rem; }
    .card-body { min-height: auto; padding: 15px; }
    .icon-circle { width: 55px; height: 55px; font-size: 1.3rem; }
    .card-header { font-size: 1rem; padding: 10px; }
    .card-body p { font-size: 0.85rem; text-align: center; }
    .navbar-brand { font-size: 0.9rem; }
}

@media (max-width: 480px) {
    .welcome-text { font-size: 1rem; }
    .card-body p { font-size: 0.8rem; }
}
</style>
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
                <li class="nav-item"><a class="nav-link active" href="home">Home</a></li>
                <li class="nav-item"><a class="nav-link " href="upload">Upload</a></li>
                <li class="nav-item"><a class="nav-link" href="deletePage">Delete</a></li>
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

<!-- Content -->
<div class="content">
<div class="container mt-4">
<h3 class="text-center welcome-text">👋 Welcome, <%= username %></h3>

<div class="row g-4">
    <!-- Upload Card -->
    <div class="col-12 col-md-6 col-lg-3">
        <div class="card card-hover" onclick="window.location='upload?user=<%= username %>'">
            <div class="card-header upload">Upload File</div>
            <div class="card-body">
                <div class="icon-circle upload-icon"><i class="bi bi-upload"></i></div>
                <p>Upload files securely to AWS S3.</p>
            </div>
        </div>
    </div>

    <!-- Delete Card -->
    <div class="col-12 col-md-6 col-lg-3">
        <div class="card card-hover" onclick="window.location='deletePage?user=<%= username %>'">
            <div class="card-header delete">Delete File</div>
            <div class="card-body">
                <div class="icon-circle delete-icon"><i class="bi bi-trash"></i></div>
                <p>Delete files from main bucket safely.</p>
            </div>
        </div>
    </div>

    <!-- View Files Card -->
    <div class="col-12 col-md-6 col-lg-3">
        <div class="card card-hover" onclick="window.location='listFiles?user=<%= username %>'">
            <div class="card-header view">View Files</div>
            <div class="card-body">
                <div class="icon-circle view-icon"><i class="bi bi-folder2-open"></i></div>
                <p>View all files in main bucket.</p>
            </div>
        </div>
    </div>

    <!-- Backup Files Card -->
    <div class="col-12 col-md-6 col-lg-3">
        <div class="card card-hover" onclick="window.location='listBackup?user=<%= username %>'">
            <div class="card-header backup">Backup Files</div>
            <div class="card-body">
                <div class="icon-circle backup-icon"><i class="bi bi-arrow-repeat"></i></div>
                <p>Access backup files easily.</p>
            </div>
        </div>
    </div>
</div>
</div>
</div>

<!-- LOGIN SUCCESS TOAST -->
<div class="position-fixed top-0 end-0 p-3" style="z-index: 1055;">
    <div id="loginToast" class="toast text-bg-success">
        <div class="toast-body">
            ✅ Login Successful! Welcome, <strong><%= username %></strong>.
        </div>
    </div>
</div>

<!-- Footer -->
<footer>© 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
<% if("loginSuccess".equals(msg)) { %>
    window.addEventListener('DOMContentLoaded', () => {
        new bootstrap.Toast(document.getElementById('loginToast'), { delay: 3000 }).show();
    });
<% } %>
</script>
</body>
</html>