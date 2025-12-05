package com.dev.servlets;

import com.dev.conexionDB.VariablesConexion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet(name = "TestConexionServlet", urlPatterns = {"/testConexion"})
public class TestConexionServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html>");
        out.println("<head><title>Test de Conexión</title></head>");
        out.println("<body style='font-family: monospace; padding: 20px;'>");
        out.println("<h1>🔍 Test de Conexión a Base de Datos</h1>");
        
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // TEST 1: Obtener conexión
            out.println("<h2>TEST 1: Obtener Conexión</h2>");
            VariablesConexion vc = new VariablesConexion();
            con = vc.getConnection();
            
            if (con == null) {
                out.println("<p style='color: red;'>❌ Conexión es NULL</p>");
                return;
            }
            
            if (con.isClosed()) {
                out.println("<p style='color: red;'>❌ Conexión está CERRADA</p>");
                return;
            }
            
            out.println("<p style='color: green;'>✅ Conexión obtenida exitosamente</p>");
            
            // TEST 2: Query simple
            out.println("<h2>TEST 2: Query Simple</h2>");
            String sql = "SELECT COUNT(*) as total FROM usuario";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                int total = rs.getInt("total");
                out.println("<p style='color: green;'>✅ Query ejecutado correctamente</p>");
                out.println("<p>Total de usuarios: <strong>" + total + "</strong></p>");
            }
            
            rs.close();
            ps.close();
            
            // TEST 3: Buscar usuario específico
            out.println("<h2>TEST 3: Buscar Usuario Específico</h2>");
            sql = "SELECT usuario, nombre, paterno FROM usuario WHERE usuario = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, "aadministrador.p");
            rs = ps.executeQuery();
            
            if (rs.next()) {
                out.println("<p style='color: green;'>✅ Usuario encontrado</p>");
                out.println("<p>Usuario: <strong>" + rs.getString("usuario") + "</strong></p>");
                out.println("<p>Nombre: <strong>" + rs.getString("nombre") + " " + rs.getString("paterno") + "</strong></p>");
            } else {
                out.println("<p style='color: red;'>❌ Usuario NO encontrado</p>");
            }
            
            rs.close();
            ps.close();
            
            // TEST 4: Verificar contraseña
            out.println("<h2>TEST 4: Verificar Contraseña</h2>");
            sql = "SELECT p.hash_actual FROM password p " +
                  "INNER JOIN usuario u ON p.id_usuario = u.id_usuario " +
                  "WHERE u.usuario = ? " +
                  "ORDER BY p.id_pass DESC LIMIT 1";
            
            ps = con.prepareStatement(sql);
            ps.setString(1, "aadministrador.p");
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String hash = rs.getString("hash_actual");
                out.println("<p style='color: green;'>✅ Hash encontrado</p>");
                out.println("<p>Hash en BD: <code style='word-break: break-all;'>" + hash + "</code></p>");
                out.println("<p>Hash esperado: <code style='word-break: break-all;'>eab38de360dda0f942457928d3ec4414c6e7d6039c8a815d448f50a58d89f5c7</code></p>");
                
                if ("eab38de360dda0f942457928d3ec4414c6e7d6039c8a815d448f50a58d89f5c7".equals(hash)) {
                    out.println("<p style='color: green; font-weight: bold;'>✅✅✅ LOS HASHES COINCIDEN</p>");
                } else {
                    out.println("<p style='color: red; font-weight: bold;'>❌ LOS HASHES NO COINCIDEN</p>");
                }
            } else {
                out.println("<p style='color: red;'>❌ No se encontró contraseña para el usuario</p>");
            }
            
            // TEST 5: Query completo de login
            out.println("<h2>TEST 5: Query Completo de Login</h2>");
            sql = "SELECT u.id_usuario, u.usuario, r.rol " +
                  "FROM usuario u " +
                  "INNER JOIN rol r ON u.id_rol = r.id_rol " +
                  "INNER JOIN password p ON u.id_usuario = p.id_usuario " +
                  "WHERE u.usuario = ? AND p.hash_actual = ? " +
                  "LIMIT 1";
            
            ps = con.prepareStatement(sql);
            ps.setString(1, "aadministrador.p");
            ps.setString(2, "eab38de360dda0f942457928d3ec4414c6e7d6039c8a815d448f50a58d89f5c7");
            rs = ps.executeQuery();
            
            if (rs.next()) {
                out.println("<p style='color: green; font-weight: bold;'>✅✅✅ QUERY DE LOGIN FUNCIONA</p>");
                out.println("<p>Usuario: <strong>" + rs.getString("usuario") + "</strong></p>");
                out.println("<p>Rol: <strong>" + rs.getString("rol") + "</strong></p>");
            } else {
                out.println("<p style='color: red; font-weight: bold;'>❌ QUERY DE LOGIN FALLÓ</p>");
                out.println("<p>El usuario o la contraseña no coinciden</p>");
            }
            
            out.println("<hr>");
            out.println("<h2>✅ RESUMEN</h2>");
            out.println("<p>Si todos los tests pasaron, el login DEBERÍA funcionar</p>");
            out.println("<p><a href='login.jsp'>Ir al login</a></p>");
            
        } catch (Exception e) {
            out.println("<h2 style='color: red;'>❌ ERROR</h2>");
            out.println("<p>" + e.getMessage() + "</p>");
            out.println("<pre>");
            e.printStackTrace(out);
            out.println("</pre>");
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (con != null) con.close();
            } catch (Exception e) {
                out.println("<p style='color: red;'>Error al cerrar recursos: " + e.getMessage() + "</p>");
            }
        }
        
        out.println("</body>");
        out.println("</html>");
    }
}