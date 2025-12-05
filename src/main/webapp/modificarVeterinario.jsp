<%@page import="com.dev.bean.VeterinarioBean"%>
<%@page import="com.dev.clases.Veterinario"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Modificar Veterinario</title>
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
            
            // Obtener ID del veterinario
            String idVeterinario = request.getParameter("id");
            Veterinario vet = null;
            
            // Procesar modificación si viene POST
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    VeterinarioBean bean = new VeterinarioBean();
                    mensaje = bean.modificarVeterinario(request, idVeterinario);
                    mostrarMensaje = true;
                    esError = mensaje.toLowerCase().contains("error");
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensaje = "Error: " + e.getMessage();
                    mostrarMensaje = true;
                    esError = true;
                }
            }
            
            // Buscar datos del veterinario
            if (idVeterinario != null) {
                try {
                    VeterinarioBean bean = new VeterinarioBean();
                    vet = bean.buscarVeterinario(Integer.parseInt(idVeterinario));
                    bean.cerrarConexion();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            
            // Si no se encontró el veterinario, redirigir
            if (vet == null) {
                response.sendRedirect("listaVeterinarios.jsp");
                return;
            }
        %>
        
        <div class="container">
            <div class="header">
                <h1>✏️ Modificar Veterinario</h1>
                <p>Actualice los datos del veterinario</p>
            </div>
            
            <a href="listaVeterinarios.jsp" class="back-link">← Volver a lista</a>
            
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="POST" action="modificarVeterinario.jsp?id=<%= idVeterinario %>">
                <h3 style="color: #333; margin-bottom: 20px;">📋 Datos Personales</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Nombre *</label>
                        <input type="text" name="nombreV" value="<%= vet.getNombreVet() %>" required>
                    </div>
                    <div class="form-group">
                        <label>Apellido Paterno *</label>
                        <input type="text" name="paternoV" value="<%= vet.getPaternoVet() %>" required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Apellido Materno</label>
                        <input type="text" name="maternoV" value="<%= vet.getMaternoVet() != null ? vet.getMaternoVet() : "" %>">
                    </div>
                    <div class="form-group">
                        <label>CI *</label>
                        <input type="text" name="ciV" value="<%= vet.getCiVet() %>" required>
                    </div>
                </div>
                
                <h3 style="color: #333; margin: 30px 0 20px 0;">🎓 Datos Profesionales</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Matrícula *</label>
                        <input type="text" name="matriculaV" value="<%= vet.getMatriculaProfesional() %>" required>
                    </div>
                    <div class="form-group">
                        <label>Especialidad *</label>
                        <select name="especialidadV" required>
                            <option value="Medicina General" <%= "Medicina General".equals(vet.getEspecialidad()) ? "selected" : "" %>>Medicina General</option>
                            <option value="Cirugía" <%= "Cirugía".equals(vet.getEspecialidad()) ? "selected" : "" %>>Cirugía</option>
                            <option value="Dermatología" <%= "Dermatología".equals(vet.getEspecialidad()) ? "selected" : "" %>>Dermatología</option>
                            <option value="Cardiología" <%= "Cardiología".equals(vet.getEspecialidad()) ? "selected" : "" %>>Cardiología</option>
                            <option value="Oftalmología" <%= "Oftalmología".equals(vet.getEspecialidad()) ? "selected" : "" %>>Oftalmología</option>
                            <option value="Nutrición" <%= "Nutrición".equals(vet.getEspecialidad()) ? "selected" : "" %>>Nutrición</option>
                            <option value="Emergencias" <%= "Emergencias".equals(vet.getEspecialidad()) ? "selected" : "" %>>Emergencias</option>
                        </select>
                    </div>
                </div>
                
                <h3 style="color: #333; margin: 30px 0 20px 0;">📞 Datos de Contacto</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Teléfono</label>
                        <input type="tel" name="telefonoV" value="<%= vet.getTelefono() != null ? vet.getTelefono() : "" %>">
                    </div>
                    <div class="form-group">
                        <label>Email</label>
                        <input type="email" name="emailV" value="<%= vet.getEmail() != null ? vet.getEmail() : "" %>">
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Dirección</label>
                    <input type="text" name="direccionV" value="<%= vet.getDireccion() != null ? vet.getDireccion() : "" %>">
                </div>
                
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">💾 Actualizar</button>
                    <a href="listaVeterinarios.jsp" class="btn btn-secondary" style="text-align: center; line-height: 1.5;">❌ Cancelar</a>
                </div>
            </form>
        </div>
    </body>
</html>
