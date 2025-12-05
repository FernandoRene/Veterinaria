<%-- 
    Document   : listaVeterinarios
    Created on : Dec 2024
    Author     : Fernando
    Description: Lista de veterinarios registrados
--%>

<%@page import="com.dev.bean.VeterinarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lista de Veterinarios</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }
            
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: #f5f5f5;
                padding: 20px;
            }
            
            .container {
                max-width: 1200px;
                margin: 0 auto;
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            
            .header {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                padding: 20px;
                border-radius: 10px 10px 0 0;
                margin: -30px -30px 30px -30px;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }
            
            .header-content h1 {
                font-size: 24px;
                margin-bottom: 5px;
            }
            
            .header-content p {
                font-size: 14px;
                opacity: 0.9;
            }
            
            .btn {
                padding: 10px 20px;
                border: none;
                border-radius: 5px;
                font-size: 14px;
                font-weight: 600;
                cursor: pointer;
                text-decoration: none;
                display: inline-block;
                transition: transform 0.2s;
            }
            
            .btn:hover {
                transform: translateY(-2px);
            }
            
            .btn-success {
                background: #28a745;
                color: white;
            }
            
            .btn-primary {
                background: #667eea;
                color: white;
            }
            
            .btn-warning {
                background: #ffc107;
                color: #333;
            }
            
            .btn-sm {
                padding: 5px 10px;
                font-size: 12px;
            }
            
            .back-link {
                display: inline-block;
                color: #667eea;
                text-decoration: none;
                margin-bottom: 20px;
                font-size: 14px;
            }
            
            .back-link:hover {
                text-decoration: underline;
            }
            
            .actions-bar {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
                padding: 15px;
                background: #f8f9fa;
                border-radius: 5px;
            }
            
            table {
                width: 100%;
                border-collapse: collapse;
                margin-top: 20px;
            }
            
            thead {
                background: #667eea;
                color: white;
            }
            
            th {
                padding: 12px;
                text-align: left;
                font-weight: 600;
            }
            
            td {
                padding: 12px;
                border-bottom: 1px solid #dee2e6;
            }
            
            tbody tr:hover {
                background: #f8f9fa;
            }
            
            .badge {
                padding: 4px 12px;
                border-radius: 12px;
                font-size: 12px;
                font-weight: 600;
            }
            
            .badge-success {
                background: #d4edda;
                color: #155724;
            }
            
            .badge-secondary {
                background: #e2e3e5;
                color: #383d41;
            }
            
            .no-data {
                text-align: center;
                padding: 40px;
                color: #6c757d;
            }
            
            .no-data-icon {
                font-size: 48px;
                margin-bottom: 10px;
            }
            
            .alert {
                padding: 15px;
                border-radius: 5px;
                margin-bottom: 20px;
            }
            
            .alert-info {
                background: #d1ecf1;
                border-left: 4px solid #17a2b8;
                color: #0c5460;
            }
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
            
            // Obtener lista de veterinarios
            String listaHTML = "";
            int totalVeterinarios = 0;
            
            try {
                VeterinarioBean bean = new VeterinarioBean();
                listaHTML = bean.listadoVeterinarios();
                bean.cerrarConexion();
                
                // Contar veterinarios (aproximado)
                if (listaHTML != null && !listaHTML.isEmpty()) {
                    totalVeterinarios = listaHTML.split("<tr>").length - 1;
                }
            } catch (Exception e) {
                e.printStackTrace();
                listaHTML = "";
            }
        %>
        
        <div class="container">
            <div class="header">
                <div class="header-content">
                    <h1>👨‍⚕️ Lista de Veterinarios</h1>
                    <p>Gestión de veterinarios de la clínica</p>
                </div>
                <a href="registroVeterinario.jsp" class="btn btn-success">
                    ➕ Nuevo Veterinario
                </a>
            </div>
            
            <a href="index.jsp" class="back-link">← Volver al inicio</a>
            
            <!-- Barra de acciones -->
            <div class="actions-bar">
                <div>
                    <strong>Total de veterinarios:</strong> <%= totalVeterinarios %>
                </div>
                <div>
                    <button onclick="window.print()" class="btn btn-primary btn-sm">
                        🖨️ Imprimir
                    </button>
                </div>
            </div>
            
            <!-- Mensaje informativo -->
            <% if (totalVeterinarios == 0) { %>
                <div class="alert alert-info">
                    ℹ️ <strong>Información:</strong> No hay veterinarios registrados aún. 
                    Haga click en "Nuevo Veterinario" para agregar el primero.
                </div>
            <% } %>
            
            <!-- Tabla de veterinarios -->
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
                <div class="no-data">
                    <div class="no-data-icon">🏥</div>
                    <h3>No hay veterinarios registrados</h3>
                    <p>Comience agregando un nuevo veterinario</p>
                    <br>
                    <a href="registroVeterinario.jsp" class="btn btn-success">
                        ➕ Registrar Primer Veterinario
                    </a>
                </div>
            <% } %>
            
        </div>
        
        <script>
            // Función para confirmar cambio de estado
            function confirmarCambio() {
                return confirm('¿Está seguro de cambiar el estado de este veterinario?');
            }
            
            // Función para refrescar la página
            function refrescar() {
                location.reload();
            }
        </script>
    </body>
</html>
