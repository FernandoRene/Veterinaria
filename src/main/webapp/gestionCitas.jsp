<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="com.dev.bean.CitaBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
 HttpSession sesion = request.getSession(false);
    
    if (sesion == null || sesion.getAttribute("usuarioRol") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    request.setCharacterEncoding("UTF-8");
    
    UsuarioRol usuarioRol = (UsuarioRol) sesion.getAttribute("usuarioRol");
    String codigoUsuario = usuarioRol.getCodigo();
    Integer idUsuarioObj = (Integer) session.getAttribute("id_usuario");
    int idUsuario = (idUsuarioObj != null) ? idUsuarioObj : 0;
    
    String mensaje = request.getParameter("mensaje");
    String error = request.getParameter("error");
    String tabActiva = request.getParameter("tab");
    if (tabActiva == null || tabActiva.isEmpty()) {
        tabActiva = "lista";
    }
      
    CitaBean bean = new CitaBean();
    // Procesar registro si viene del formulario
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("accion") != null) {
    String accion = request.getParameter("accion");
    
    if ("registrar".equals(accion)) {
        try {
            int idMascota = Integer.parseInt(request.getParameter("idMascota"));
            int idVeterinario = Integer.parseInt(request.getParameter("idVeterinario"));
            String tipoConsulta = request.getParameter("tipoConsulta");
            String fechaCita = request.getParameter("fechaCita");
            String horaCita = request.getParameter("horaCita");
            int duracionMinutos = Integer.parseInt(request.getParameter("duracionMinutos"));
            String motivo = request.getParameter("motivo");
            
            boolean resultado = bean.registrarCita(idMascota, idVeterinario, tipoConsulta,
                                                   fechaCita, horaCita, duracionMinutos,
                                                   motivo, idUsuario);
            
            if (resultado) {
                mensaje = "Cita registrada exitosamente";
                tabActiva = "lista";
            } else {
                error = "Error al registrar cita";
                tabActiva = "registro";
            }
            
            } catch (Exception e) {
                error = "Error: " + e.getMessage();
                tabActiva = "registro";
            }
        }
    }  
    
    ArrayList<Map<String, String>> listaCitas = bean.listadoCitas();
    ArrayList<Map<String, String>> listaMascotas = bean.listadoMascotasActivas();
    ArrayList<Map<String, String>> listaVeterinarios = bean.listadoVeterinariosActivos();
    
    bean.cerrarConexion();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Citas Medicas</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        
        .container {
            max-width: 1600px;
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            overflow: hidden;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            text-align: center;
        }
        
        .header h1 {
            font-size: 2em;
            margin-bottom: 10px;
        }
        
        .user-info {
            background: rgba(255,255,255,0.2);
            padding: 10px 20px;
            border-radius: 8px;
            display: inline-block;
            margin-top: 10px;
        }
        
        .tabs {
            display: flex;
            background: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }
        
        .tab {
            flex: 1;
            padding: 15px 30px;
            text-align: center;
            cursor: pointer;
            background: #f8f9fa;
            border: none;
            font-size: 16px;
            font-weight: 600;
            color: #495057;
            transition: all 0.3s;
        }
        
        .tab:hover {
            background: #e9ecef;
        }
        
        .tab.active {
            background: white;
            color: #667eea;
            border-bottom: 3px solid #667eea;
        }
        
        .tab-content {
            display: none;
            padding: 30px;
            animation: fadeIn 0.3s;
        }
        
        .tab-content.active {
            display: block;
        }
        
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-weight: 500;
        }
        
        .alert-success {
            background: #d4edda;
            color: #155724;
            border-left: 4px solid #28a745;
        }
        
        .alert-error {
            background: #f8d7da;
            color: #721c24;
            border-left: 4px solid #dc3545;
        }
        
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .form-group {
            display: flex;
            flex-direction: column;
        }
        
        .form-group label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .form-group textarea {
            resize: vertical;
            min-height: 100px;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .btn-back {
            background: #6c757d;
            color: white;
            text-decoration: none;
            display: inline-block;
            margin-right: 10px;
        }
        
        .btn-back:hover {
            background: #5a6268;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        thead {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        
        th {
            padding: 15px 10px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 11px;
            letter-spacing: 0.5px;
        }
        
        td {
            padding: 12px 10px;
            border-bottom: 1px solid #e9ecef;
            font-size: 13px;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        
        .badge-programada {
            background: #cfe2ff;
            color: #084298;
        }
        
        .badge-confirmada {
            background: #d1e7dd;
            color: #0f5132;
        }
        
        .badge-en-atencion {
            background: #fff3cd;
            color: #664d03;
        }
        
        .badge-completada {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-cancelada {
            background: #f8d7da;
            color: #721c24;
        }
        
        .badge-no-asistio {
            background: #e7e7e7;
            color: #666;
        }
        
        .btn-action {
            padding: 6px 12px;
            font-size: 12px;
            margin-right: 5px;
            margin-bottom: 5px;
        }
        
        .btn-warning {
            background: #ffc107;
            color: #000;
        }
        
        .btn-danger {
            background: #dc3545;
            color: white;
        }
        
        .btn-success {
            background: #28a745;
            color: white;
        }
        
        .btn-info {
            background: #17a2b8;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .info-box {
            background: #e7f3ff;
            border-left: 4px solid #2196F3;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .info-box h4 {
            color: #1976D2;
            margin-bottom: 5px;
        }
    </style>
    <script>
        function cambiarTab(tabName) {
            const tabs = document.querySelectorAll('.tab');
            const contents = document.querySelectorAll('.tab-content');

            tabs.forEach(tab => tab.classList.remove('active'));
            contents.forEach(content => content.classList.remove('active'));

            const tabButton = document.getElementById('tab-' + tabName);
            const tabContent = document.getElementById(tabName);

            if (tabButton) tabButton.classList.add('active');
            if (tabContent) tabContent.classList.add('active');
        }
        
        function cambiarEstadoCita(idCita, estadoActual) {
            console.log("DEBUG: Cambiar estado cita ID:", idCita, "Estado actual:", estadoActual);

            let nuevoEstado = '';
            let mensaje = '';
            let icono = '';

            if (estadoActual === 'PROGRAMADA') {
                nuevoEstado = 'CONFIRMADA';
                mensaje = '✅ ¿Confirmar esta cita programada?\n\nLa cita pasará a estado: CONFIRMADA';
                icono = '✅';
            } else if (estadoActual === 'CONFIRMADA') {
                nuevoEstado = 'ATENDIDA';
                mensaje = '🏥 ¿Marcar esta cita como atendida?\n\nLa cita pasará a estado: ATENDIDA';
                icono = '🏥';
            } else {
                alert('⚠️ No se puede cambiar el estado de una cita ' + estadoActual);
                return;
            }

            console.log("DEBUG: Nuevo estado será:", nuevoEstado);

            if (confirm(icono + ' ' + mensaje)) {
                window.location.href = 'cambiarEstadoCita.jsp?id=' + idCita + '&estado=' + nuevoEstado;
            }
        }

        function cancelarCita(idCita) {
            if (confirm('❌ ¿Cancelar esta cita?\n\n⚠️ Esta acción no se puede deshacer.')) {
                window.location.href = 'cambiarEstadoCita.jsp?id=' + idCita + '&estado=CANCELADA';
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Gestion de Citas Medicas</h1>
            <div class="user-info">
                Usuario: <%= codigoUsuario %>
            </div>
        </div>
        
        <div class="tabs">
            <button id="tab-lista" class="tab <%= "lista".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('lista')">
                Lista de Citas
            </button>
            <button id="tab-registro" class="tab <%= "registro".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('registro')">
                Nueva Cita
            </button>
        </div>
        
        <!-- TAB: LISTA DE CITAS -->
        <div id="lista" class="tab-content <%= "lista".equals(tabActiva) ? "active" : "" %>">
            <% if (mensaje != null) { %>
                <div class="alert alert-success"><%= mensaje %></div>
            <% } %>
            
            <% if (error != null && "lista".equals(tabActiva)) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>
            
            <div style="margin-bottom: 20px;">
                <a href="index.jsp" class="btn btn-back">Volver al Menu</a>
            </div>
            
            <% if (listaCitas.isEmpty()) { %>
                <div class="empty-state">
                    <h3>No hay citas registradas</h3>
                    <p>Haga clic en "Nueva Cita" para agendar la primera cita</p>
                </div>
            <% } else { %>
                <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr>
                            <th>Nro Cita</th>
                            <th>Fecha/Hora</th>
                            <th>Mascota</th>
                            <th>Propietario</th>
                            <th>Veterinario</th>
                            <th>Tipo</th>
                            <th>Motivo</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> cita : listaCitas) { 
                            String estadoClass = cita.get("estado").toLowerCase().replace("_", "-");
                        %>
                        <tr>
                            <td><strong><%= cita.get("nro_cita") %></strong></td>
                            <td>
                                <%= cita.get("fecha_cita") %><br>
                                <small><%= cita.get("hora_cita") %> (<%= cita.get("duracion_minutos") %> min)</small>
                            </td>
                            <td>
                                <strong><%= cita.get("mascota") %></strong><br>
                                <small><%= cita.get("especie") %> - <%= cita.get("raza") %></small>
                            </td>
                            <td>
                                <%= cita.get("propietario") %><br>
                                <small><%= cita.get("telefono_propietario") %></small>
                            </td>
                            <td>
                                <%= cita.get("veterinario") %><br>
                                <small><%= cita.get("matricula_vet") %></small>
                            </td>
                            <td><%= cita.get("tipo_consulta") %></td>
                            <td><%= cita.get("motivo") %></td>
                            <td>
                            <% String estado = cita.get("estado"); %>
                            <% 
                                String badgeClass = "";
                                String icono = "";

                                if ("PROGRAMADA".equals(estado)) {
                                    badgeClass = "badge-warning";
                                    icono = "⏳";
                                } else if ("CONFIRMADA".equals(estado)) {
                                    badgeClass = "badge-primary";
                                    icono = "✅";
                                } else if ("ATENDIDA".equals(estado)) {
                                    badgeClass = "badge-success";
                                    icono = "🏥";
                                } else if ("CANCELADA".equals(estado)) {
                                    badgeClass = "badge-danger";
                                    icono = "❌";
                                }
                            %>
                            <span class="badge <%= badgeClass %>">
                                <%= icono %> <%= estado %>
                            </span>
                        </td>
                            <td>
                            <% 
                                estado = (String)cita.get("estado"); 
                                // Convertir a String y luego JavaScript lo manejará
                                String idCita = cita.get("id_cita").toString();
                            %>

                            <% if ("PROGRAMADA".equals(estado)) { %>
                                <button onclick="cambiarEstadoCita(<%= idCita %>, '<%= estado %>')" 
                                        class="btn btn-action btn-success">
                                    Confirmar
                                </button>
                                <button onclick="cancelarCita(<%= idCita %>)" 
                                        class="btn btn-action btn-danger">
                                    Cancelar
                                </button>

                            <% } else if ("CONFIRMADA".equals(estado)) { %>
                                <button onclick="cambiarEstadoCita(<%= idCita %>, '<%= estado %>')" 
                                        class="btn btn-action btn-info">
                                    Marcar Atendida
                                </button>
                                <button onclick="cancelarCita(<%= idCita %>)" 
                                        class="btn btn-action btn-danger">
                                    Cancelar
                                </button>

                            <% } else if ("ATENDIDA".equals(estado) || "CANCELADA".equals(estado)) { %>
                                <span class="text-muted">Sin acciones</span>
                            <% } %>
                        </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                </div>
            <% } %>
        </div>
        
        <!-- TAB: NUEVA CITA -->
        <div id="registro" class="tab-content <%= "registro".equals(tabActiva) ? "active" : "" %>">
            <% if (error != null && "registro".equals(tabActiva)) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>
            
            <h2 style="margin-bottom: 20px; color: #495057;">Agendar Nueva Cita</h2>
            
            <% if (listaMascotas.isEmpty() || listaVeterinarios.isEmpty()) { %>
                <div class="alert alert-error">
                    <% if (listaMascotas.isEmpty()) { %>
                        No hay mascotas activas registradas. Debe registrar mascotas primero.<br>
                    <% } %>
                    <% if (listaVeterinarios.isEmpty()) { %>
                        No hay veterinarios activos disponibles. Debe registrar veterinarios primero.
                    <% } %>
                </div>
            <% } else { %>
            
            <div class="info-box">
                <h4>Informacion Importante</h4>
                <p>Complete todos los campos para agendar una cita medica. El sistema generara automaticamente el numero de cita.</p>
            </div>
            
            <form method="POST" action="gestionCitas.jsp">
                <input type="hidden" name="accion" value="registrar">
                
                <div class="form-grid">
                    <div class="form-group">
                        <label>Mascota *</label>
                        <select name="idMascota" required>
                            <option value="">-- Seleccione Mascota --</option>
                            <% for (Map<String, String> mascota : listaMascotas) { %>
                                <option value="<%= mascota.get("id_mascota") %>">
                                    <%= mascota.get("nombre_mascota") %> - <%= mascota.get("propietario") %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Veterinario *</label>
                        <select name="idVeterinario" required>
                            <option value="">-- Seleccione Veterinario --</option>
                            <% for (Map<String, String> vet : listaVeterinarios) { %>
                                <option value="<%= vet.get("id_veterinario") %>">
                                    <%= vet.get("nombre_completo") %> - <%= vet.get("especialidad") %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Tipo de Consulta *</label>
                        <select name="tipoConsulta" required>
                            <option value="">-- Seleccione Tipo --</option>
                            <option value="Consulta General">Consulta General</option>
                            <option value="Control">Control</option>
                            <option value="Vacunación">Vacunación</option>
                            <option value="Cirugía">Cirugia</option>
                            <option value="Emergencia">Emergencia</option>
                            <option value="Tratamiento">Tratamiento</option>
                            <option value="Desparasitación">Desparasitación</option>
                            <option value="Estética">Estética</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Fecha de la Cita *</label>
                        <input type="date" name="fechaCita" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Hora de la Cita *</label>
                        <input type="time" name="horaCita" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Duracion (minutos) *</label>
                        <select name="duracionMinutos" required>
                            <option value="">-- Seleccione --</option>
                            <option value="15">15 minutos</option>
                            <option value="30" selected>30 minutos</option>
                            <option value="45">45 minutos</option>
                            <option value="60">60 minutos</option>
                            <option value="90">90 minutos</option>
                            <option value="120">120 minutos</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Motivo de la Consulta *</label>
                    <textarea name="motivo" required 
                              placeholder="Describa brevemente el motivo de la consulta"></textarea>
                </div>
                
                <div style="margin-top: 30px;">
                    <button type="submit" class="btn btn-primary">Agendar Cita</button>
                    <a href="index.jsp" class="btn btn-back">Cancelar</a>
                </div>
            </form>
            <% } %>
        </div>
    </div>
</body>
</html>
