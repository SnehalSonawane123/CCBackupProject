<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">

<!-- ✅ REQUIRED FOR MOBILE -->
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Login - AWS S3 Backup System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
/* === Keep all your existing CSS === */
body {
    background: linear-gradient(135deg, #4e54c8, #8f94fb);
    min-height: 100vh;
    font-family: 'Segoe UI', sans-serif;
    overflow-x: hidden; /* ✅ fixed */
}

.navbar-brand { font-weight: bold; color: #fff !important; font-size: 1.4rem; }

.login-card {
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(15px);
    padding: 2rem;
    color: white;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    animation: fadeIn 0.8s ease;
}

h2 { text-align: center; margin-bottom: 20px; font-weight: 600; }

.form-control { border-radius: 10px; height: 45px; border: none; }

.form-control:focus { box-shadow: 0 0 10px rgba(255,255,255,0.6); }

.btn-primary {
    border-radius: 10px;
    padding: 10px;
    font-weight: 500;
    transition: 0.3s;
}

.btn-primary:hover {
    transform: translateY(-3px);
    box-shadow: 0 5px 20px rgba(0,0,0,0.3);
}

a { color: #fff; font-weight: 500; }
a:hover { text-decoration: underline; }

.grid-container {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2rem;
}

.info-card {
    text-align: center;
    display: flex;
    flex-direction: column;
    justify-content: center;
}

.alert { font-size: 0.9rem; }

@keyframes fadeIn {
    from {opacity: 0; transform: translateY(-20px);}
    to {opacity: 1; transform: translateY(0);}
}

/* ✅ MOBILE RESPONSIVE */
@media(max-width: 768px) {

    .grid-container {
        grid-template-columns: 1fr;
        gap: 1.5rem;
        padding: 10px;
    }

    .login-card {
        padding: 1.5rem;
    }

    .navbar-brand {
        font-size: 1rem;
        text-align: center;
        width: 100%;
    }

    h2 {
        font-size: 1.3rem;
    }

    .form-control {
        height: 40px;
        font-size: 0.9rem;
    }

    .btn-primary {
        padding: 8px;
        font-size: 0.9rem;
    }
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
/* Extra small devices */
@media(max-width: 480px) {

    .login-card {
        padding: 1.2rem;
    }

    h2 {
        font-size: 1.1rem;
    }

    .form-control {
        height: 38px;
        font-size: 0.85rem;
    }
}

</style>

</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-transparent p-3 position-absolute w-100">
    
    <a class="navbar-brand" href="index.jsp">
        Backup & Recovery System using AWS S3
    </a>

    <div class="ms-auto">
        <a href="register.jsp" class="btn btn-outline-light btn-sm">Register</a>
    </div>

</nav>

<!-- Main -->
<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
    <div class="grid-container">

        <!-- Login Card -->
        <div class="login-card">

            <!-- Alert -->
            <div id="alertPlaceholder">
            <%
                String msg = (String) request.getAttribute("msg");
                if(msg != null){
                    String alertClass = "alert-light";
                    String alertText = "";

                    switch(msg){
                        case "registered": 
                            alertText = "✅ Registered successfully. Please login."; 
                            alertClass="alert-success"; 
                            break;
                        case "invalid": 
                            alertText = "❌ Invalid username/password!"; 
                            alertClass="alert-danger"; 
                            break;
                        case "error": 
                            alertText = "⚠ Something went wrong!"; 
                            alertClass="alert-warning"; 
                            break;
                        case "loggedout": 
                            alertText = "✅ Logged out successfully!"; 
                            alertClass="alert-info"; 
                            break;
                    }
            %>
            <div class="alert <%= alertClass %> alert-dismissible fade show" role="alert">
                <%= alertText %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
            <% } %>
            </div>

            <h2>Login</h2>

            <form action="login" method="post">
                <div class="mb-3">
                    <input type="text" name="username" placeholder="Username" class="form-control" required>
                </div>

                <div class="mb-3">
                    <input type="password" name="password" placeholder="Password" class="form-control" required>
                </div>

                <button type="submit" class="btn btn-primary w-100">
                    Login
                </button>

                <div class="text-center mt-3">
                    <small>Don't have an account? <a href="register.jsp">Register</a></small>
                </div>
            </form>
        </div>

        <!-- Info Card -->
        <div class="login-card info-card">
            <h2>Welcome 👋</h2>
            <p>
                Manage your files securely with Backup & Recovery System using AWS S3.
            </p>
            <p>
                Upload, delete, backup, and restore files easily with a modern cloud interface.
            </p>
        </div>

    </div>
</div>
<footer>
    © 2026 Backup & Recovery System using AWS S3 | Developed by Tanuja Surve and Group
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html> 