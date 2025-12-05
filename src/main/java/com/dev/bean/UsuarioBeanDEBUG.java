package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import com.dev.clases.UsuarioRol;
import jakarta.servlet.http.HttpServletRequest;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class UsuarioBeanDEBUG {
    
    private Connection con;
    
    public UsuarioBeanDEBUG() {
        System.out.println("🔵 UsuarioBeanDEBUG - Constructor INICIO");
        VariablesConexion vc = new VariablesConexion();
        this.con = vc.getConnection();
        System.out.println("✅ Conexión obtenida: " + (con != null ? "OK" : "NULL"));
    }
    
    public void cerrarConexion() {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
                System.out.println("✅ Conexión cerrada");
            }
        } catch (Exception e) {
            System.err.println("❌ Error al cerrar conexión: " + e.getMessage());
        }
    }
    
    private String encriptarSHA256(String password) {
        System.out.println("🔵 Encriptando contraseña...");
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            
            String resultado = hexString.toString();
            System.out.println("✅ Hash generado: " + resultado);
            return resultado;
            
        } catch (Exception e) {
            System.err.println("❌ Error al encriptar: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    public UsuarioRol verificarValidez(HttpServletRequest request) {
        System.out.println("🔵 verificarValidez - INICIO");
        
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            // PASO 1: Obtener parámetros
            String usuario = request.getParameter("usuario");
            String password = request.getParameter("password");
            
            System.out.println("   Usuario: " + usuario);
            System.out.println("   Password: " + (password != null ? "***" : "null"));
            
            if (usuario == null || usuario.trim().isEmpty()) {
                System.err.println("❌ Usuario vacío");
                return null;
            }
            
            if (password == null || password.trim().isEmpty()) {
                System.err.println("❌ Password vacío");
                return null;
            }
            
            // PASO 2: Encriptar
            String hash = encriptarSHA256(password);
            if (hash == null) {
                System.err.println("❌ No se pudo generar hash");
                return null;
            }
            
            // PASO 3: Query
            System.out.println("🔵 Ejecutando query...");
            String sql = "SELECT u.id_usuario, u.usuario as codigo, r.id_rol, r.rol " +
                        "FROM usuario u " +
                        "INNER JOIN rol r ON u.id_rol = r.id_rol " +
                        "INNER JOIN password p ON u.id_usuario = p.id_usuario " +
                        "WHERE u.usuario = ? AND p.hash_actual = ? " +
                        "LIMIT 1";
            
            System.out.println("   SQL: " + sql);
            System.out.println("   Param 1: " + usuario);
            System.out.println("   Param 2: " + hash);
            
            ps = con.prepareStatement(sql);
            ps.setString(1, usuario);
            ps.setString(2, hash);
            
            System.out.println("🔵 Ejecutando query...");
            rs = ps.executeQuery();
            System.out.println("✅ Query ejecutado");
            
            // PASO 4: Procesar resultado
            if (rs.next()) {
                System.out.println("✅ USUARIO ENCONTRADO");
                
                UsuarioRol usuarioRol = new UsuarioRol();
                usuarioRol.setCodigo(rs.getString("codigo"));
                usuarioRol.setRol(rs.getString("rol"));
                
                System.out.println("   Código: " + usuarioRol.getCodigo());
                System.out.println("   Rol: " + usuarioRol.getRol());
                
                return usuarioRol;
                
            } else {
                System.err.println("❌ NO SE ENCONTRÓ EL USUARIO");
                System.err.println("   Verifica:");
                System.err.println("   1. Usuario existe: " + usuario);
                System.err.println("   2. Hash en BD: " + hash);
                return null;
            }
            
        } catch (Exception e) {
            System.err.println("❌❌❌ EXCEPCIÓN en verificarValidez ❌❌❌");
            System.err.println("Mensaje: " + e.getMessage());
            e.printStackTrace();
            return null;
            
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (Exception e) {
                System.err.println("❌ Error al cerrar recursos: " + e.getMessage());
            }
        }
    }
}