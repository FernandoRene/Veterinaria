<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Foto de la Mascota</title>
    <style>
        body { margin: 0; padding: 20px; background: #f5f5f5; font-family: 'Segoe UI', sans-serif; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #eee; }
        h1 { margin: 0; color: #333; }
        .btn { padding: 8px 16px; background: #667eea; color: white; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; display: inline-block; }
        .image-container { text-align: center; padding: 20px; }
        .image-container img { max-width: 100%; max-height: 70vh; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }
        .loading { padding: 40px; text-align: center; color: #666; }
    </style>
</head>
<body>
    <%
        String idMascota = request.getParameter("id");
        if (idMascota == null || idMascota.isEmpty()) {
            response.sendRedirect("listaMascota.jsp");
            return;
        }
    %>
    
    <div class="container">
        <div class="header">
            <h1>📷 Foto de la Mascota</h1>
            <a href="listaMascota.jsp" class="btn">← Volver a la lista</a>
        </div>
        
        <div class="image-container">
            <img id="fotoMascota" 
                 src="MostrarImagen?id=<%= idMascota %>" 
                 alt="Foto de la mascota"
                 onload="document.getElementById('loading').style.display='none';"
                 onerror="document.getElementById('loading').innerHTML='<h3>❌ No se pudo cargar la imagen</h3><p>La imagen puede estar corrupta o ser demasiado grande.</p>';">
            
            <div id="loading" class="loading">
                <div style="font-size: 48px; margin-bottom: 10px;">⏳</div>
                <p>Cargando imagen...</p>
            </div>
        </div>
        
        <div style="text-align:center; margin-top:20px;">
            <button onclick="window.history.back()" class="btn">← Volver</button>
            <button onclick="window.location.reload()" class="btn">🔄 Recargar</button>
            <a href="MostrarImagen?id=<%= idMascota %>" download="mascota-<%= idMascota %>.jpg" class="btn">⬇️ Descargar</a>
        </div>
    </div>
    
    <script>
        // Ocultar loading después de 5 segundos máximo
        setTimeout(function() {
            document.getElementById('loading').style.display = 'none';
        }, 5000);
    </script>
</body>
</html>