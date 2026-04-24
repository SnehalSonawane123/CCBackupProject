<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<!-- ✅ IMPORTANT for mobile responsiveness -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Register - AWS S3 Backup System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

<style>
/* === Keep all your existing CSS unchanged === */
body {
    background: linear-gradient(135deg, #6a11cb, #2575fc);
    min-height: 100vh;
    font-family: 'Segoe UI', sans-serif;
    overflow-x: hidden;
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
/* ✅ Mobile spacing fix */
.container {
    padding: 15px;
}

/* Card */
.register-card {
    border-radius: 20px;
    padding: 30px;
    background: rgba(255,255,255,0.95);
    box-shadow: 0 15px 40px rgba(0,0,0,0.25);
    animation: fadeInUp 1s ease forwards;
    transform: translateY(30px);
    transition: transform 0.3s ease, box-shadow 0.3s ease;
}

/* Hover (disable on mobile for smooth UX) */
@media (hover: hover) {
    .register-card:hover {
        transform: translateY(0px) scale(1.02);
        box-shadow: 0 20px 50px rgba(0,0,0,0.35);
    }
}

.navbar-brand {
    font-weight: bold;
    color: #fff !important;
    font-size: 1.4rem;
    animation: fadeInDown 1s ease forwards;
    transform: translateY(-30px);
}

/* Inputs */
.form-control {
    border-radius: 10px;
    transition: all 0.3s ease;
}

.form-control:focus {
    box-shadow: 0 0 10px rgba(0,123,255,0.6);
    transform: scale(1.02);
}

/* Button */
.btn-primary {
    border-radius: 10px;
    transition: all 0.3s ease;
    animation: fadeIn 1s ease forwards;
}

.btn-primary:hover {
    transform: translateY(-3px) scale(1.03);
    box-shadow: 0 8px 20px rgba(0,123,255,0.5);
}

/* Strength bar */
.strength-bar {
    height: 6px;
    border-radius: 5px;
    margin-top: 5px;
    transition: width 0.3s ease, background 0.3s ease;
}

.small-text {
    font-size: 0.85rem;
    animation: fadeIn 1s ease forwards;
}

/* Animations */
@keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
}

@keyframes fadeInUp {
    from { opacity: 0; transform: translateY(30px);}
    to { opacity: 1; transform: translateY(0);}
}

@keyframes fadeInDown {
    from { opacity: 0; transform: translateY(-30px);}
    to { opacity: 1; transform: translateY(0);}
}

/* ✅ MOBILE RESPONSIVE FIXES */
@media (max-width: 576px) {

    .register-card {
        padding: 20px;
        border-radius: 15px;
    }

    h2 {
        font-size: 1.5rem;
    }

    .navbar-brand {
        font-size: 1rem;
        text-align: center;
        width: 100%;
    }

    .input-group-text {
        padding: 8px;
    }

    .form-control {
        font-size: 0.9rem;
    }

    .btn-primary {
        font-size: 0.95rem;
        padding: 10px;
    }
}
</style>

<script>
function togglePassword(id, icon) {
    let field = document.getElementById(id);
    let iconEl = document.getElementById(icon);

    if (field.type === "password") {
        field.type = "text";
        iconEl.classList.replace("bi-eye", "bi-eye-slash");
    } else {
        field.type = "password";
        iconEl.classList.replace("bi-eye-slash", "bi-eye");
    }
}

function checkStrength() {
    let pass = document.getElementById("password").value;
    let bar = document.getElementById("strengthBar");
    let text = document.getElementById("strengthText");

    let strength = 0;

    if (pass.length >= 6) strength++;
    if (pass.match(/[A-Z]/)) strength++;
    if (pass.match(/[0-9]/)) strength++;
    if (pass.match(/[@$!%*?&]/)) strength++;

    if (strength <= 1) {
        bar.style.width = "25%";
        bar.style.background = "red";
        text.innerText = "Weak";
    } else if (strength == 2) {
        bar.style.width = "50%";
        bar.style.background = "orange";
        text.innerText = "Medium";
    } else if (strength == 3) {
        bar.style.width = "75%";
        bar.style.background = "#ffc107";
        text.innerText = "Good";
    } else {
        bar.style.width = "100%";
        bar.style.background = "green";
        text.innerText = "Strong";
    }
}

function validatePassword() {
    let pass = document.getElementById("password").value;
    let confirm = document.getElementById("confirmPassword").value;
    let msg = document.getElementById("matchMsg");

    if (confirm === "") {
        msg.innerText = "";
        return;
    }

    if (pass === confirm) {
        msg.innerText = "Passwords match ✅";
        msg.style.color = "green";
    } else {
        msg.innerText = "Passwords do not match ❌";
        msg.style.color = "red";
    }
}
</script>
</head>

<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-transparent p-3 position-absolute w-100">
    
    <a class="navbar-brand" href="index.jsp">
        Backup & Recovery System using AWS S3
    </a>

    <div class="ms-auto">
        <a href="index.jsp" class="btn btn-outline-light btn-sm">Login</a>
    </div>

</nav>

<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
    <div class="register-card w-100" style="max-width:420px;">

        <h2 class="text-center mb-4">📝 Create Account</h2>

        <% 
            String msg = (String) request.getAttribute("msg");
            String errorDetail = (String) request.getAttribute("errorDetail");
            if("error".equals(msg) && errorDetail != null){
        %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <%= errorDetail %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <% } %>

        <form action="register" method="post">

            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-person"></i></span>
                <input type="text" name="fullName" class="form-control" placeholder="Full Name" required>
            </div>

            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-person-badge"></i></span>
                <input type="text" name="username" class="form-control" placeholder="Username" required>
            </div>

            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                <input type="email" name="email" class="form-control" placeholder="Email" required>
            </div>

            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-telephone"></i></span>
                <input type="text" name="phone" class="form-control" placeholder="Phone">
            </div>

            <div class="mb-3 input-group">
                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                <input type="password" id="password" name="password" class="form-control" placeholder="Password" onkeyup="checkStrength(); validatePassword();" required>
                <span class="input-group-text" onclick="togglePassword('password','eye1')" style="cursor:pointer;">
                    <i id="eye1" class="bi bi-eye"></i>
                </span>
            </div>

            <div class="strength-bar bg-light">
                <div id="strengthBar" class="strength-bar"></div>
            </div>
            <div id="strengthText" class="small-text mb-2"></div>

            <div class="mb-3 mt-3 input-group">
                <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                <input type="password" id="confirmPassword" class="form-control" placeholder="Confirm Password" onkeyup="validatePassword()" required>
                <span class="input-group-text" onclick="togglePassword('confirmPassword','eye2')" style="cursor:pointer;">
                    <i id="eye2" class="bi bi-eye"></i>
                </span>
            </div>

            <div id="matchMsg" class="small-text mb-2"></div>

            <button type="submit" class="btn btn-primary w-100">
                <i class="bi bi-person-plus"></i> Register
            </button>

            <div class="text-center mt-3">
                <small>Already have an account? <a href="index.jsp">Login</a></small>
            </div>

        </form>
    </div>
</div>
<footer>
    © 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html> 