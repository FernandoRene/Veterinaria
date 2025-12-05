<%@page import="com.dev.bean.UsuarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Cambiar Contraseña</title>
    <style>
        body { font-family: Arial; background: #f5f5f5; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px; margin: -30px -30px 30px -30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; font-weight: 600; margin-bottom: 8px; color: #333; }
        input { width: 100%; padding: 12px; border: 2px solid #e1e8ed; border-radius: 5px; box-sizing: border-box; }
        input:focus { outline: none; border-color: #667eea; }
        button { width: 100%; padding: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border: none; border-radius: 5px; cursor: pointer; font-size: 16px; margin-top: 10px; }
        button:hover { opacity: 0.9; }
        button:disabled { opacity: 0.5; cursor: not-allowed; }
        .back-link { display: inline-block; color: #667eea; text-decoration: none; margin-bottom: 20px; }
        .message { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .validation { margin-top: 10px; font-size: 14px; }
        .validation.match { color: #28a745; }
        .validation.no-match { color: #dc3545; }
    </style>
</head>
<body>
    <%
        UsuarioRol usuarioRol = (UsuarioRol) session.getAttribute("usuarioRol");
        if (usuarioRol == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        String mensaje = "";
        boolean mostrarFormulario = true;
        
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            UsuarioBean bean = new UsuarioBean();
            mensaje = bean.cambiarPasswordUsuario(request);
            bean.cerrarConexion();
            mostrarFormulario = false;
        }
        
        String codigo = request.getParameter("codigo");
    %>
    
    <div class="container">
        <div class="header">
            <h1>🔑 Cambiar Contraseña</h1>
        </div>
        
        <a href="listaUsuario.jsp" class="back-link">← Volver a la lista</a>
        
        <% if (!mensaje.isEmpty()) { %>
            <div class="message <%= mensaje.contains("Error") ? "error" : "success" %>">
                <%= mensaje %>
            </div>
            <% if (!mensaje.contains("Error")) { %>
                <a href="listaUsuario.jsp">
                    <button type="button">Volver a la lista</button>
                </a>
            <% } %>
        <% } %>
        
        <% if (mostrarFormulario) { %>
            <form method="POST" id="formPassword">
                <input type="hidden" name="codigo" value="<%= codigo %>">
                
                <div class="form-group">
                    <label>Usuario:</label>
                    <input type="text" value="<%= codigo != null ? codigo : "" %>" readonly>
                </div>
                
                <div class="form-group">
                    <label>Nueva Contraseña:</label>
                    <input type="password" name="nuevaPassword" id="nuevaPassword" 
                           required minlength="6" placeholder="Mínimo 6 caracteres">
                </div>
                
                <div class="form-group">
                    <label>Confirmar Contraseña:</label>
                    <input type="password" id="confirmarPassword" 
                           required minlength="6" placeholder="Repita la contraseña">
                    <div class="validation" id="validacion"></div>
                </div>
                
                <button type="submit" id="btnSubmit">Cambiar Contraseña</button>
            </form>
        <% } %>
    </div>
    
    <script>
        const nuevaPass = document.getElementById('nuevaPassword');
        const confirmarPass = document.getElementById('confirmarPassword');
        const validacion = document.getElementById('validacion');
        const btnSubmit = document.getElementById('btnSubmit');
        
        function validarPasswords() {
            const pass1 = nuevaPass.value;
            const pass2 = confirmarPass.value;
            
            if (pass2 === '') {
                validacion.textContent = '';
                btnSubmit.disabled = true;
                return;
            }
            
            if (pass1 === pass2) {
                validacion.textContent = '✓ Las contraseñas coinciden';
                validacion.className = 'validation match';
                btnSubmit.disabled = false;
            } else {
                validacion.textContent = '✗ Las contraseñas no coinciden';
                validacion.className = 'validation no-match';
                btnSubmit.disabled = true;
            }
        }
        
        nuevaPass.addEventListener('input', validarPasswords);
        confirmarPass.addEventListener('input', validarPasswords);
        
        document.getElementById('formPassword').addEventListener('submit', function(e) {
            if (nuevaPass.value !== confirmarPass.value) {
                e.preventDefault();
                alert('Las contraseñas no coinciden');
            }
        });
    </script>
</body>
</html>
