<%@page import="com.dev.bean.VeterinarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Veterinarios</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; }
        .container { max-width: 1400px; margin: 0 auto; background: white; min-height: 100vh; }
        
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; 
                  padding: 30px; display: flex; justify-content: space-between; align-items: center; }
        .header h1 { font-size: 28px; }
        .back-link { color: white; text-decoration: none; padding: 10px 20px; 
                     background: rgba(255,255,255,0.2); border-radius: 5px; }
        
        .tabs { display: flex; background: #f8f9fa; border-bottom: 2px solid #dee2e6; }
        .tab { padding: 15px 30px; cursor: pointer; border: none; background: transparent; 
               font-size: 16px; font-weight: 600; color: #6c757d; transition: all 0.3s; }
        .tab.active { color: #667eea; border-bottom: 3px solid #667eea; background: white; }
        .tab:hover { color: #667eea; }
        
        .tab-content { display: none; padding: 30px; }
        .tab-content.active { display: block; }
        
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; animation: slideDown 0.3s; }
        .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .alert-error { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
        
        .info-box { background: #e7f3ff; padding: 15px; border-radius: 5px; margin-bottom: 20px; 
                    border-left: 4px solid #2196F3; }
        .info-box strong { color: #1976D2; }
        
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        thead { background: #667eea; color: white; }
        th { padding: 12px; text-align: left; font-weight: 600; }
        td { padding: 12px; border-bottom: 1px solid #dee2e6; }
        tbody tr:hover { background: #f8f9fa; }
        .action-btn { padding: 6px 12px; text-decoration: none; border-radius: 4px; 
                      font-size: 12px; display: inline-block; }
        .btn-warning { background: #ffc107; color: #000; }
        
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
        
        String tabActiva = request.getParameter("tab");
        if (tabActiva == null || tabActiva.isEmpty()) {
            tabActiva = "lista";
        }
        
        // Obtener lista de veterinarios
        String listaHTML = "";
        try {
            VeterinarioBean bean = new VeterinarioBean();
            listaHTML = bean.listadoVeterinarios();
            bean.cerrarConexion();
        } catch (Exception e) {
            e.printStackTrace();
        }
    %>
    
    <div class="container">
        <div class="header">
            <h1>🩺 Gestión de Veterinarios</h1>
            <a href="index.jsp" class="back-link">← Volver al inicio</a>
        </div>
        
        <div class="tabs">
            <button class="tab <%= "lista".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('lista')">
                📋 Lista de Veterinarios
            </button>
            <button class="tab <%= "info".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('info')">
                ℹ️ Información
            </button>
        </div>
        
        <!-- Tab: Lista -->
        <div id="tab-lista" class="tab-content <%= "lista".equals(tabActiva) ? "active" : "" %>">
            <% if (listaHTML != null && !listaHTML.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Apellido Paterno</th>
                            <th>Apellido Materno</th>
                            <th>C.I.</th>
                            <th>Matrícula</th>
                            <th>Especialidad</th>
                            <th>Teléfono</th>
                            <th>Email</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= listaHTML %>
                    </tbody>
                </table>
            <% } else { %>
                <div style="text-align: center; padding: 40px; color: #6c757d;">
                    No hay veterinarios registrados
                </div>
            <% } %>
        </div>
        
        <!-- Tab: Información -->
        <div id="tab-info" class="tab-content <%= "info".equals(tabActiva) ? "active" : "" %>">
            <h2 style="color: #667eea; margin-bottom: 20px;">ℹ️ Cómo funciona la gestión de veterinarios</h2>
            
            <div class="info-box">
                <strong>🔗 Registro Automático</strong>
                <p style="margin-top: 10px;">
                    Los veterinarios se crean automáticamente cuando registras un 
                    <strong>usuario con rol VETERINARIO</strong> en la sección de Gestión de Usuarios.
                </p>
            </div>
            
            <div class="info-box">
                <strong>📝 Datos Generados Automáticamente</strong>
                <ul style="margin-top: 10px; margin-left: 20px;">
                    <li><strong>Matrícula:</strong> VET-XXX (auto-incremental)</li>
                    <li><strong>Email:</strong> codigo_usuario@vetclinic.com</li>
                    <li><strong>Especialidad:</strong> Medicina General (por defecto)</li>
                    <li><strong>Estado:</strong> ACTIVO</li>
                    <li><strong>Fecha de contratación:</strong> Fecha actual</li>
                </ul>
            </div>
            
            <div class="info-box">
                <strong>🔄 Gestión</strong>
                <p style="margin-top: 10px;">
                    Desde esta pantalla puedes:
                </p>
                <ul style="margin-top: 10px; margin-left: 20px;">
                    <li>Ver todos los veterinarios registrados</li>
                    <li>Cambiar el estado (ACTIVO/INACTIVO/SUSPENDIDO)</li>
                    <li>Verificar sus datos profesionales</li>
                </ul>
            </div>
            
            <div class="info-box">
                <strong>👤 Acceso al Sistema</strong>
                <p style="margin-top: 10px;">
                    Cada veterinario tiene un usuario asociado que le permite:
                </p>
                <ul style="margin-top: 10px; margin-left: 20px;">
                    <li>Iniciar sesión en el sistema</li>
                    <li>Acceder a funciones según su rol</li>
                    <li>Gestionar sus propios horarios y citas</li>
                </ul>
            </div>
            
            <div style="text-align: center; margin-top: 30px;">
                <a href="gestionUsuarios.jsp?tab=registro" style="display: inline-block; padding: 15px 30px; 
                   background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; 
                   text-decoration: none; border-radius: 8px; font-weight: 600;">
                    ➕ Crear Nuevo Veterinario
                </a>
            </div>
        </div>
    </div>
    
    <script>
        function cambiarTab(tab) {
            const url = new URL(window.location);
            url.searchParams.set('tab', tab);
            window.history.pushState({}, '', url);
            
            document.querySelectorAll('.tab-content').forEach(content => {
                content.classList.remove('active');
            });
            
            document.querySelectorAll('.tab').forEach(t => {
                t.classList.remove('active');
            });
            
            document.getElementById('tab-' + tab).classList.add('active');
            event.target.classList.add('active');
        }
    </script>
</body>
</html>
