<%@page import="com.dev.bean.UsuarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Usuarios</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; }
        .container { max-width: 1400px; margin: 0 auto; background: white; min-height: 100vh; }
        
        /* Header */
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; 
                  padding: 30px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { font-size: 28px; }
        .back-link { color: white; text-decoration: none; padding: 10px 20px; 
                     background: rgba(255,255,255,0.2); border-radius: 5px; }
        
        /* Tabs */
        .tabs { display: flex; background: #f8f9fa; border-bottom: 2px solid #dee2e6; }
        .tab { padding: 15px 30px; cursor: pointer; border: none; background: transparent; 
               font-size: 16px; font-weight: 600; color: #6c757d; transition: all 0.3s; }
        .tab.active { color: #667eea; border-bottom: 3px solid #667eea; background: white; }
        .tab:hover { color: #667eea; }
        
        /* Content */
        .tab-content { display: none; padding: 30px; }
        .tab-content.active { display: block; }
        
        /* Alert */
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; animation: slideDown 0.3s; }
        .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .alert-error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
        
        /* Form */
        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; }
        .form-group { margin-bottom: 20px; }
        .form-group.full-width { grid-column: span 2; }
        label { display: block; font-weight: 600; margin-bottom: 8px; color: #333; }
        input, select, textarea { width: 100%; padding: 12px; border: 2px solid #e1e8ed; 
                                   border-radius: 5px; font-size: 14px; }
        input:focus, select:focus, textarea:focus { outline: none; border-color: #667eea; }
        button { padding: 12px 30px; border: none; border-radius: 5px; font-size: 16px; 
                 font-weight: 600; cursor: pointer; }
        .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                       color: white; width: 100%; margin-top: 10px; }
        .btn-primary:hover { opacity: 0.9; }
        
        /* Table */
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        thead { background: #667eea; color: white; }
        th { padding: 12px; text-align: left; font-weight: 600; }
        td { padding: 12px; border-bottom: 1px solid #dee2e6; }
        tbody tr:hover { background: #f8f9fa; }
        .action-btn { padding: 6px 12px; text-decoration: none; border-radius: 4px; 
                      font-size: 12px; margin-right: 5px; display: inline-block; }
        .btn-warning { background: #ffc107; color: #000; }
        .btn-info { background: #17a2b8; color: white; }
        
        /* Validation */
        .validation { margin-top: 10px; font-size: 14px; }
        .validation.match { color: #28a745; }
        .validation.no-match { color: #dc3545; }
        
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-10px); }
            to { opacity: 1; transform: translateY(0); }
        }
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
        boolean esError = false;
        String tabActiva = request.getParameter("tab");
        
        // Si no hay tab especificada, usar "lista" por defecto
        if (tabActiva == null || tabActiva.isEmpty()) {
            tabActiva = "lista";
        }
        
        // Procesar registro de usuario
        if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("accion") != null) {
            String accion = request.getParameter("accion");
            
            if ("registrar".equals(accion)) {
                UsuarioBean bean = new UsuarioBean();
                mensaje = bean.registrarUsuario(request);
                bean.cerrarConexion();
                esError = mensaje.contains("Error");
                
                // Si el registro fue exitoso, cambiar a tab de lista
                if (!esError) {
                    tabActiva = "lista";
                }
            }
        }
        
        // Obtener lista de usuarios
        String listaHTML = "";
        try {
            UsuarioBean bean = new UsuarioBean();
            listaHTML = bean.listadoUsuario();
            bean.cerrarConexion();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        // Obtener lista de roles
        String rolesHTML = "";
        try {
            Class.forName("org.postgresql.Driver");
            Connection con = DriverManager.getConnection(
                "jdbc:postgresql://localhost:5432/modulo9_proyecto", 
                "postgres", 
                "INvoker2025."
            );
            PreparedStatement ps = con.prepareStatement("SELECT id_rol, nombre_rol FROM rol WHERE estado = 'ACTIVO' ORDER BY nombre_rol");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                rolesHTML += "<option value='" + rs.getInt("id_rol") + "'>" + rs.getString("nombre_rol") + "</option>";
            }
            rs.close();
            ps.close();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    %>
    
    <div class="container">
        <div class="header">
            <h1>👥 Gestión de Usuarios</h1>
            <a href="index.jsp" class="back-link">← Volver al inicio</a>
        </div>
        
        <!-- Tabs -->
        <div class="tabs">
            <button class="tab <%= "lista".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('lista')">
                📋 Lista de Usuarios
            </button>
            <button class="tab <%= "registro".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('registro')">
                ➕ Nuevo Usuario
            </button>
        </div>
        
        <!-- Mensaje -->
        <% if (!mensaje.isEmpty()) { %>
            <div style="padding: 30px;">
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            </div>
        <% } %>
        
        <!-- Tab: Lista de Usuarios -->
        <div id="tab-lista" class="tab-content <%= "lista".equals(tabActiva) ? "active" : "" %>">
            <% if (listaHTML != null && !listaHTML.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>Usuario</th>
                            <th>Nombre</th>
                            <th>Apellido Paterno</th>
                            <th>Apellido Materno</th>
                            <th>Dirección</th>
                            <th>Teléfono</th>
                            <th>CI</th>
                            <th>Rol</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= listaHTML %>
                    </tbody>
                </table>
            <% } else { %>
                <div style="text-align: center; padding: 40px; color: #6c757d;">
                    No hay usuarios registrados
                </div>
            <% } %>
        </div>
        
        <!-- Tab: Registro de Usuario -->
        <div id="tab-registro" class="tab-content <%= "registro".equals(tabActiva) ? "active" : "" %>">
            <form method="POST" id="formRegistro">
                <input type="hidden" name="accion" value="registrar">
                
                <div class="form-grid">
                    <div class="form-group">
                        <label>Nombre *</label>
                        <input type="text" name="nombre" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Apellido Paterno *</label>
                        <input type="text" name="paterno" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Apellido Materno</label>
                        <input type="text" name="materno">
                    </div>
                    
                    <div class="form-group">
                        <label>CI *</label>
                        <input type="text" name="nroCedula" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Teléfono</label>
                        <input type="tel" name="telefono">
                    </div>
                    
                    <div class="form-group">
                        <label>Rol *</label>
                        <select name="idRol" required>
                            <option value="">Seleccione...</option>
                            <%= rolesHTML %>
                        </select>
                    </div>
                    
                    <div class="form-group full-width">
                        <label>Dirección</label>
                        <input type="text" name="direccion">
                    </div>
                    
                    <div class="form-group">
                        <label>Contraseña *</label>
                        <input type="password" name="password" id="password" required minlength="6" 
                               placeholder="Mínimo 6 caracteres">
                    </div>
                    
                    <div class="form-group">
                        <label>Confirmar Contraseña *</label>
                        <input type="password" id="confirmPassword" required minlength="6" 
                               placeholder="Repita la contraseña">
                        <div class="validation" id="validacion"></div>
                    </div>
                </div>
                
                <button type="submit" class="btn-primary" id="btnSubmit" disabled>
                    Registrar Usuario
                </button>
            </form>
        </div>
    </div>
    
    <script>
        // Cambiar entre tabs
        function cambiarTab(tab) {
            // Actualizar URL sin recargar
            const url = new URL(window.location);
            url.searchParams.set('tab', tab);
            window.history.pushState({}, '', url);
            
            // Ocultar todos los contenidos
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            
            // Desactivar todos los tabs
            document.querySelectorAll('.tab').forEach(t => {
                t.classList.remove('active');
            });
            
            // Activar tab seleccionada
            document.getElementById('tab-' + tab).classList.add('active');
            event.target.classList.add('active');
        }
        
        // Validación de contraseñas
        const password = document.getElementById('password');
        const confirmPassword = document.getElementById('confirmPassword');
        const validacion = document.getElementById('validacion');
        const btnSubmit = document.getElementById('btnSubmit');
        
        function validarPasswords() {
            const pass1 = password.value;
            const pass2 = confirmPassword.value;
            
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
        
        password.addEventListener('input', validarPasswords);
        confirmPassword.addEventListener('input', validarPasswords);
        
        document.getElementById('formRegistro').addEventListener('submit', function(e) {
            if (password.value !== confirmPassword.value) {
                e.preventDefault();
                alert('Las contraseñas no coinciden');
            }
        });
    </script>
</body>
</html>
