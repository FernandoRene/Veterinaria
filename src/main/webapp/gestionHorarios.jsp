<%@page import="com.dev.clases.UsuarioRol"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="com.dev.bean.HorarioBean"%>
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
    String nombreCompleto = usuarioRol.getNombreCompleto();
    String rol = usuarioRol.getRol();
    
    Integer idUsuarioObj = (Integer) session.getAttribute("id_usuario");
    int idUsuario = (idUsuarioObj != null) ? idUsuarioObj : 0;
    
    // Variables para mensajes y tab activa
    String mensaje = "";
    String error = "";
    String tabActiva = request.getParameter("tab");
    
    // Si no hay tab especificada, usar "lista" por defecto
    if (tabActiva == null || tabActiva.isEmpty()) {
        tabActiva = "lista";
    }
    
    // Procesar registro si viene del formulario
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("accion") != null) {
        String accion = request.getParameter("accion");
        
        if ("registrar".equals(accion)) {
            HorarioBean beanRegistro = new HorarioBean();
            try {
                int idVeterinario = Integer.parseInt(request.getParameter("idVeterinario"));
                String diaSemana = request.getParameter("diaSemana");
                String horaInicio = request.getParameter("horaInicio");
                String horaFin = request.getParameter("horaFin");
                String turno = request.getParameter("turno");
                
                boolean resultado = beanRegistro.registrarHorario(idVeterinario, diaSemana, horaInicio, 
                                                                   horaFin, turno, idUsuario);
                
                if (resultado) {
                    mensaje = "Horario registrado exitosamente";
                    tabActiva = "lista";  // Cambiar a tab lista si fue exitoso
                } else {
                    error = "Error al registrar horario";
                    tabActiva = "registro";  // Mantener en tab registro si hubo error
                }
                
            } catch (NumberFormatException e) {
                error = "Error: Datos de veterinario inválidos";
                tabActiva = "registro";
            } catch (Exception e) {
                error = "Error: " + e.getMessage();
                tabActiva = "registro";
            } finally {
                beanRegistro.cerrarConexion();
            }
        }
    }
    
    // SIEMPRE cargar los datos (después de procesar o no)
    HorarioBean bean = new HorarioBean();
    ArrayList<Map<String, String>> listaHorarios = bean.listadoHorarios();
    ArrayList<Map<String, String>> listaVeterinarios = bean.listadoVeterinariosActivos();
    bean.cerrarConexion();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Horarios</title>
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
            max-width: 1400px;
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
        .form-group select {
            padding: 12px 15px;
            border: 2px solid #e9ecef;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
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
            padding: 15px;
            text-align: left;
            font-weight: 600;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }
        
        td {
            padding: 15px;
            border-bottom: 1px solid #e9ecef;
        }
        
        tbody tr:hover {
            background: #f8f9fa;
        }
        
        .badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        
        .badge-activo {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-inactivo {
            background: #f8d7da;
            color: #721c24;
        }
        
        .btn-action {
            padding: 6px 12px;
            font-size: 12px;
            margin-right: 5px;
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
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .empty-state h3 {
            font-size: 24px;
            margin-bottom: 10px;
        }
    </style>
    <script>
        function cambiarTab(tabName) {
            const tabs = document.querySelectorAll('.tab');
            const contents = document.querySelectorAll('.tab-content');
            
            tabs.forEach(tab => tab.classList.remove('active'));
            contents.forEach(content => content.classList.remove('active'));
            
            const tabButton = document.getElementById('tab-' + tabName);
if          (tabButton) tabButton.classList.add('active');
            const tabContent = document.getElementById(tabName);
if          (tabContent) tabContent.classList.add('active');
        }
        
        function confirmarCambioEstado(idHorario, estadoActual) {
            const nuevoEstado = estadoActual === 'ACTIVO' ? 'INACTIVO' : 'ACTIVO';
            const accion = estadoActual === 'ACTIVO' ? 'desactivar' : 'activar';
            
            if (confirm('¿Esta seguro de ' + accion + ' este horario?')) {
                window.location.href = 'cambiarEstadoHorario.jsp?id=' + idHorario + '&estado=' + nuevoEstado;
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Gestion de Horarios de Veterinarios</h1>
            <div class="user-info">
                Usuario: <%= codigoUsuario %>
            </div>
        </div>
        
        <div class="tabs">
            <button id="tab-lista" class="tab <%= "lista".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('lista')">
                Lista de Horarios
            </button>
            <button id="tab-registro" class="tab <%= "registro".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('registro')">
                Nuevo Horario
            </button>
        </div>
        
        <!-- TAB: LISTA DE HORARIOS -->
        <div id="lista" class="tab-content <%= "lista".equals(tabActiva) ? "active" : "" %>">
            <% if (!mensaje.isEmpty()) { %>
                <div class="alert alert-success"><%= mensaje %></div>
            <% } %>

            <% if (!error.isEmpty() && "lista".equals(tabActiva)) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>
            
            <div style="margin-bottom: 20px;">
                <a href="index.jsp" class="btn btn-back">Volver al Menu</a>
            </div>
            
            <% if (listaHorarios.isEmpty()) { %>
                <div class="empty-state">
                    <h3>No hay horarios registrados</h3>
                    <p>Haga clic en "Nuevo Horario" para agregar el primer horario</p>
                </div>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Veterinario</th>
                            <th>Matricula</th>
                            <th>Especialidad</th>
                            <th>Dia</th>
                            <th>Horario</th>
                            <th>Turno</th>
                            <th>Estado</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> horario : listaHorarios) { %>
                        <tr>
                            <td><%= horario.get("id_horario") %></td>
                            <td><%= horario.get("veterinario") %></td>
                            <td><%= horario.get("matricula") %></td>
                            <td><%= horario.get("especialidad") %></td>
                            <td><%= horario.get("dia_semana") %></td>
                            <td><%= horario.get("hora_inicio") %> - <%= horario.get("hora_fin") %></td>
                            <td><%= horario.get("turno") %></td>
                            <td>
                                <span class="badge badge-<%= horario.get("estado").toLowerCase() %>">
                                    <%= horario.get("estado") %>
                                </span>
                            </td>
                            <td>
                                <% if ("ACTIVO".equals(horario.get("estado"))) { %>
                                    <button onclick="confirmarCambioEstado(<%= horario.get("id_horario") %>, 'ACTIVO')" 
                                            class="btn btn-action btn-warning">
                                        Desactivar
                                    </button>
                                <% } else { %>
                                    <button onclick="confirmarCambioEstado(<%= horario.get("id_horario") %>, 'INACTIVO')" 
                                            class="btn btn-action btn-success">
                                        Activar
                                    </button>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- TAB: NUEVO HORARIO -->
        <div id="registro" class="tab-content <%= "registro".equals(tabActiva) ? "active" : "" %>">
            <% if (!error.isEmpty() && "registro".equals(tabActiva)) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>
            
            <h2 style="margin-bottom: 20px; color: #495057;">Registrar Nuevo Horario</h2>
            
            <% if (listaVeterinarios.isEmpty()) { %>
                <div class="alert alert-error">
                    No hay veterinarios activos disponibles. Debe registrar veterinarios primero.
                </div>
            <% } else { %>
            
            <form method="POST" action="gestionHorarios.jsp">
                <input type="hidden" name="accion" value="registrar">
                
                <div class="form-grid">
                    <div class="form-group">
                        <label>Veterinario *</label>
                        <select name="idVeterinario" required>
                            <option value="">-- Seleccione Veterinario --</option>
                            <% for (Map<String, String> vet : listaVeterinarios) { %>
                                <option value="<%= vet.get("id_veterinario") %>">
                                    <%= vet.get("nombre_completo") %> - <%= vet.get("matricula") %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Dia de la Semana *</label>
                        <select name="diaSemana" required>
                            <option value="">-- Seleccione Dia --</option>
                            <option value="Lunes">Lunes</option>
                            <option value="Martes">Martes</option>
                            <option value="Miércoles">Miercoles</option>
                            <option value="Jueves">Jueves</option>
                            <option value="Viernes">Viernes</option>
                            <option value="Sábado">Sabado</option>
                            <option value="Domingo">Domingo</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Hora Inicio *</label>
                        <input type="time" name="horaInicio" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Hora Fin *</label>
                        <input type="time" name="horaFin" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Turno *</label>
                        <select name="turno" required>
                            <option value="">-- Seleccione Turno --</option>
                            <option value="Mañana">Mañana</option>
                            <option value="Tarde">Tarde</option>
                            <option value="Noche">Noche</option>
                            <option value="Completo">Completo</option>
                        </select>
                    </div>
                </div>
                
                <div style="margin-top: 30px;">
                    <button type="submit" class="btn btn-primary">Registrar Horario</button>
                    <a href="index.jsp" class="btn btn-back">Cancelar</a>
                </div>
            </form>
            <% } %>
        </div>
    </div>
</body>
</html>
