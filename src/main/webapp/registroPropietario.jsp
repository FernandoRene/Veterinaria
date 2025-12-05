<%@page import="com.dev.bean.PropietarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Propietario</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; }
            .header h1 { font-size: 24px; margin-bottom: 5px; }
            .form-group { margin-bottom: 20px; }
            .form-group label { display: block; color: #333; font-weight: 500; margin-bottom: 8px; }
            .form-group label .required { color: #dc3545; }
            .form-group input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
            .form-group input:focus { outline: none; border-color: #667eea; }
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
            
            String mensaje = "";
            boolean mostrarMensaje = false;
            boolean esError = false;
            
            // Procesar formulario
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    PropietarioBean bean = new PropietarioBean();
                    mensaje = bean.registrarPropietario(request);
                    mostrarMensaje = true;
                    esError = mensaje.toLowerCase().contains("error");
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensaje = "Error: " + e.getMessage();
                    mostrarMensaje = true;
                    esError = true;
                }
            }
        %>
        
        <div class="container">
            <div class="header">
                <h1>👤 Registro de Propietario</h1>
                <p>Complete los datos del nuevo propietario</p>
            </div>
            
            <a href="listaPropietario.jsp" class="back-link">← Volver a lista</a>
            
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <form method="POST" action="registroPropietario.jsp" onsubmit="return validar()">
                <div class="form-row">
                    <div class="form-group">
                        <label>Nombre <span class="required">*</span></label>
                        <input type="text" name="nombreP" id="nombreP" required>
                    </div>
                    <div class="form-group">
                        <label>Apellido Paterno <span class="required">*</span></label>
                        <input type="text" name="paternoP" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Apellido Materno</label>
                    <input type="text" name="maternoP">
                </div>
                
                <div class="form-group">
                    <label>Dirección</label>
                    <input type="text" name="direccionP">
                </div>
                
                <div class="form-group">
                    <label>Teléfono</label>
                    <input type="tel" name="telefonoP" id="telefonoP">
                </div>
                
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">💾 Guardar</button>
                    <button type="button" class="btn btn-secondary" onclick="limpiar()">🔄 Limpiar</button>
                </div>
            </form>
        </div>
        
        <script>
            function validar() {
                const nombre = document.getElementById('nombreP').value.trim();
                if (!nombre) {
                    alert('El nombre es obligatorio');
                    return false;
                }
                return confirm('¿Desea registrar este propietario?');
            }
            
            function limpiar() {
                if (confirm('¿Desea limpiar el formulario?')) {
                    document.querySelector('form').reset();
                }
            }
            
            // Validar solo números en teléfono
            document.getElementById('telefonoP').addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
            });
        </script>
    </body>
</html>
