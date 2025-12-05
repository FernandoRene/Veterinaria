<%@page import="com.dev.bean.MascotaBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Lista de Mascotas</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', sans-serif; background: #f5f5f5; padding: 20px; }
            .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 10px 10px 0 0; margin: -30px -30px 30px -30px; display: flex; justify-content: space-between; align-items: center; }
            .header h1 { font-size: 24px; }
            .btn { padding: 10px 20px; border: none; border-radius: 5px; font-size: 14px; font-weight: 600; cursor: pointer; text-decoration: none; display: inline-block; transition: transform 0.2s; }
            .btn:hover { transform: translateY(-2px); }
            .btn-success { background: #28a745; color: white; }
            .btn-sm { padding: 5px 10px; font-size: 12px; }
            .back-link { display: inline-block; color: #667eea; text-decoration: none; margin-bottom: 20px; }
            table { width: 100%; border-collapse: collapse; margin-top: 20px; }
            thead { background: #667eea; color: white; }
            th { padding: 12px; text-align: left; font-weight: 600; }
            td { padding: 12px; border-bottom: 1px solid #dee2e6; }
            tbody tr:hover { background: #f8f9fa; }
            .no-data { text-align: center; padding: 40px; color: #6c757d; }
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
            
            // Obtener lista
            String listaHTML = "";
            try {
                MascotaBean bean = new MascotaBean();
                listaHTML = bean.listaMascotas();
                bean.cerrarConexion();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
        
        <div class="container">
            <div class="header">
                <div>
                    <h1>🐶 Lista de Mascotas</h1>
                    <p>Gestión de mascotas registradas</p>
                </div>
                <a href="registroMascota.jsp" class="btn btn-success">➕ Nueva Mascota</a>
            </div>
            
            <a href="index.jsp" class="back-link">← Volver al inicio</a>
            
            <% if (listaHTML != null && !listaHTML.isEmpty()) { %>
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Imagen</th>
                            <th>Nombre</th>
                            <th>Raza</th>
                            <th>Especie</th>
                            <th>Color</th>
                            <th>Sexo</th>
                            <th>Fecha Nacimiento</th>
                            <th>Peso</th>
                            <th>Propietario</th>
                            <th>Acciones</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%= listaHTML %>
                    </tbody>
                </table>
            <% } else { %>
                <div class="no-data">
                    <div style="font-size: 48px; margin-bottom: 10px;">🐕</div>
                    <h3>No hay mascotas registradas</h3>
                    <p>Comience agregando una nueva mascota</p>
                    <br>
                    <a href="registroMascota.jsp" class="btn btn-success">➕ Registrar Mascota</a>
                </div>
            <% } %>
        </div>
        <!-- Agrega esto antes del </body> -->
        <div id="imagenModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.8); z-index:1000; justify-content:center; align-items:center;">
            <div style="background:white; border-radius:10px; padding:20px; max-width:90%; max-height:90%;">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:15px;">
                    <h3 style="margin:0;">Foto de la Mascota</h3>
                    <button onclick="cerrarModal()" style="background:none; border:none; font-size:24px; cursor:pointer; color:#666;">&times;</button>
                </div>
                <div id="modalContenido" style="max-height:70vh; overflow:auto; text-align:center;">
                    <!-- La imagen se cargará aquí -->
                </div>
            </div>
        </div>

        <script>
            function verFoto(idMascota) {
                const modal = document.getElementById('imagenModal');
                const contenido = document.getElementById('modalContenido');

                // Mostrar cargando
                contenido.innerHTML = '<div style="padding:40px;text-align:center;color:#666;">' +
                                     '<div style="font-size:24px;margin-bottom:10px;">⏳</div>' +
                                     '<p>Cargando imagen...</p>' +
                                     '</div>';

                // Mostrar modal
                modal.style.display = 'flex';

                // Cargar la imagen
                const img = new Image();
                img.src = 'MostrarImagen?id=' + idMascota + '&t=' + new Date().getTime(); // Cache buster
                img.style.maxWidth = '100%';
                img.style.maxHeight = '60vh';
                img.style.borderRadius = '10px';

                img.onload = function() {
                    contenido.innerHTML = '';
                    contenido.appendChild(img);

                    // Agregar botón de descarga
                    const descargarBtn = document.createElement('button');
                    descargarBtn.innerHTML = '⬇️ Descargar';
                    descargarBtn.style.marginTop = '15px';
                    descargarBtn.style.padding = '8px 16px';
                    descargarBtn.style.background = '#28a745';
                    descargarBtn.style.color = 'white';
                    descargarBtn.style.border = 'none';
                    descargarBtn.style.borderRadius = '5px';
                    descargarBtn.style.cursor = 'pointer';
                    descargarBtn.onclick = function() {
                        const link = document.createElement('a');
                        link.href = img.src;
                        link.download = 'mascota-' + idMascota + '.jpg';
                        document.body.appendChild(link);
                        link.click();
                        document.body.removeChild(link);
                    };

                    contenido.appendChild(descargarBtn);
                };

                img.onerror = function() {
                    contenido.innerHTML = '<div style="padding:40px;text-align:center;color:#666;">' +
                                         '<div style="font-size:48px;margin-bottom:10px;">📷</div>' +
                                         '<h4>No se pudo cargar la imagen</h4>' +
                                         '<p>La imagen puede estar dañada o ser incompatible.</p>' +
                                         '<button onclick="cerrarModal()" style="margin-top:15px;padding:8px 16px;background:#667eea;color:white;border:none;border-radius:5px;cursor:pointer;">Cerrar</button>' +
                                         '</div>';
                };
            }

            function cerrarModal() {
                document.getElementById('imagenModal').style.display = 'none';
                document.getElementById('modalContenido').innerHTML = '';
            }

            // Cerrar al hacer clic fuera
            document.getElementById('imagenModal').addEventListener('click', function(e) {
                if (e.target === this) {
                    cerrarModal();
                }
            });

            // Cerrar con ESC
            document.addEventListener('keydown', function(e) {
                if (e.key === 'Escape') {
                    cerrarModal();
                }
            });
        </script>
    </body>
</html>
