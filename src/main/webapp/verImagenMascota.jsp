<%@page import="java.io.InputStream"%>
<%@page import="com.dev.bean.MascotaBean"%>
<%@page import="java.sql.Blob"%>
<%@page import="java.io.OutputStream"%>
<%@page contentType="image/jpeg" pageEncoding="UTF-8"%>
<%
    // Obtener ID de la mascota
    String idParam = request.getParameter("id");
    if (idParam == null || idParam.isEmpty()) {
        response.sendError(400, "ID no especificado");
        return;
    }
    
    OutputStream outStream = null;
    MascotaBean bean = null;
    
    try {
        bean = new MascotaBean();
        // Obtener la imagen de la base de datos
        Blob fotoBlob = bean.getFotoMascota(Integer.parseInt(idParam));
        
        if (fotoBlob != null) {
            response.setContentType("image/jpeg");
            response.setHeader("Content-Disposition", "inline");
            
            byte[] buffer = new byte[4096];
            int length;
            
            InputStream inputStream = fotoBlob.getBinaryStream();
            outStream = response.getOutputStream();
            
            while ((length = inputStream.read(buffer)) != -1) {
                outStream.write(buffer, 0, length);
            }
            
            inputStream.close();
        } else {
            // Si no hay imagen, redirigir a una imagen por defecto
            response.sendRedirect("images/default-pet.png");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        // En caso de error, mostrar imagen por defecto
        response.sendRedirect("images/default-pet.png");
    } finally {
        if (outStream != null) {
            outStream.close();
        }
        if (bean != null) {
            bean.cerrarConexion();
        }
    }
%>