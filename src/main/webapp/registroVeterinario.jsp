<%-- 
    Document   : registroVeterinario
    Created on : Dec 2024
    Author     : Fernando
    Description: Formulario para registrar nuevos veterinarios
--%>

<%@page import="com.dev.bean.VeterinarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Registro de Veterinario</title>
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
                max-width: 800px;
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
            }
            
            .header h1 {
                font-size: 24px;
                margin-bottom: 5px;
            }
            
            .header p {
                font-size: 14px;
                opacity: 0.9;
            }
            
            .form-group {
                margin-bottom: 20px;
            }
            
            .form-group label {
                display: block;
                color: #333;
                font-weight: 500;
                margin-bottom: 8px;
            }
            
            .form-group label .required {
                color: #dc3545;
                margin-left: 3px;
            }
            
            .form-group input,
            .form-group select {
                width: 100%;
                padding: 12px;
                border: 1px solid #ddd;
                border-radius: 5px;
                font-size: 14px;
                transition: border-color 0.3s;
            }
            
            .form-group input:focus,
            .form-group select:focus {
                outline: none;
                border-color: #667eea;
            }
            
            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }
            
            .btn-container {
                display: flex;
                gap: 10px;
                margin-top: 30px;
            }
            
            .btn {
                padding: 12px 30px;
                border: none;
                border-radius: 5px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s;
            }
            
            .btn:hover {
                transform: translateY(-2px);
            }
            
            .btn-primary {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                flex: 1;
            }
            
            .btn-secondary {
                background: #6c757d;
                color: white;
                flex: 1;
            }
            
            .alert {
                padding: 15px;
                border-radius: 5px;
                margin-bottom: 20px;
            }
            
            .alert-success {
                background: #d4edda;
                border-left: 4px solid #28a745;
                color: #155724;
            }
            
            .alert-error {
                background: #f8d7da;
                border-left: 4px solid #dc3545;
                color: #721c24;
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
            
            // Variable para mensaje
            String mensaje = "";
            boolean mostrarMensaje = false;
            boolean esError = false;
            
            // Procesar formulario si viene POST
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                try {
                    VeterinarioBean bean = new VeterinarioBean();
                    mensaje = bean.registrarVeterinario(request);
                    mostrarMensaje = true;
                    
                    // Determinar si es error
                    if (mensaje.toLowerCase().contains("error") || 
                        mensaje.toLowerCase().contains("duplicad")) {
                        esError = true;
                    }
                    
                    bean.cerrarConexion();
                } catch (Exception e) {
                    mensaje = "Error al procesar el registro: " + e.getMessage();
                    mostrarMensaje = true;
                    esError = true;
                    e.printStackTrace();
                }
            }
        %>
        
        <div class="container">
            <div class="header">
                <h1>🏥 Registro de Veterinario</h1>
                <p>Complete todos los campos para registrar un nuevo veterinario</p>
            </div>
            
            <a href="listaVeterinarios.jsp" class="back-link">← Volver a lista de veterinarios</a>
            
            <!-- Mensaje de resultado -->
            <% if (mostrarMensaje) { %>
                <div class="alert <%= esError ? "alert-error" : "alert-success" %>">
                    <%= mensaje %>
                </div>
            <% } %>
            
            <!-- Formulario -->
            <form method="POST" action="registroVeterinario.jsp" onsubmit="return validarFormulario()">
                
                <!-- Datos Personales -->
                <h3 style="color: #333; margin-bottom: 20px;">📋 Datos Personales</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="nombreV">Nombre <span class="required">*</span></label>
                        <input type="text" 
                               id="nombreV" 
                               name="nombreV" 
                               placeholder="Ingrese el nombre"
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label for="paternoV">Apellido Paterno <span class="required">*</span></label>
                        <input type="text" 
                               id="paternoV" 
                               name="paternoV" 
                               placeholder="Ingrese el apellido paterno"
                               required>
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="maternoV">Apellido Materno</label>
                        <input type="text" 
                               id="maternoV" 
                               name="maternoV" 
                               placeholder="Ingrese el apellido materno">
                    </div>
                    
                    <div class="form-group">
                        <label for="ciV">Cédula de Identidad <span class="required">*</span></label>
                        <input type="text" 
                               id="ciV" 
                               name="ciV" 
                               placeholder="Ej: 12345678"
                               required>
                    </div>
                </div>
                
                <!-- Datos Profesionales -->
                <h3 style="color: #333; margin: 30px 0 20px 0;">🎓 Datos Profesionales</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="matriculaV">Matrícula Profesional <span class="required">*</span></label>
                        <input type="text" 
                               id="matriculaV" 
                               name="matriculaV" 
                               placeholder="Ej: VET-001"
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label for="especialidadV">Especialidad <span class="required">*</span></label>
                        <select id="especialidadV" name="especialidadV" required>
                            <option value="">Seleccione una especialidad</option>
                            <option value="Medicina General">Medicina General</option>
                            <option value="Cirugía">Cirugía</option>
                            <option value="Dermatología">Dermatología</option>
                            <option value="Cardiología">Cardiología</option>
                            <option value="Oftalmología">Oftalmología</option>
                            <option value="Nutrición">Nutrición</option>
                            <option value="Emergencias">Emergencias</option>
                        </select>
                    </div>
                </div>
                
                <!-- Datos de Contacto -->
                <h3 style="color: #333; margin: 30px 0 20px 0;">📞 Datos de Contacto</h3>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="telefonoV">Teléfono</label>
                        <input type="tel" 
                               id="telefonoV" 
                               name="telefonoV" 
                               placeholder="Ej: 71234567">
                    </div>
                    
                    <div class="form-group">
                        <label for="emailV">Email</label>
                        <input type="email" 
                               id="emailV" 
                               name="emailV" 
                               placeholder="Ej: veterinario@clinica.com">
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="direccionV">Dirección</label>
                    <input type="text" 
                           id="direccionV" 
                           name="direccionV" 
                           placeholder="Ingrese la dirección completa">
                </div>
                
                <!-- Botones -->
                <div class="btn-container">
                    <button type="submit" class="btn btn-primary">
                        💾 Guardar Veterinario
                    </button>
                    <button type="button" class="btn btn-secondary" onclick="limpiarFormulario()">
                        🔄 Limpiar
                    </button>
                </div>
                
            </form>
        </div>
        
        <script>
            // Validación del formulario
            function validarFormulario() {
                const nombre = document.getElementById('nombreV').value.trim();
                const paterno = document.getElementById('paternoV').value.trim();
                const ci = document.getElementById('ciV').value.trim();
                const matricula = document.getElementById('matriculaV').value.trim();
                const especialidad = document.getElementById('especialidadV').value;
                
                if (!nombre || !paterno || !ci || !matricula || !especialidad) {
                    alert('Por favor complete todos los campos obligatorios (*)');
                    return false;
                }
                
                // Validar que CI solo tenga números
                if (!/^\d+$/.test(ci)) {
                    alert('La cédula de identidad debe contener solo números');
                    return false;
                }
                
                // Validar longitud mínima de CI
                if (ci.length < 6) {
                    alert('La cédula de identidad debe tener al menos 6 dígitos');
                    return false;
                }
                
                return confirm('¿Está seguro de registrar este veterinario?');
            }
            
            // Limpiar formulario
            function limpiarFormulario() {
                if (confirm('¿Está seguro de limpiar el formulario?')) {
                    document.querySelector('form').reset();
                }
            }
            
            // Validación en tiempo real del email
            document.getElementById('emailV').addEventListener('blur', function() {
                const email = this.value;
                if (email && !email.includes('@')) {
                    alert('Por favor ingrese un email válido');
                    this.focus();
                }
            });
            
            // Validación en tiempo real del teléfono
            document.getElementById('telefonoV').addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
            });
            
            // Validación en tiempo real de CI
            document.getElementById('ciV').addEventListener('input', function() {
                this.value = this.value.replace(/[^0-9]/g, '');
            });
        </script>
    </body>
</html>
