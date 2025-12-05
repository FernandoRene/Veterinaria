<%@page import="com.dev.bean.MascotaBean"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        response.sendRedirect("listaMascota.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Foto de Mascota</title>
    <style>
        body { margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        .header { display: flex; justify-content: space-between; margin-bottom: 20px; }
        .btn { padding: 8px 16px; background: #667eea; color: white; border: none; border-radius: 5px; cursor: pointer; text-decoration: none; }
        .image-container { text-align: center; }
        img { max-width: 100%; max-height: 70vh; border-radius: 10px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Foto de la Mascota ID: <%= idParam %></h2>
            <a href="listaMascota.jsp" class="btn">← Volver</a>
        </div>
        
        <div class="image-container">
            <img src="MostrarImagen?id=<%= idParam %>" 
                 alt="Foto de mascota"
                 onerror="this.onerror=null; this.src='data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMjAwIiBoZWlnaHQ9IjIwMCIgZmlsbD0iI2YwZjBmMCIvPjx0ZXh0IHg9IjEwMCIgeT0iMTAwIiBmb250LWZhbWlseT0iQXJpYWwiIGZvbnQtc2l6ZT0iMTQiIGZpbGw9IiM2NjYiIHRleHQtYW5jaG9yPSJtaWRkbGUiIGR5PSIuM2VtIj7wn5GgIE5vIGhheSBpbWFnZW48L3RleHQ+PC9zdmc+'">
        </div>
    </div>
</body>
</html>