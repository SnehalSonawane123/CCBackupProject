<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0"> <!-- ✅ Mobile -->
<title>Error - AWS S3 Backup System</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
body {
    min-height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    background: linear-gradient(135deg, #ff4b2b, #ff416c);
    font-family: 'Segoe UI', sans-serif;
    padding: 15px;
}

/* Glass card */
.card {
    padding: 40px 30px;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.15);
    backdrop-filter: blur(15px);
    color: white;
    text-align: center;
    box-shadow: 0 10px 40px rgba(0,0,0,0.3);
    animation: fadeIn 0.8s ease-in-out;
    width: 100%;
    max-width: 380px;
    transition: 0.3s;
}

.card:hover {
    transform: translateY(-5px);
}

/* Icon */
.crossmark {
    font-size: 4.5rem;
    animation: bounce 0.8s ease;
}

/* Text */
h2 {
    font-weight: 600;
    margin-top: 10px;
}

p {
    opacity: 0.9;
    font-size: 15px;
}

/* Buttons */
.btn-custom {
    border-radius: 10px;
    padding: 10px 18px;
    font-weight: 500;
    transition: 0.3s;
    font-size: 14px;
}

/* Home button */
.btn-home {
    background: white;
    color: #ff416c;
}

.btn-home:hover {
    transform: translateY(-3px);
    box-shadow: 0 5px 20px rgba(255,255,255,0.4);
}

/* Retry button */
.btn-retry {
    border: 1px solid white;
    color: white;
}

.btn-retry:hover {
    background: white;
    color: #ff416c;
    transform: translateY(-3px);
}

/* Animations */
@keyframes fadeIn {
    from {opacity: 0; transform: translateY(30px);}
    to {opacity: 1; transform: translateY(0);}
}

@keyframes bounce {
    0% {transform: scale(0.5);}
    60% {transform: scale(1.2);}
    100% {transform: scale(1);}
}

/* Mobile fix */
@media (max-width: 576px) {
    .card {
        padding: 30px 20px;
    }

    .crossmark {
        font-size: 3.5rem;
    }
}
</style>

</head>
<body>

<div class="card">
    
    <div class="crossmark">❌</div>

    <h2>Oops! Something went wrong</h2>

    <p class="mt-2 mb-4">
        The operation failed. Please try again or go back safely.
    </p>

    <div class="d-flex justify-content-center gap-3 flex-wrap">
        <a href="home" class="btn btn-custom btn-home">🏠 Home</a>
        <a href="javascript:history.back()" class="btn btn-custom btn-retry">🔄 Retry</a>
    </div>

</div>

</body>
</html>