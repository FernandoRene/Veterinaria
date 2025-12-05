package com.dev.servlets;

import com.dev.bean.UsuarioBean;
import com.dev.clases.UsuarioRol;
import jakarta.servlet.RequestDispatcher;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Servlet para autenticación de usuarios
 * @author Fernando
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/loginServlet"})
public class LoginServlet_old extends HttpServlet {

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException {
        response.setContentType("text/html;charset=UTF-8");
        
        try (PrintWriter out = response.getWriter()) {
            RequestDispatcher requestDispatcher;
            UsuarioBean usuarioBean = new UsuarioBean();
            
            // Validar usuario con SHA-256
            UsuarioRol usuarioRol = usuarioBean.verificarValidez(request);
            
            if (usuarioRol == null) {
                System.out.println("❌ Login fallido - Usuario o contraseña incorrectos");
                
                // NO guardar null en la sesión
                // Solo redirigir a la página de error
                requestDispatcher = request.getRequestDispatcher("/loginError.jsp");
                
            } else {
                System.out.println("✅ Login exitoso - Usuario: " + usuarioRol.getCodigo() + 
                                 " | Rol: " + usuarioRol.getRol());
                
                // Recuperar/crear sesión
                HttpSession session = request.getSession(true);
                
                // Guardar objeto de usuario en la sesión
                session.setAttribute("usuarioRol", usuarioRol);
                
                // Establecer timeout de 30 minutos
                session.setMaxInactiveInterval(30 * 60);
                
                System.out.println("📝 Sesión creada - ID: " + session.getId());
                
                // Redirigir a página principal
                requestDispatcher = request.getRequestDispatcher("/index.jsp");
            }
            
            // Cerrar conexión del bean
            usuarioBean.cerrarConexion();
            
            // Forward a la página correspondiente
            requestDispatcher.forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(LoginServlet_old.class.getName()).log(Level.SEVERE, null, ex);
            response.sendRedirect("loginError.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            processRequest(request, response);
        } catch (SQLException ex) {
            Logger.getLogger(LoginServlet_old.class.getName()).log(Level.SEVERE, null, ex);
            response.sendRedirect("loginError.jsp");
        }
    }

    @Override
    public String getServletInfo() {
        return "Servlet de autenticación con SHA-256";
    }
}
