<%@page import="com.dev.bean.MascotaBean"%>
<%@page import="com.dev.bean.PropietarioBean"%>
<%@page import="com.dev.clases.Mascota"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modificar Mascota</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; }
            .header h1 { font-size: 24px; }
            .form-group { margin-bottom: 20px; }
            .form-group label { display: block; color: #333; font-weight: 500; margin-bottom: 8px; }
            .form-group input, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
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
            
            String idMascota = request.getParameter("id");
            Mascota mascota = null;
            
            // Procesar modificación
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    MascotaBean bean = new MascotaBean();
                    mensaje = bean.modificarMascota(request, idMascota);
                    mostrarMensaje = true;
                    esError = mensaje.toLowerCase().contains("error");
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensaje = "Error: " + e.getMessage();
                    mostrarMensaje = true;
                    esError = true;
                }
            }
            
            // Buscar mascota
            if (idMascota != null) {
                try {
                    MascotaBean bean = new MascotaBean();
                    mascota = bean.buscarMascota(Integer.parseInt(idMascota));
                    bean.cerrarConexion();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
            if (mascota == null) {
                response.sendRedirect("listaMascota.jsp");
                return;
            }
            
            // Obtener propietarios
            String propietariosOptions = "";
            try {
                PropietarioBean propBean = new PropietarioBean();
                propietariosOptions = propBean.listaPropietarioSelect();
                propBean.cerrarConexion();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        
        <div class="container">
            <div class="header">
                <h1>✏️ Modificar Mascota</h1>
                <p>Actualice los datos de la mascota</p>
            </div>
            
            <a href="listaMascota.jsp" class="back-link">← Volver a lista</a>
            
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="POST" action="modificarMascota.jsp?id=<%= idMascota %>">
                <div class="form-group">
                    <label>Nombre *</label>
                    <input type="text" name="nombreM" value="<%= mascota.getNomMas() %>" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Raza *</label>
                        <input type="text" name="razaM" value="<%= mascota.getRazaMas() %>" required>
                    </div>
                    <div class="form-group">
                        <label>Especie *</label>
                        <select name="especieM" required>
                            <option value="Perro" <%= "Perro".equals(mascota.getEspecie()) ? "selected" : "" %>>Perro</option>
                            <option value="Gato" <%= "Gato".equals(mascota.getEspecie()) ? "selected" : "" %>>Gato</option>
                            <option value="Ave" <%= "Ave".equals(mascota.getEspecie()) ? "selected" : "" %>>Ave</option>
                            <option value="Conejo" <%= "Conejo".equals(mascota.getEspecie()) ? "selected" : "" %>>Conejo</option>
                            <option value="Hamster" <%= "Hamster".equals(mascota.getEspecie()) ? "selected" : "" %>>Hamster</option>
                            <option value="Otro" <%= "Otro".equals(mascota.getEspecie()) ? "selected" : "" %>>Otro</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Color</label>
                        <input type="text" name="colorM" value="<%= mascota.getColorMas() != null ? mascota.getColorMas() : "" %>">
                    </div>
                    <div class="form-group">
                        <label>Sexo *</label>
                        <select name="sexoM" required>
                            <option value="Macho" <%= "Macho".equals(mascota.getSexoMas()) ? "selected" : "" %>>Macho</option>
                            <option value="Hembra" <%= "Hembra".equals(mascota.getSexoMas()) ? "selected" : "" %>>Hembra</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Propietario *</label>
                    <select name="propietarioM" required>
                        <%= propietariosOptions %>
                    </select>
                </div>
                
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">💾 Actualizar</button>
                    <a href="listaMascota.jsp" class="btn btn-secondary">❌ Cancelar</a>
                </div>
            </form>
        </div>
        
        <script>
            // Seleccionar el propietario actual
            window.onload = function() {
                var select = document.querySelector('select[name="propietarioM"]');
                var currentProp = '<%= mascota.getPropietario() != null ? mascota.getPropietario().getIdProp() : "" %>';
                if (currentProp && select) {
                    select.value = currentProp;
                }
            };
        </script>
    </body>
</html>
