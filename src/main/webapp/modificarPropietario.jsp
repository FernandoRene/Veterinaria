<%@page import="com.dev.bean.PropietarioBean"%>
<%@page import="com.dev.clases.Propietario"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modificar Propietario</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; }
            .header h1 { font-size: 24px; }
            .form-group { margin-bottom: 20px; }
            .form-group label { display: block; color: #333; font-weight: 500; margin-bottom: 8px; }
            .form-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
            .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
            .btn { padding: 12px 30px; border: none; border-radius: 5px; font-size: 16px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; text-align: center; }
            .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; flex: 1; }
            .btn-secondary { background: #6c757d; color: white; flex: 1; }
            .btn-container { display: flex; gap: 10px; margin-top: 30px; }
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
            
            String idPropietario = request.getParameter("id");
            Propietario prop = null;
            
            // Procesar modificación
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    PropietarioBean bean = new PropietarioBean();
                    mensaje = bean.modificarPropietario(request, idPropietario);
                    mostrarMensaje = true;
                    esError = mensaje.toLowerCase().contains("error");
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensaje = "Error: " + e.getMessage();
                    mostrarMensaje = true;
                    esError = true;
                }
            }
            
            // Buscar propietario
            if (idPropietario != null) {
                try {
                    PropietarioBean bean = new PropietarioBean();
                    prop = bean.buscar(Integer.parseInt(idPropietario));
                    bean.cerrarConexion();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
            if (prop == null) {
                response.sendRedirect("listaPropietario.jsp");
                return;
            }
        %>
        
        <div class="container">
            <div class="header">
                <h1>✏️ Modificar Propietario</h1>
                <p>Actualice los datos del propietario</p>
            </div>
            
            <a href="listaPropietario.jsp" class="back-link">← Volver a lista</a>
            
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="POST" action="modificarPropietario.jsp?id=<%= idPropietario %>">
                <div class="form-row">
                    <div class="form-group">
                        <label>Nombre *</label>
                        <input type="text" name="nombreP" value="<%= prop.getNomProp() %>" required>
                    </div>
                    <div class="form-group">
                        <label>Apellido Paterno *</label>
                        <input type="text" name="paternoP" value="<%= prop.getPatProp() %>" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Apellido Materno</label>
                    <input type="text" name="maternoP" value="<%= prop.getMatProp() != null ? prop.getMatProp() : "" %>">
                </div>
                
                <div class="form-group">
                    <label>Dirección</label>
                    <input type="text" name="direccionP" value="<%= prop.getDirProp() != null ? prop.getDirProp() : "" %>">
                </div>
                
                <div class="form-group">
                    <label>Teléfono</label>
                    <input type="tel" name="telefonoP" value="<%= prop.getTelProp() != null ? prop.getTelProp() : "" %>">
                </div>
                
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">💾 Actualizar</button>
                    <a href="listaPropietario.jsp" class="btn btn-secondary">❌ Cancelar</a>
                </div>
            </form>
        </div>
    </body>
</html>
