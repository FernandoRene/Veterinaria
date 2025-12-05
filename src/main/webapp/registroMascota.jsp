<%@page import="com.dev.bean.MascotaBean"%>
<%@page import="com.dev.bean.PropietarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Mascota</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; }
            .header h1 { font-size: 24px; margin-bottom: 5px; }
            .form-group { margin-bottom: 20px; }
            .form-group label { display: block; color: #333; font-weight: 500; margin-bottom: 8px; }
            .form-group label .required { color: #dc3545; }
            .form-group input, .form-group select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
            .form-group input:focus, .form-group select:focus { outline: none; border-color: #667eea; }
            .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
            .btn-container { display: flex; gap: 10px; margin-top: 30px; }
            .btn { padding: 12px 30px; border: none; border-radius: 5px; font-size: 16px; font-weight: 600; cursor: pointer; transition: transform 0.2s; }
            .btn:hover { transform: translateY(-2px); }
            .btn-primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; flex: 1; }
            .btn-secondary { background: #6c757d; color: white; flex: 1; }
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
            
            // Mostrar mensaje si viene del controlador
            String mensaje = (String) request.getAttribute("mensajeRegistro");
            boolean mostrarMensaje = mensaje != null && !mensaje.isEmpty();
            boolean esError = mostrarMensaje && mensaje.toLowerCase().contains("error");
        %>
        
        <div class="container">
            <div class="header">
                <h1>🐕 Registro de Mascota</h1>
                <p>Complete los datos de la nueva mascota</p>
            </div>
            
            <a href="listaMascota.jsp" class="back-link">← Volver a lista</a>
            
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="POST" action="MascotaServlet" enctype="multipart/form-data" onsubmit="return validar()">
                <h3 style="color: #333; margin-bottom: 20px;">📋 Datos de la Mascota</h3>
                
                <div class="form-group">
                    <label>Nombre <span class="required">*</span></label>
                    <input type="text" name="nombreM" id="nombreM" required>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Raza <span class="required">*</span></label>
                        <input type="text" name="razaM" required>
                    </div>
                    <div class="form-group">
                        <label>Especie (Tipo) <span class="required">*</span></label>
                        <select name="tipoM" required>
                            <option value="">Seleccione</option>
                            <option value="Perro">Perro</option>
                            <option value="Gato">Gato</option>
                            <option value="Ave">Ave</option>
                            <option value="Conejo">Conejo</option>
                            <option value="Hamster">Hamster</option>
                            <option value="Otro">Otro</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Color</label>
                        <input type="text" name="colorM">
                    </div>
                    <div class="form-group">
                        <label>Sexo <span class="required">*</span></label>
                        <select name="genero" required>
                            <option value="">Seleccione</option>
                            <option value="Macho">Macho</option>
                            <option value="Hembra">Hembra</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label>Peso (kg)</label>
                        <input type="number" name="pesoM" step="0.1" min="0">
                    </div>
                    <div class="form-group">
                        <label>Fecha de Nacimiento</label>
                        <input type="date" name="fMascota">
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Propietario <span class="required">*</span></label>
                    <select name="idPropietario" required>
                        <option value="">Seleccione un propietario</option>
                        <%
                            String listaHTML = "";
                            try {
                                PropietarioBean bean = new PropietarioBean();
                                listaHTML = bean.listadoPropietariosParaSelect();
                                bean.cerrarConexion();
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        %>
                        <%= listaHTML %>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Foto de la Mascota (Opcional - Máx. 2MB)</label>
                    <input type="file" name="fotoMascota" id="fotoMascota" accept="image/*" onchange="validarImagen(this)">
                    <small style="color:#666; font-size:12px;">Formatos: JPG, PNG, GIF. Tamaño máximo: 2MB</small>
                </div>
                
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">💾 Guardar</button>
                    <button type="button" class="btn btn-secondary" onclick="limpiar()">🔄 Limpiar</button>
                </div>
            </form>
        </div>
        
        <script>
            function validarImagen(input) {
                if (input.files && input.files[0]) {
                    const file = input.files[0];
                    const maxSize = 2 * 1024 * 1024; // 2MB en bytes

                    // Validar tamaño
                    if (file.size > maxSize) {
                        alert('La imagen es demasiado grande. El tamaño máximo es 2MB.');
                        input.value = ''; // Limpiar el input
                        return false;
                    }

                    // Validar tipo de archivo
                    const validTypes = ['image/jpeg', 'image/png', 'image/gif'];
                    if (!validTypes.includes(file.type)) {
                        alert('Formato no válido. Use JPG, PNG o GIF.');
                        input.value = '';
                        return false;
                    }

                    // Previsualización opcional
                    const reader = new FileReader();
                    reader.onload = function(e) {
                        document.getElementById('preview').innerHTML = 
                            '<img src="' + e.target.result + '" style="max-width:150px;margin-top:10px;border-radius:5px;">';
                    }
                    reader.readAsDataURL(file);
                }
            }

            </script>
    </body>
</html>