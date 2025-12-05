package com.dev.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.dev.conexionDB.VariablesConexion;

@WebServlet("/MostrarImagen")
public class MostrarImagenServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID no especificado");
            return;
        }
        
        Connection connection = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        OutputStream outputStream = null;
        
        try {
            // Conectar a la base de datos
            VariablesConexion variable = new VariablesConexion();
            variable.iniciarConexion();
            connection = variable.getConnection();
            
            // Consulta para PostgreSQL
            String sql = "SELECT foto FROM mascota WHERE id_mascota = ?";
            pstmt = connection.prepareStatement(sql);
            pstmt.setInt(1, Integer.parseInt(idParam));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                byte[] fotoBytes = rs.getBytes("foto");
                
                if (fotoBytes != null && fotoBytes.length > 0) {
                    // Configurar la respuesta
                    response.setContentType("image/jpeg");
                    response.setContentLength(fotoBytes.length);
                    response.setHeader("Content-Disposition", "inline; filename=\"mascota-" + idParam + ".jpg\"");
                    
                    // Escribir la imagen
                    outputStream = response.getOutputStream();
                    outputStream.write(fotoBytes);
                    outputStream.flush();
                    return;
                }
            }
            
            // Si no hay imagen, mostrar imagen por defecto
            mostrarImagenPorDefecto(response);
            
        } catch (Exception e) {
            e.printStackTrace();
            mostrarImagenPorDefecto(response);
        } finally {
            // Cerrar recursos
            try {
                if (outputStream != null) outputStream.close();
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (connection != null) connection.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
    
    private void mostrarImagenPorDefecto(HttpServletResponse response) throws IOException {
        // Imagen por defecto en base64 (una imagen pequeña de 1x1 pixel transparente)
        String defaultImage = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
        
        response.setContentType("image/png");
        byte[] imageBytes = java.util.Base64.getDecoder().decode(defaultImage);
        response.getOutputStream().write(imageBytes);
    }
}