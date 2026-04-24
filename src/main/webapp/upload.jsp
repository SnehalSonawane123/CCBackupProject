<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page session="true" %>
<%
    String username = (String) session.getAttribute("username");
    if(username == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<!-- ✅ IMPORTANT for mobile -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Upload Files - AWS S3</title>

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

/* Navbar */
.navbar {
    background: linear-gradient(90deg, #007bff, #0056b3);
}

/* Heading */
h2 {
    font-weight: 600;
    margin-top: 20px;
    animation: fadeDown 0.8s ease;
}

/* Center Layout */
.center-box {
    flex: 1;
    display: flex;
    justify-content: center;
    align-items: center;
    padding: 15px; /* ✅ mobile spacing */
}

/* Card */
.upload-card {
    width: 420px;
    max-width: 100%; /* ✅ responsive */
    border-radius: 20px;
    padding: 30px;
    background: #fff;
    box-shadow: 0 15px 40px rgba(0,0,0,0.1);
    animation: fadeUp 0.8s ease;
    transition: 0.3s;
}

/* Disable hover effect on mobile */
@media (hover: hover) {
    .upload-card:hover {
        transform: translateY(-8px);
    }
}

/* Upload Box */
.upload-box {
    border: 2px dashed #0d6efd;
    border-radius: 15px;
    padding: 30px;
    text-align: center;
    background: #f9fbff;
    cursor: pointer;
    transition: 0.3s;
}

.upload-box:hover {
    background: #eef4ff;
    border-color: #0a58ca;
    transform: scale(1.02);
}

.upload-box.dragover {
    background: #e7f1ff;
}

/* File List */
.file-list {
    margin-top: 15px;
    max-height: 120px;
    overflow-y: auto;
}

/* File item */
.file-item {
    padding: 10px;
    border-radius: 10px;
    background: #f8f9fa;
    margin-bottom: 6px;
    display: flex;
    align-items: center;
    font-size: 14px;
    transition: 0.3s;
}

.file-item:hover {
    background: #e9f3ff;
    transform: translateX(5px);
}

/* Icons */
.file-item i {
    margin-right: 10px;
    font-size: 18px;
}

/* Progress */
.progress {
    height: 18px;
    border-radius: 10px;
}

/* Buttons */
.btn-upload {
    background: linear-gradient(135deg, #0d6efd, #0a58ca);
    color: white;
    border-radius: 10px;
    font-weight: 500;
    transition: 0.3s;
}

.btn-upload:hover {
    transform: scale(1.05);
    opacity: 0.9;
}

/* Back Button */
.btn-outline-secondary:hover {
    transform: scale(1.05);
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
@keyframes fadeDown {
    from {opacity:0; transform:translateY(-20px);}
    to {opacity:1; transform:translateY(0);}
}

@keyframes fadeUp {
    from {opacity:0; transform:translateY(20px);}
    to {opacity:1; transform:translateY(0);}
}

/* Toast */
#toastContainer {
    position: fixed;
    top: 20px;
    left: 50%;
    transform: translateX(-50%);
    z-index: 1100;
}

/* ✅ MOBILE RESPONSIVE */
@media (max-width: 576px) {

    h2 {
        font-size: 1.4rem;
    }

    .upload-card {
        padding: 20px;
        border-radius: 15px;
    }

    .upload-box {
        padding: 20px;
    }

    .upload-box i {
        font-size: 35px;
    }

    .file-item {
        font-size: 13px;
    }

    .btn-upload,
    .btn-outline-secondary {
        font-size: 0.95rem;
        padding: 10px;
    }

    .navbar-brand {
        font-size: 1rem;
        text-align: center;
        width: 100%;
    }
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

                <li class="nav-item"><a class="nav-link" href="home">Home</a></li>
                <li class="nav-item"><a class="nav-link active" href="upload">Upload</a></li>
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

<h2 class="text-center">📤 Upload Files to Bucket</h2>

<p class="text-center mb-3">Logged in as: <strong><%= username %></strong></p>

<div class="center-box">
<div class="upload-card">

<h5 class="text-center mb-3">🚀 Upload Files</h5>

<div class="upload-box" id="dropArea">
    <i class="bi bi-cloud-upload"></i>
    <p class="mt-2 mb-1">Drag & Drop or Click</p>
    <small class="text-muted">Supports multiple files</small>
    <input type="file" id="fileInput" multiple hidden>
</div>

<div class="file-list" id="fileList"></div>

<div class="progress mt-3 d-none" id="progressBar">
    <div class="progress-bar progress-bar-striped progress-bar-animated" style="width:0%">0%</div>
</div>

<button class="btn btn-upload w-100 mt-3" onclick="uploadFiles()">
    Upload Files
</button>

<a href="home" class="btn btn-outline-secondary w-100 mt-2">
    Back
</a>

</div>
</div>

<div id="toastContainer">
  <div id="successToast" class="toast align-items-center text-white bg-success border-0">
    <div class="d-flex">
      <div class="toast-body">✅ File uploaded successfully!</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  </div>

  <div id="errorToast" class="toast align-items-center text-white bg-danger border-0">
    <div class="d-flex">
      <div class="toast-body">❌ Upload failed! Try again.</div>
      <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
    </div>
  </div>
</div>

<footer>
    © 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
let files = [];

const dropArea = document.getElementById("dropArea");
const fileInput = document.getElementById("fileInput");
const fileList = document.getElementById("fileList");
const progressBar = document.getElementById("progressBar");
const progress = progressBar.querySelector(".progress-bar");

dropArea.onclick = () => fileInput.click();

fileInput.onchange = () => {
    files = [...fileInput.files];
    displayFiles();
};

dropArea.addEventListener("dragover", e => {
    e.preventDefault();
    dropArea.classList.add("dragover");
});

dropArea.addEventListener("dragleave", () => {
    dropArea.classList.remove("dragover");
});

dropArea.addEventListener("drop", e => {
    e.preventDefault();
    dropArea.classList.remove("dragover");
    files = [...e.dataTransfer.files];
    displayFiles();
});

function displayFiles() {
    fileList.innerHTML = "";
    files.forEach(f => {
        let icon = "bi-file";
        if(f.name.endsWith(".pdf")) icon = "bi-file-earmark-pdf";
        else if(f.name.match(/jpg|png|jpeg/)) icon = "bi-image";
        else if(f.name.match(/zip|rar/)) icon = "bi-file-zip";

        fileList.innerHTML += `
            <div class="file-item">
                <i class="bi ${icon}"></i> ${f.name}
            </div>
        `;
    });
}

function uploadFiles() {
    if(files.length === 0){
        alert("Select files!");
        return;
    }

    const formData = new FormData();
    files.forEach(f => formData.append("file", f));

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "upload", true);

    progressBar.classList.remove("d-none");

    xhr.upload.onprogress = e => {
        let percent = (e.loaded / e.total) * 100;
        progress.style.width = percent + "%";
        progress.innerText = Math.round(percent) + "%";
    };

    xhr.onload = () => {
        progressBar.classList.add("d-none");
        if(xhr.status === 200){
            new bootstrap.Toast(document.getElementById('successToast'), { delay: 3000 }).show();
            fileList.innerHTML = "";
            fileInput.value = "";
            files = [];
        } else {
            new bootstrap.Toast(document.getElementById('errorToast'), { delay: 3000 }).show();
        }
    };

    xhr.onerror = () => {
        new bootstrap.Toast(document.getElementById('errorToast'), { delay: 3000 }).show();
    }

    xhr.send(formData);
}
</script>

</body>
</html>