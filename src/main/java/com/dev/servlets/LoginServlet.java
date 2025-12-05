package com.dev.servlets;

import com.dev.bean.UsuarioBean;
import com.dev.clases.UsuarioRol;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginServlet", urlPatterns = {"/loginServlet"})
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        UsuarioBean bean = new UsuarioBean();
        UsuarioRol usuarioRol = bean.verificarValidez(request);
        bean.cerrarConexion();
        
        if (usuarioRol == null) {
            System.out.println("❌ Login fallido");
            response.sendRedirect("loginError.jsp");
        } else {
            System.out.println("✅ Login exitoso: " + usuarioRol.getCodigo());
            HttpSession session = request.getSession(true);
            session.setAttribute("usuarioRol", usuarioRol);
            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect("index.jsp");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}