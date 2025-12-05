<%-- 
    Document   : loginError
    Created on : ${date}, ${time}
    Author     : Sistema Veterinaria
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Error de Login - Sistema Veterinaria</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            
            .error-container {
                background: white;
                padding: 40px;
                border-radius: 10px;
                box-shadow: 0 10px 25px rgba(0,0,0,0.2);
                width: 100%;
                max-width: 500px;
                text-align: center;
            }
            
            .error-icon {
                font-size: 80px;
                margin-bottom: 20px;
            }
            
            .error-container h1 {
                color: #dc3545;
                font-size: 28px;
                margin-bottom: 15px;
            }
            
            .error-container p {
                color: #666;
                font-size: 16px;
                margin-bottom: 10px;
                line-height: 1.6;
            }
            
            .error-details {
                background: #fff3cd;
                border-left: 4px solid #ffc107;
                padding: 15px;
                margin: 20px 0;
                text-align: left;
                border-radius: 5px;
            }
            
            .error-details h4 {
                color: #856404;
                font-size: 14px;
                margin-bottom: 10px;
            }
            
            .error-details ul {
                color: #856404;
                font-size: 14px;
                margin-left: 20px;
            }
            
            .error-details li {
                margin: 5px 0;
            }
            
            .btn-return {
                display: inline-block;
                margin-top: 20px;
                padding: 12px 30px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                text-decoration: none;
                border-radius: 5px;
                font-size: 16px;
                font-weight: 600;
                transition: transform 0.2s;
            }
            
            .btn-return:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            }
        </style>
    </head>
    <body>
        <div class="error-container">
            <div class="error-icon">⚠️</div>
            <h1>Error de Autenticación</h1>
            <p>No se pudo iniciar sesión. Las credenciales proporcionadas no son válidas.</p>
            
            <div class="error-details">
                <h4>Posibles causas:</h4>
                <ul>
                    <li>Usuario o contraseña incorrectos</li>
                    <li>La cuenta puede estar inactiva</li>
                    <li>La contraseña puede haber expirado</li>
                    <li>Se alcanzó el número máximo de intentos</li>
                </ul>
            </div>
            
            <p>Por favor, verifique sus credenciales e intente nuevamente.</p>
            
            <a href="login.jsp" class="btn-return">
                Volver al Login
            </a>
        </div>
    </body>
</html>
