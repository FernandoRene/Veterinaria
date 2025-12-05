<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login - Sistema Veterinaria</title>
    <style>
        body { font-family: Arial; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
               min-height: 100vh; display: flex; justify-content: center; align-items: center; margin: 0; }
        .login-box { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); 
                     width: 350px; }
        h1 { color: #667eea; text-align: center; margin-bottom: 30px; }
        input { width: 100%; padding: 12px; margin: 10px 0; border: 2px solid #e1e8ed; border-radius: 5px; 
                box-sizing: border-box; }
        input:focus { outline: none; border-color: #667eea; }
        button { width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                 color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; margin-top: 10px; }
        button:hover { opacity: 0.9; }
        label { font-weight: 500; color: #333; }
        .credentials { background: #f8f9fa; padding: 15px; border-radius: 5px; margin-top: 20px; font-size: 13px; }
        .credentials code { background: white; padding: 2px 6px; border-radius: 3px; color: #e83e8c; }
    </style>
</head>
<body>
    <div class="login-box">
        <h1>🐾 Sistema Veterinaria SigePet</h1>
        <form action="loginServlet" method="POST">
            <label>Usuario</label>
            <input type="text" name="usuario" required autofocus>
            
            <label>Contraseña</label>
            <input type="password" name="password" required>
            
            <button type="submit">Iniciar Sesión</button>
        </form>
        
    </div>
</body>
</html>
