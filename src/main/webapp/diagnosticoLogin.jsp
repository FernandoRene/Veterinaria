<%@page import="com.dev.bean.UsuarioBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page import="java.security.MessageDigest"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Diagnóstico de Login</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: monospace; background: #1e1e1e; color: #d4d4d4; padding: 20px; }
            .container { max-width: 1200px; margin: 0 auto; }
            .header { background: #2d2d30; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
            .section { background: #252526; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
            .success { color: #4ec9b0; }
            .error { color: #f48771; }
            .warning { color: #ce9178; }
            .info { color: #569cd6; }
            pre { background: #1e1e1e; padding: 15px; border-radius: 5px; overflow-x: auto; }
            .label { color: #9cdcfe; font-weight: bold; }
            .form-group { margin: 15px 0; }
            input { padding: 10px; background: #3c3c3c; border: 1px solid #555; color: #d4d4d4; border-radius: 3px; }
            button { padding: 10px 20px; background: #0e639c; color: white; border: none; cursor: pointer; border-radius: 3px; }
            button:hover { background: #1177bb; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h1 class="info">🔍 DIAGNÓSTICO DE LOGIN - SISTEMA VETERINARIA</h1>
                <p>Herramienta para depurar problemas de autenticación</p>
            </div>
            
            <%
                String usuario = request.getParameter("usuario");
                String password = request.getParameter("password");
                boolean probar = "POST".equalsIgnoreCase(request.getMethod());
            %>
            
            <!-- FORMULARIO DE PRUEBA -->
            <div class="section">
                <h2 class="warning">📝 PROBAR LOGIN</h2>
                <form method="POST">
                    <div class="form-group">
                        <span class="label">Usuario:</span><br>
                        <input type="text" name="usuario" value="aadministrador.p" style="width: 300px;">
                    </div>
                    <div class="form-group">
                        <span class="label">Contraseña:</span><br>
                        <input type="text" name="password" value="Ad12mi34ni56" style="width: 300px;">
                    </div>
                    <button type="submit">🔐 Probar Login</button>
                </form>
            </div>
            
            <% if (probar && usuario != null && password != null) { %>
                
                <!-- PASO 1: HASH -->
                <div class="section">
                    <h2 class="warning">PASO 1: GENERAR HASH SHA-256</h2>
                    <%
                        String hashGenerado = "";
                        try {
                            MessageDigest md = MessageDigest.getInstance("SHA-256");
                            byte[] hash = md.digest(password.getBytes("UTF-8"));
                            StringBuilder hexString = new StringBuilder();
                            for (byte b : hash) {
                                String hex = Integer.toHexString(0xff & b);
                                if (hex.length() == 1) hexString.append('0');
                                hexString.append(hex);
                            }
                            hashGenerado = hexString.toString();
                        } catch (Exception e) {
                            hashGenerado = "ERROR: " + e.getMessage();
                        }
                    %>
                    <pre>
<span class="label">Usuario ingresado:</span> <%= usuario %>
<span class="label">Contraseña ingresada:</span> <%= password %>
<span class="label">Hash SHA-256 generado:</span> <%= hashGenerado %>

<span class="label">Hash esperado (tu BD):</span> eab38de360dda0f942457928d3ec4414c6e7d6039c8a815d448f50a58d89f5c7

<% if ("eab38de360dda0f942457928d3ec4414c6e7d6039c8a815d448f50a58d89f5c7".equals(hashGenerado)) { %>
<span class="success">✓ HASH CORRECTO - Los hashes coinciden</span>
<% } else { %>
<span class="error">✗ HASH INCORRECTO - Los hashes NO coinciden</span>
<% } %>
                    </pre>
                </div>
                
                <!-- PASO 2: LLAMAR AL BEAN -->
                <div class="section">
                    <h2 class="warning">PASO 2: LLAMAR A UsuarioBean.verificarValidez()</h2>
                    <%
                        UsuarioBean bean = null;
                        UsuarioRol usuarioRol = null;
                        String errorBean = "";
                        
                        try {
                            bean = new UsuarioBean();
                            usuarioRol = bean.verificarValidez(request);
                        } catch (Exception e) {
                            errorBean = e.getMessage();
                            e.printStackTrace();
                        } finally {
                            if (bean != null) {
                                try {
                                    bean.cerrarConexion();
                                } catch (Exception e) {}
                            }
                        }
                    %>
                    
                    <% if (!errorBean.isEmpty()) { %>
                        <pre><span class="error">✗ ERROR AL CREAR BEAN:</span> <%= errorBean %></pre>
                    <% } else if (usuarioRol == null) { %>
                        <pre>
<span class="error">✗ verificarValidez() RETORNÓ NULL</span>

<span class="label">Posibles causas:</span>
1. El usuario no existe en la tabla usuario
2. La contraseña no coincide con el hash en la tabla password
3. Error en la consulta SQL
4. Problema de conexión a la base de datos

<span class="label">Revisa los logs de GlassFish para ver detalles del error</span>
                        </pre>
                    <% } else { %>
                        <pre>
<span class="success">✓ LOGIN EXITOSO - verificarValidez() retornó un objeto UsuarioRol</span>

<span class="label">Datos del usuario:</span>
ID Usuario:    <%= usuarioRol.getIdUsuario() %>
Código:        <%= usuarioRol.getCodigo() %>
Nombre:        <%= usuarioRol.getNombre() %>
Paterno:       <%= usuarioRol.getPaterno() %>
Materno:       <%= usuarioRol.getMaterno() != null ? usuarioRol.getMaterno() : "N/A" %>
Rol ID:        <%= usuarioRol.getIdRol() %>
Rol:           <%= usuarioRol.getRol() %>
Vigencia:      <%= usuarioRol.getVigenciaDias() %> días
                        </pre>
                    <% } %>
                </div>
                
                <!-- PASO 3: SIMULACIÓN DE SESIÓN -->
                <div class="section">
                    <h2 class="warning">PASO 3: CREAR SESIÓN (SIMULACIÓN)</h2>
                    <% if (usuarioRol != null) { %>
                        <pre>
<span class="success">✓ Sesión creada exitosamente</span>

<span class="label">En LoginServlet debería hacer:</span>
HttpSession session = request.getSession(true);
session.setAttribute("usuarioRol", usuarioRol);
session.setMaxInactiveInterval(30 * 60);
request.getRequestDispatcher("/index.jsp").forward(request, response);

<span class="success">El login DEBERÍA funcionar correctamente</span>
                        </pre>
                    <% } else { %>
                        <pre>
<span class="error">✗ No se puede crear sesión porque usuarioRol es null</span>

<span class="label">En LoginServlet debería hacer:</span>
request.getRequestDispatcher("/loginError.jsp").forward(request, response);

<span class="error">El login FALLARÁ y redirigirá a loginError.jsp</span>
                        </pre>
                    <% } %>
                </div>
                
            <% } else { %>
                <div class="section">
                    <p class="info">👆 Complete el formulario de arriba y presione "Probar Login" para ejecutar el diagnóstico</p>
                </div>
            <% } %>
            
            <!-- INFORMACIÓN ADICIONAL -->
            <div class="section">
                <h2 class="warning">📚 INFORMACIÓN DE REFERENCIA</h2>
                <pre>
<span class="label">Credenciales correctas:</span>
Usuario:    aadministrador.p
Contraseña: Ad12mi34ni56
Hash:       eab38de360dda0f942457928d3ec4414c6e7d6039c8a815d448f50a58d89f5c7

<span class="label">URL del login real:</span>
<%= request.getContextPath() %>/login.jsp

<span class="label">URL del servlet de login:</span>
<%= request.getContextPath() %>/loginServlet

<span class="label">Verificar en base de datos:</span>
SELECT * FROM usuario WHERE codigo = 'aadministrador.p';
SELECT * FROM password WHERE id_usuario = (SELECT id_usuario FROM usuario WHERE codigo = 'aadministrador.p');
                </pre>
            </div>
        </div>
    </body>
</html>
