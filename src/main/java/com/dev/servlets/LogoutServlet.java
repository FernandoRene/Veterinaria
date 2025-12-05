package com.dev.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet para cerrar sesi贸n
 * @author Fernando
 */
@WebServlet(name = "LogoutServlet", urlPatterns = {"/logout"})
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Obtener la sesi贸n actual (sin crear una nueva)
        HttpSession session = request.getSession(false);
        
        if (session != null) {
            System.out.println("馃毆 Cerrando sesi贸n del usuario: " + 
                             (session.getAttribute("usuarioRol") != null ? 
                              ((com.dev.clases.UsuarioRol)session.getAttribute("usuarioRol")).getCodigo() : 
                              "desconocido"));
            
            // Invalidar la sesi贸n
            session.invalidate();
        }
        
        // Redirigir al login
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet para cerrar sesi贸n de usuario";
    }
}
