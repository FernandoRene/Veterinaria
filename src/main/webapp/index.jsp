<%-- 
    Document   : index
    Created on : ${date}, ${time}
    Author     : Sistema Veterinaria
--%>

<%@page import="com.dev.clases.UsuarioRol"%>
<%@page import="com.dev.clases.Recursos"%>
<%@page import="com.dev.bean.RolRecursoBean"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Sistema de Gestión Veterinaria</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f5f5f5;
            }
            
            /* Header */
            .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px 0;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            
            .header-content {
                max-width: 1200px;
                margin: 0 auto;
                padding: 0 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .logo h1 {
                font-size: 24px;
                font-weight: 600;
            }
            
            .user-info {
                display: flex;
                align-items: center;
                gap: 20px;
            }
            
            .user-info span {
                font-size: 14px;
            }
            
            .btn-logout {
                background: rgba(255,255,255,0.2);
                color: white;
                padding: 8px 20px;
                border-radius: 5px;
                text-decoration: none;
                font-size: 14px;
                transition: background 0.3s;
            }
            
            .btn-logout:hover {
                background: rgba(255,255,255,0.3);
            }
            
            /* Main Content */
            .container {
                max-width: 1200px;
                margin: 40px auto;
                padding: 0 20px;
            }
            
            .welcome-section {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                margin-bottom: 30px;
            }
            
            .welcome-section h2 {
                color: #333;
                font-size: 28px;
                margin-bottom: 10px;
            }
            
            .welcome-section p {
                color: #666;
                font-size: 16px;
            }
            
            .alert {
                padding: 15px;
                border-radius: 5px;
                margin-top: 20px;
            }
            
            .alert-warning {
                background: #fff3cd;
                border-left: 4px solid #ffc107;
                color: #856404;
            }
            
            .alert-info {
                background: #d1ecf1;
                border-left: 4px solid #17a2b8;
                color: #0c5460;
            }
            
            /* Menu Cards */
            .menu-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 20px;
            }
            
            .menu-card {
                background: white;
                padding: 25px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                transition: transform 0.3s, box-shadow 0.3s;
                text-decoration: none;
                color: inherit;
                display: block;
            }
            
            .menu-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 20px rgba(0,0,0,0.15);
            }
            
            .menu-card-icon {
                font-size: 40px;
                margin-bottom: 15px;
                font-weight: bold;
                color: #667eea;
                font-family: monospace;
            }
            
            .menu-card h3 {
                color: #333;
                font-size: 18px;
                margin-bottom: 10px;
            }
            
            .menu-card p {
                color: #666;
                font-size: 14px;
            }
            
            /* Footer */
            .footer {
                text-align: center;
                padding: 20px;
                color: #666;
                margin-top: 40px;
            }
        </style>
    </head>
    <body>
        <%
            // Verificar si hay sesión activa
            UsuarioRol usuarioRol = (UsuarioRol) session.getAttribute("usuarioRol");
            
            if (usuarioRol == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            // Obtener recursos permitidos para el rol del usuario
            RolRecursoBean rolRecursoBean = null;
            List<Recursos> listaRecursos = null;
            
            try {
                rolRecursoBean = new RolRecursoBean();
                listaRecursos = rolRecursoBean.listaRecursos(usuarioRol.getRol());                
            } catch(Exception e) {
                e.printStackTrace();
            }
            
            // Calcular días hasta vencimiento de password
            int diasVigencia = usuarioRol.getVigenciaDias();
            boolean passwordProximoVencer = diasVigencia >= -30 && diasVigencia < 0;
            boolean passwordVencido = diasVigencia >= 0;
        %>
        
        <!-- Header -->
        <div class="header">
            <div class="header-content">
                <div class="logo">
                    <h1>Sistema Veterinaria SigePet</h1>
                </div>
                <div class="user-info">
                    <span><%= usuarioRol.getNombreCompleto() %></span>
                    <span>|</span>
                    <span><%= usuarioRol.getRol() %></span>
                    <a href="logout" class="btn-logout">Cerrar Sesion</a>
                </div>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="container">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <h2>Bienvenido(a), <%= usuarioRol.getNombreCompleto() %>!</h2>
                <p>Has iniciado sesion correctamente en el Sistema de Gestion Veterinaria.</p>
                
                
            </div>
            
            <!-- Menu Grid -->
            <div class="menu-grid">
                <% 
                    if (listaRecursos != null && !listaRecursos.isEmpty()) {
                        for (Recursos recurso : listaRecursos) {
                            if ("ACTIVO".equals(recurso.getEstado())) {
                                String icono = "[*]";
                                String descripcion = "Acceso a " + recurso.getNombreEnlace().toLowerCase();
                                
                                // Asignar iconos segun el modulo
                                if (recurso.getNombreEnlace().contains("Propietario")) {
                                    icono = "👤";
                                    descripcion = "Gestion de propietarios y sus datos";
                                }
                                else if (recurso.getNombreEnlace().contains("Mascotas")) {
                                    icono = "🐶";
                                    descripcion = "Gestion de mascotas y expedientes";
                                }
                                else if (recurso.getNombreEnlace().contains("Usuario")) {
                                    icono = "👥";
                                    descripcion = "Registro y gestion de usuarios del sistema";
                                }
                                else if (recurso.getNombreEnlace().contains("Veterinario")) {
                                    icono = "👨‍⚕️";
                                    descripcion = "Gestion de veterinarios y horarios";
                                }
                                else if (recurso.getNombreEnlace().contains("Cita")) {
                                    icono = "📅";
                                    descripcion = "Gestion de citas medicas";
                                }
                                else if (recurso.getNombreEnlace().contains("Atencion")) {
                                    icono = "🏥";
                                    descripcion = "Registro de atenciones medicas";
                                }
                                else if (recurso.getNombreEnlace().contains("Pago")) {
                                    icono = "💰";
                                    descripcion = "Gestion de pagos y facturacion";
                                }
                                else if (recurso.getNombreEnlace().contains("Horario")) {
                                    icono = "🕐";
                                    descripcion = "Gestion de horarios";
                                }
                                else if (recurso.getNombreEnlace().contains("Reporte")) {
                                    icono = "📈";
                                    descripcion = "Reportes y estadisticas";
                                }
                %>
                                <a href="<%= recurso.getUrl() %>" class="menu-card">
                                    <div class="menu-card-icon"><%= icono %></div>
                                    <h3><%= recurso.getNombreEnlace() %></h3>
                                    <p><%= descripcion %></p>
                                </a>
                <%
                            }
                        }
                    } else {
                %>
                    <div class="menu-card">
                        <div class="menu-card-icon">[i]</div>
                        <h3>Sin recursos asignados</h3>
                        <p>No hay recursos disponibles para su rol actual.</p>
                    </div>
                <% } %>             
                    
            </div>
        </div>                                       
        
        <!-- Footer -->
        <div class="footer">
            <p>&copy; 2025 Sistema de Gestion Veterinaria - Todos los derechos reservados</p>
        </div>
        
        <%
            // Cerrar conexión del bean si existe
            if (rolRecursoBean != null) {
                try {
                    rolRecursoBean.cerrarConexion();
                } catch(Exception e) {
                    e.printStackTrace();
                }
            }
        %>
    </body>
</html>
