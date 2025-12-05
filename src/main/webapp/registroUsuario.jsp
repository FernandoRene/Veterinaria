<%@page import="com.dev.bean.UsuarioBean"%>
<%@page import="com.dev.bean.RolBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Usuario</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; }
            .header h1 { font-size: 24px; margin-bottom: 5px; }
            .form-group { margin-bottom: 20px; }
            .form-group label { display: block; color: #333; font-weight: 500; margin-bottom: 8px; }
            .form-group input, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
            .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
            .btn { padding: 12px 30px; border: none; border-radius: 5px; font-size: 16px; font-weight: 600; cursor: pointer; }
            .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; width: 100%; margin-top: 20px; }
            .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
            .alert-success { background: #d4edda; border-left: 4px solid #28a745; color: #155724; }
            .alert-error { background: #f8d7da; border-left: 4px solid #dc3545; color: #721c24; }
            .back-link { display: inline-block; color: #667eea; text-decoration: none; margin-bottom: 20px; }
        </style>
    </head>
    <body>
        <%
            // Verificar sesión
            UsuarioRol usuarioRol = (UsuarioRol) session.getAttribute("usuarioRol");
            if (usuarioRol == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            String mensaje = "";
            boolean mostrarMensaje = false;
            boolean esError = false;
            
            // Procesar formulario
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    UsuarioBean bean = new UsuarioBean();
                    mensaje = bean.registrarUsuario(request);
                    mostrarMensaje = true;
                    esError = mensaje.toLowerCase().contains("error");
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensaje = "Error: " + e.getMessage();
                    mostrarMensaje = true;
                    esError = true;
                }
            }
            
            // Obtener roles para el select
            String rolesOption = "";
            try {
                RolBean rolBean = new RolBean();
                rolesOption = rolBean.listaRolSelect();
                rolBean.cerrarConexion();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        
        <div class="container">
            <div class="header">
                <h1>👤 Registro de Usuario</h1>
                <p>Complete todos los campos para registrar un nuevo usuario</p>
            </div>
            
            <a href="index.jsp" class="back-link">← Volver al inicio</a>
            
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="POST" action="registroUsuario.jsp">
                <h3 style="color: #333; margin-bottom: 20px;">📋 Datos Personales</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Nombre *</label>
                        <input type="text" name="nombre" required>
                    </div>
                    <div class="form-group">
                        <label>Apellido Paterno *</label>
                        <input type="text" name="paterno" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Apellido Materno</label>
                        <input type="text" name="materno">
                    </div>
                    <div class="form-group">
                        <label>CI *</label>
                        <input type="text" name="nroCedula" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Teléfono</label>
                        <input type="tel" name="telefono">
                    </div>
                    <div class="form-group">
                        <label>Rol *</label>
                        <select name="idRol" required>
                            <option value="">Seleccione un rol</option>
                            <%= rolesOption %>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Dirección</label>
                    <input type="text" name="direccion">
                </div>
                
                <h3 style="color: #333; margin: 30px 0 20px 0;">🔐 Credenciales de Acceso</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Contraseña *</label>
                        <input type="password" name="password" id="password" required minlength="6" placeholder="Mínimo 6 caracteres">
                    </div>
                    <div class="form-group">
                        <label>Confirmar Contraseña *</label>
                        <input type="password" name="confirmPassword" id="confirmPassword" required minlength="6" placeholder="Repita la contraseña">
                    </div>
                </div>
                
                <div id="passwordMessage" style="padding: 10px; border-radius: 5px; margin-bottom: 20px; display: none;"></div>
                
                <button type="submit" class="btn btn-primary" id="btnSubmit">💾 Guardar Usuario</button>
            </form>
        </div>
        
        <script>
            // Validación de contraseñas en tiempo real
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirmPassword');
            const passwordMessage = document.getElementById('passwordMessage');
            const btnSubmit = document.getElementById('btnSubmit');
            
            function validarPasswords() {
                const pass = password.value;
                const confirm = confirmPassword.value;
                
                if (confirm.length === 0) {
                    passwordMessage.style.display = 'none';
                    return;
                }
                
                if (pass === confirm) {
                    passwordMessage.style.display = 'block';
                    passwordMessage.style.background = '#d4edda';
                    passwordMessage.style.color = '#155724';
                    passwordMessage.textContent = '✓ Las contraseñas coinciden';
                    btnSubmit.disabled = false;
                } else {
                    passwordMessage.style.display = 'block';
                    passwordMessage.style.background = '#f8d7da';
                    passwordMessage.style.color = '#721c24';
                    passwordMessage.textContent = '✗ Las contraseñas no coinciden';
                    btnSubmit.disabled = true;
                }
            }
            
            password.addEventListener('input', validarPasswords);
            confirmPassword.addEventListener('input', validarPasswords);
            
            // Validación antes de enviar
            document.querySelector('form').addEventListener('submit', function(e) {
                const pass = password.value;
                const confirm = confirmPassword.value;
                
                if (pass !== confirm) {
                    e.preventDefault();
                    alert('Las contraseñas no coinciden. Por favor verifique.');
                    return false;
                }
                
                if (pass.length < 6) {
                    e.preventDefault();
                    alert('La contraseña debe tener al menos 6 caracteres');
                    return false;
                }
                
                return confirm('¿Está seguro de crear este usuario?');
            });
        </script>
    </body>
</html>
