<%@page import="com.dev.bean.PropietarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lista de Propietarios</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; display: flex; justify-content: space-between; align-items: center; }
            .header h1 { font-size: 24px; }
            .btn { padding: 10px 20px; border: none; border-radius: 5px; font-size: 14px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; transition: transform 0.2s; }
            .btn:hover { transform: translateY(-2px); }
            .btn-success { background: #28a745; color: white; }
            .btn-primary { background: #667eea; color: white; }
            .btn-warning { background: #ffc107; color: #333; }
            .btn-sm { padding: 5px 10px; font-size: 12px; }
            .back-link { display: inline-block; color: #667eea; text-decoration: none; margin-bottom: 20px; }
            .back-link:hover { text-decoration: underline; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            thead { background: #667eea; color: white; }
            th { padding: 12px; text-align: left; font-weight: 600; }
            td { padding: 12px; border-bottom: 1px solid #dee2e6; }
            tbody tr:hover { background: #f8f9fa; }
            .no-data { text-align: center; padding: 40px; color: #6c757d; }
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
            
            // Procesar eliminación si viene el parámetro
            String idEliminar = request.getParameter("id");
            String mensajeEliminar = "";
            if (idEliminar != null) {
                try {
                    PropietarioBean bean = new PropietarioBean();
                    mensajeEliminar = bean.eliminarPropietario(idEliminar);
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensajeEliminar = "Error al eliminar: " + e.getMessage();
                }
            }
            
            // Obtener lista
            String listaHTML = "";
            try {
                PropietarioBean bean = new PropietarioBean();
                listaHTML = bean.listadoPropietarios();
                bean.cerrarConexion();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        
        <div class="container">
            <div class="header">
                <div>
                    <h1>👥 Lista de Propietarios</h1>
                    <p>Gestión de propietarios de mascotas</p>
                </div>
                <a href="registroPropietario.jsp" class="btn btn-success">➕ Nuevo Propietario</a>
            </div>
            
            <a href="index.jsp" class="back-link">← Volver al inicio</a>
            
            <% if (mensajeEliminar != null && !mensajeEliminar.isEmpty()) { %>
                <div style="padding: 15px; background: <%= mensajeEliminar.contains("Error") ? "#f8d7da" : "#d4edda" %>; border-radius: 5px; margin-bottom: 20px;">
                    <%= mensajeEliminar %>
                </div>
            <% } %>
            
            <% if (listaHTML != null && !listaHTML.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nombre</th>
                            <th>Apellido Paterno</th>
                            <th>Apellido Materno</th>
                            <th>Dirección</th>
                            <th>Teléfono</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= listaHTML %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="no-data">
                    <div style="font-size: 48px; margin-bottom: 10px;">👥</div>
                    <h3>No hay propietarios registrados</h3>
                    <p>Comience agregando un nuevo propietario</p>
                    <br>
                    <a href="registroPropietario.jsp" class="btn btn-success">➕ Registrar Propietario</a>
                </div>
            <% } %>
        </div>
        
        <script>
            function confirmarEliminacion() {
                return confirm('¿Está seguro de eliminar este propietario?\nEsta acción no se puede deshacer.');
            }
        </script>
    </body>
</html>
