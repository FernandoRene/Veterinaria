package com.dev.servlets;

import com.dev.bean.MascotaBean; // Asegúrate de que esta ruta sea correcta
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.IOException;
import java.io.InputStream;

// 1. URL que el formulario llamará
@WebServlet("/MascotaServlet")
// 2. Anotación necesaria para manejar formularios que incluyen archivos (multipart/form-data)
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1, // 1 MB
    maxFileSize = 1024 * 1024 * 10,      // 10 MB
    maxRequestSize = 1024 * 1024 * 50    // 50 MB
)
public class MascotaServlet extends HttpServlet {

    private static final String FOTO_INPUT_NAME = "fotoMascota"; // El nombre del campo 'input type="file"' en el JSP

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String mensaje = "";

        try (MascotaBean bean = new MascotaBean()) {

            // Obtener el archivo - el nombre debe coincidir con el input file
            Part filePart = request.getPart("fotoMascota");
            InputStream fileContent = null;

            // Verificar si se subió un archivo válido
            if (filePart != null && filePart.getSize() > 0 && filePart.getInputStream() != null) {
                fileContent = filePart.getInputStream();
                System.out.println("Archivo recibido, tamaño: " + filePart.getSize() + " bytes");
            } else {
                System.out.println("No se recibió archivo o está vacío");
            }

            // Llamar al método registrarMascota
            mensaje = bean.registrarMascota(request, fileContent);

            System.out.println("Mensaje de registro: " + mensaje);

            // Determinar si es error
            boolean esError = mensaje.contains("❌") || mensaje.toLowerCase().contains("error");

            if (!esError) {
                // Éxito
                request.getSession().setAttribute("mensajeRegistro", mensaje);
                response.sendRedirect("listaMascota.jsp");
            } else {
                // Error
                request.setAttribute("mensajeRegistro", mensaje);
                request.getRequestDispatcher("registroMascota.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            mensaje = "❌ Error en el controlador: " + e.getMessage();
            request.setAttribute("mensajeRegistro", mensaje);
            request.getRequestDispatcher("registroMascota.jsp").forward(request, response);
        }
    }
}