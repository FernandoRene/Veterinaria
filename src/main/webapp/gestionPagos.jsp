<%@page import="com.dev.clases.UsuarioRol"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Map"%>
<%@page import="com.dev.bean.PagoBean"%>
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
    
    PagoBean bean = new PagoBean();
    
    // Procesar registro si viene del formulario
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("accion") != null) {
        String accion = request.getParameter("accion");
        
        if ("registrar".equals(accion)) {
            try {
                int idMascota = Integer.parseInt(request.getParameter("idMascota"));
                String idCitaStr = request.getParameter("idCita");
                Integer idCita = (idCitaStr != null && !idCitaStr.isEmpty()) ? 
                                 Integer.parseInt(idCitaStr) : null;
                
                String tipoAtencion = request.getParameter("tipoAtencion");
                double monto = Double.parseDouble(request.getParameter("monto"));
                String metodoPago = request.getParameter("metodoPago");
                String nroComprobante = request.getParameter("nroComprobante");
                String observaciones = request.getParameter("observaciones");
                
                boolean resultado = bean.registrarPago(idMascota, idCita, tipoAtencion, monto,
                                                       metodoPago, nroComprobante, observaciones,
                                                       idUsuario);
                
                bean.cerrarConexion();
                
                if (resultado) {
                    response.sendRedirect("gestionPagos.jsp?mensaje=Pago registrado exitosamente&tab=lista");
                } else {
                    response.sendRedirect("gestionPagos.jsp?error=Error al registrar pago&tab=registro");
                }
                return;
                
            } catch (Exception e) {
                bean.cerrarConexion();
                response.sendRedirect("gestionPagos.jsp?error=Error: " + e.getMessage() + "&tab=registro");
                return;
            }
        }
    }
    
    ArrayList<Map<String, String>> listaPagos = bean.listadoPagos();
    ArrayList<Map<String, String>> listaMascotas = bean.listadoMascotasActivas();
    ArrayList<Map<String, String>> listaCitasSinPago = bean.listadoCitasSinPago();
    
    bean.cerrarConexion();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion de Pagos</title>
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
            min-height: 80px;
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
        
        .badge-pagado {
            background: #d4edda;
            color: #155724;
        }
        
        .badge-pendiente {
            background: #fff3cd;
            color: #664d03;
        }
        
        .badge-anulado {
            background: #f8d7da;
            color: #721c24;
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
        
        .monto {
            font-size: 18px;
            font-weight: bold;
            color: #28a745;
        }
        
        .section-divider {
            border-top: 2px solid #e9ecef;
            margin: 30px 0;
            padding-top: 20px;
        }
        
        .radio-group {
            display: flex;
            gap: 20px;
            margin: 10px 0;
        }
        
        .radio-group label {
            display: flex;
            align-items: center;
            cursor: pointer;
            font-weight: normal;
        }
        
        .radio-group input[type="radio"] {
            margin-right: 8px;
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
        
        function toggleTipoPago(tipo) {
            const citaSection = document.getElementById('citaSection');
            const idCitaSelect = document.getElementById('idCita');
            
            if (tipo === 'cita') {
                citaSection.style.display = 'block';
                idCitaSelect.required = true;
            } else {
                citaSection.style.display = 'none';
                idCitaSelect.required = false;
                idCitaSelect.value = '';
            }
        }
        
        function cargarInfoCita() {
            const citaSelect = document.getElementById('idCita');
            const selectedOption = citaSelect.options[citaSelect.selectedIndex];
            
            if (selectedOption && selectedOption.value) {
                const idMascota = selectedOption.getAttribute('data-mascota');
                const tipoConsulta = selectedOption.getAttribute('data-tipo');
                
                document.getElementById('idMascota').value = idMascota;
                document.getElementById('tipoAtencion').value = tipoConsulta;
            }
        }
    </script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Gestion de Pagos por Atenciones</h1>
            <div class="user-info">
                Usuario: <%= codigoUsuario %>
            </div>
        </div>
        
        <div class="tabs">
            <button class="tab <%= "lista".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('lista')">
                Lista de Pagos
            </button>
            <button class="tab <%= "registro".equals(tabActiva) ? "active" : "" %>" onclick="cambiarTab('registro')">
                Nuevo Pago
            </button>
        </div>
        
        <!-- TAB: LISTA DE PAGOS -->
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
            
            <% if (listaPagos.isEmpty()) { %>
                <div class="empty-state">
                    <h3>No hay pagos registrados</h3>
                    <p>Haga clic en "Nuevo Pago" para registrar el primer pago</p>
                </div>
            <% } else { %>
                <div style="overflow-x: auto;">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Fecha</th>
                            <th>Mascota</th>
                            <th>Propietario</th>
                            <th>Tipo Atencion</th>
                            <th>Nro Cita</th>
                            <th>Monto</th>
                            <th>Metodo Pago</th>
                            <th>Comprobante</th>
                            <th>Estado</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> pago : listaPagos) { %>
                        <tr>
                            <td><strong>#<%= pago.get("id_pago") %></strong></td>
                            <td><%= pago.get("fecha_pago").substring(0, 16) %></td>
                            <td>
                                <strong><%= pago.get("mascota") %></strong><br>
                                <small><%= pago.get("especie") %> - <%= pago.get("raza") %></small>
                            </td>
                            <td>
                                <%= pago.get("propietario") %><br>
                                <small><%= pago.get("telefono_propietario") %></small>
                            </td>
                            <td><%= pago.get("tipo_atencion") %></td>
                            <td><%= pago.get("nro_cita") %></td>
                            <td><span class="monto">Bs <%= pago.get("monto") %></span></td>
                            <td><%= pago.get("metodo_pago") %></td>
                            <td><%= pago.get("nro_comprobante") %></td>
                            <td>
                                <span class="badge badge-<%= pago.get("estado").toLowerCase() %>">
                                    <%= pago.get("estado") %>
                                </span>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                </div>
            <% } %>
        </div>
        
        <!-- TAB: NUEVO PAGO -->
        <div id="registro" class="tab-content <%= "registro".equals(tabActiva) ? "active" : "" %>">
            <% if (error != null && "registro".equals(tabActiva)) { %>
                <div class="alert alert-error"><%= error %></div>
            <% } %>
            
            <h2 style="margin-bottom: 20px; color: #495057;">Registrar Nuevo Pago</h2>
            
            <% if (listaMascotas.isEmpty()) { %>
                <div class="alert alert-error">
                    No hay mascotas activas registradas. Debe registrar mascotas primero.
                </div>
            <% } else { %>
            
            <div class="info-box">
                <h4>Informacion Importante</h4>
                <p>Seleccione si el pago corresponde a una cita medica completada o es un pago directo por otros servicios.</p>
            </div>
            
            <form method="POST" action="gestionPagos.jsp">
                <input type="hidden" name="accion" value="registrar">
                
                <!-- Selección de tipo de pago -->
                <div class="form-group">
                    <label>Tipo de Pago *</label>
                    <div class="radio-group">
                        <label>
                            <input type="radio" name="tipoPago" value="cita" 
                                   onchange="toggleTipoPago('cita')" 
                                   <%= !listaCitasSinPago.isEmpty() ? "checked" : "" %>>
                            Pago de Cita Medica Completada
                        </label>
                        <label>
                            <input type="radio" name="tipoPago" value="directo" 
                                   onchange="toggleTipoPago('directo')"
                                   <%= listaCitasSinPago.isEmpty() ? "checked" : "" %>>
                            Pago Directo (sin cita)
                        </label>
                    </div>
                </div>
                
                <!-- Sección: Cita -->
                <div id="citaSection" style="<%= listaCitasSinPago.isEmpty() ? "display:none;" : "" %>">
                    <div class="form-group">
                        <label>Seleccione Cita a Pagar</label>
                        <select id="idCita" name="idCita" onchange="cargarInfoCita()"
                                <%= !listaCitasSinPago.isEmpty() ? "required" : "" %>>
                            <option value="">-- Seleccione Cita --</option>
                            <% for (Map<String, String> cita : listaCitasSinPago) { %>
                                <option value="<%= cita.get("id_cita") %>"
                                        data-mascota="<%= cita.get("id_mascota") %>"
                                        data-tipo="<%= cita.get("tipo_consulta") %>">
                                    <%= cita.get("nro_cita") %> - <%= cita.get("fecha_cita") %> - 
                                    <%= cita.get("mascota") %> - <%= cita.get("propietario") %>
                                </option>
                            <% } %>
                        </select>
                        <% if (listaCitasSinPago.isEmpty()) { %>
                            <small style="color: #6c757d;">No hay citas completadas pendientes de pago</small>
                        <% } %>
                    </div>
                </div>
                
                <div class="section-divider"></div>
                
                <div class="form-grid">
                    <div class="form-group">
                        <label>Mascota *</label>
                        <select id="idMascota" name="idMascota" required>
                            <option value="">-- Seleccione Mascota --</option>
                            <% for (Map<String, String> mascota : listaMascotas) { %>
                                <option value="<%= mascota.get("id_mascota") %>">
                                    <%= mascota.get("nombre_mascota") %> - <%= mascota.get("propietario") %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Tipo de Atencion *</label>
                        <select id="tipoAtencion" name="tipoAtencion" required>
                            <option value="">-- Seleccione Tipo --</option>
                            <option value="CONSULTA GENERAL">Consulta General</option>
                            <option value="VACUNACION">Vacunacion</option>
                            <option value="CIRUGIA">Cirugia</option>
                            <option value="TRATAMIENTO">Tratamiento</option>
                            <option value="EMERGENCIA">Emergencia</option>
                            <option value="DESPARASITACION">Desparasitacion</option>
                            <option value="BANO Y PELUQUERIA">Bano y Peluqueria</option>
                            <option value="HOSPITALIZACION">Hospitalizacion</option>
                            <option value="EXAMENES">Examenes</option>
                            <option value="OTROS">Otros</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Monto (Bs) *</label>
                        <input type="number" name="monto" step="0.01" min="0" 
                               placeholder="0.00" required>
                    </div>
                    
                    <div class="form-group">
                        <label>Metodo de Pago *</label>
                        <select name="metodoPago" required>
                            <option value="">-- Seleccione Metodo --</option>
                            <option value="EFECTIVO">Efectivo</option>
                            <option value="TARJETA">Tarjeta</option>
                            <option value="TRANSFERENCIA">Transferencia</option>
                            <option value="QR">QR</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label>Numero de Comprobante *</label>
                        <input type="text" name="nroComprobante" 
                               placeholder="Ej: REC-001234" required>
                    </div>
                </div>
                
                <div class="form-group">
                    <label>Observaciones</label>
                    <textarea name="observaciones" 
                              placeholder="Observaciones adicionales (opcional)"></textarea>
                </div>
                
                <div style="margin-top: 30px;">
                    <button type="submit" class="btn btn-primary">Registrar Pago</button>
                    <a href="index.jsp" class="btn btn-back">Cancelar</a>
                </div>
            </form>
            <% } %>
        </div>
    </div>
</body>
</html>
