package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import com.dev.clases.UsuarioRol;
import jakarta.servlet.http.HttpServletRequest;
import java.security.MessageDigest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UsuarioBean {
    
    private Connection con;
    
    public UsuarioBean() {
        VariablesConexion vc = new VariablesConexion();
        this.con = vc.getConnection();
    }
    
    public void cerrarConexion() {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    private String encriptarSHA256(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    public UsuarioRol verificarValidez(HttpServletRequest request) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            String usuario = request.getParameter("usuario");
            String password = request.getParameter("password");
            
            if (usuario == null || password == null) {
                return null;
            }
            
            String hash = encriptarSHA256(password);
            if (hash == null) {
                return null;
            }
            
            System.out.println("Verificando usuario: " + usuario);
            System.out.println("Hash: " + hash);
            
            String sql = "SELECT u.id_usuario, u.codigo, u.nombre_usu, u.paterno_usu, u.materno_usu, " +
                        "u.direccion_usu, u.telefono_usu, u.nro_cedula, " +
                        "r.id_rol, r.nombre_rol " +
                        "FROM usuario u " +
                        "INNER JOIN rol r ON u.id_rol = r.id_rol " +
                        "INNER JOIN password p ON u.id_usuario = p.id_usuario " +
                        "WHERE u.codigo = ? " +
                        "AND p.pass = ? " +
                        "AND u.estado_usu = 'ACTIVO' " +
                        "AND p.estado_pass = 'ACTIVO' " +
                        "LIMIT 1";
            
            ps = con.prepareStatement(sql);
            ps.setString(1, usuario);
            ps.setString(2, hash);
            
            rs = ps.executeQuery();
            
            if (rs.next()) {
                UsuarioRol usuarioRol = new UsuarioRol();
                usuarioRol.setCodigo(rs.getString("codigo"));
                usuarioRol.setRol(rs.getString("nombre_rol"));

                String nombre = rs.getString("nombre_usu") != null ? rs.getString("nombre_usu") : "";
                String paterno = rs.getString("paterno_usu") != null ? rs.getString("paterno_usu") : "";
                String materno = rs.getString("materno_usu") != null ? rs.getString("materno_usu") : "";
                String nombreCompleto = (nombre + " " + paterno + " " + materno).trim();
                usuarioRol.setNombreCompleto(nombreCompleto);

                System.out.println("✅ Usuario encontrado: " + usuarioRol.getCodigo() + " - " + nombreCompleto);
                return usuarioRol;
            } else {
                System.err.println("❌ Usuario o contraseña incorrectos");
                return null;
            }
            
        } catch (SQLException e) {
            System.err.println("❌ Error SQL: " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public String listadoUsuario() {
        PreparedStatement ps = null;
        ResultSet rs = null;
        StringBuilder html = new StringBuilder();
        
        try {
            String sql = "SELECT u.id_usuario, u.codigo, u.nombre_usu, u.paterno_usu, u.materno_usu, " +
                        "u.direccion_usu, u.telefono_usu, u.nro_cedula, r.nombre_rol " +
                        "FROM usuario u " +
                        "INNER JOIN rol r ON u.id_rol = r.id_rol " +
                        "WHERE u.estado_usu = 'ACTIVO' " +
                        "ORDER BY u.id_usuario DESC";
            
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                int idUsuario = rs.getInt("id_usuario");
                String codigo = rs.getString("codigo");
                
                html.append("<tr>");
                html.append("<td>").append(codigo).append("</td>");
                html.append("<td>").append(rs.getString("nombre_usu")).append("</td>");
                html.append("<td>").append(rs.getString("paterno_usu")).append("</td>");
                html.append("<td>").append(rs.getString("materno_usu") != null ? rs.getString("materno_usu") : "").append("</td>");
                html.append("<td>").append(rs.getString("direccion_usu") != null ? rs.getString("direccion_usu") : "").append("</td>");
                html.append("<td>").append(rs.getString("telefono_usu") != null ? rs.getString("telefono_usu") : "").append("</td>");
                html.append("<td>").append(rs.getString("nro_cedula")).append("</td>");
                html.append("<td>").append(rs.getString("nombre_rol")).append("</td>");
                html.append("<td>");
                html.append("<a href='cambiarEstadoUsuario.jsp?id=").append(idUsuario).append("&codigo=").append(codigo).append("' ");
                html.append("style='padding: 6px 12px; background: #ffc107; color: #000; text-decoration: none; ");
                html.append("border-radius: 4px; font-size: 12px; margin-right: 5px;'>Cambiar Estado</a>");
                html.append("<a href='cambiarPasswordUsuario.jsp?codigo=").append(codigo).append("' ");
                html.append("style='padding: 6px 12px; background: #17a2b8; color: white; text-decoration: none; ");
                html.append("border-radius: 4px; font-size: 12px;'>Cambiar Contraseña</a>");
                html.append("</td>");
                html.append("</tr>");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        
        return html.toString();
    }
    
    public String registrarUsuario(HttpServletRequest request) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            String nombre = request.getParameter("nombre");
            String paterno = request.getParameter("paterno");
            String materno = request.getParameter("materno");
            String direccion = request.getParameter("direccion");
            String telefono = request.getParameter("telefono");
            String nroCedula = request.getParameter("nroCedula");
            String idRol = request.getParameter("idRol");
            String password = request.getParameter("password");
            
            if (nombre == null || paterno == null || nroCedula == null || idRol == null || password == null) {
                return "Error: Faltan datos obligatorios";
            }
            
            if (password.length() < 6) {
                return "Error: La contraseña debe tener al menos 6 caracteres";
            }
            
            // Generar código de usuario
            String codigo = (nombre.substring(0, 1) + paterno).toLowerCase() + "." + nroCedula.substring(0, 1);
            
            // Verificar si el código ya existe
            String sqlVerificar = "SELECT codigo FROM usuario WHERE codigo = ?";
            ps = con.prepareStatement(sqlVerificar);
            ps.setString(1, codigo);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return "Error: El código de usuario ya existe";
            }
            rs.close();
            ps.close();
            
            con.setAutoCommit(false);
            
            // Obtener el próximo ID manualmente
            String sqlMaxId = "SELECT COALESCE(MAX(id_usuario), 0) + 1 as next_id FROM usuario";
            ps = con.prepareStatement(sqlMaxId);
            rs = ps.executeQuery();
            int nextId = 1;
            if (rs.next()) {
                nextId = rs.getInt("next_id");
            }
            rs.close();
            ps.close();
            
            // Insertar usuario con ID explícito
            String sqlUsuario = "INSERT INTO usuario (id_usuario, codigo, nombre_usu, paterno_usu, materno_usu, " +
                               "direccion_usu, telefono_usu, nro_cedula, id_rol, estado_usu) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVO')";
            
            ps = con.prepareStatement(sqlUsuario);
            ps.setInt(1, nextId);
            ps.setString(2, codigo);
            ps.setString(3, nombre);
            ps.setString(4, paterno);
            ps.setString(5, materno);
            ps.setString(6, direccion);
            ps.setString(7, telefono);
            ps.setString(8, nroCedula);
            ps.setInt(9, Integer.parseInt(idRol));
            
            ps.executeUpdate();
            ps.close();
            
            int idUsuario = nextId;
            
            // Encriptar y guardar contraseña
            String passwordEncriptado = encriptarSHA256(password);
            
            // Obtener próximo ID de password
            String sqlMaxPassId = "SELECT COALESCE(MAX(id_pass), 0) + 1 as next_id FROM password";
            ps = con.prepareStatement(sqlMaxPassId);
            rs = ps.executeQuery();
            int nextPassId = 1;
            if (rs.next()) {
                nextPassId = rs.getInt("next_id");
            }
            rs.close();
            ps.close();
            
            String sqlPassword = "INSERT INTO password (id_pass, id_usuario, pass, f_creacion, f_vencimiento, " +
                                "intentos, estado_pass) " +
                                "VALUES (?, ?, ?, CURRENT_DATE, CURRENT_DATE + INTERVAL '180 days', 0, 'ACTIVO')";
            
            ps = con.prepareStatement(sqlPassword);
            ps.setInt(1, nextPassId);
            ps.setInt(2, idUsuario);
            ps.setString(3, passwordEncriptado);
            ps.executeUpdate();
            ps.close();
            
            con.commit();
            con.setAutoCommit(true);
            
            // ENFOQUE B: Si el rol es VETERINARIO (id_rol = 2), crear registro en tabla veterinario
            if (Integer.parseInt(idRol) == 2) {
                try {
                    // Obtener próximo ID de veterinario
                    String sqlMaxVetId = "SELECT COALESCE(MAX(id_veterinario), 0) + 1 as next_id FROM veterinario";
                    ps = con.prepareStatement(sqlMaxVetId);
                    rs = ps.executeQuery();
                    int nextVetId = 1;
                    if (rs.next()) {
                        nextVetId = rs.getInt("next_id");
                    }
                    rs.close();
                    ps.close();
                    
                    // Generar matrícula automática: VET-XXX
                    String matricula = String.format("VET-%03d", nextVetId);
                    
                    // Insertar en tabla veterinario
                    String sqlVeterinario = "INSERT INTO veterinario (id_veterinario, nombre_vet, paterno_vet, " +
                                           "materno_vet, ci_vet, matricula_profesional, especialidad, " +
                                           "telefono, email, direccion, fecha_contratacion, estado) " +
                                           "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_DATE, 'ACTIVO')";
                    
                    ps = con.prepareStatement(sqlVeterinario);
                    ps.setInt(1, nextVetId);
                    ps.setString(2, nombre);
                    ps.setString(3, paterno);
                    ps.setString(4, materno);
                    ps.setString(5, nroCedula);
                    ps.setString(6, matricula);
                    ps.setString(7, "Medicina General"); // Especialidad por defecto
                    ps.setString(8, telefono);
                    ps.setString(9, codigo + "@vetclinic.com"); // Email automático
                    ps.setString(10, direccion);
                    
                    ps.executeUpdate();
                    ps.close();
                    
                    return "Usuario y veterinario registrados exitosamente.<br>" +
                           "Código usuario: " + codigo + "<br>" +
                           "Matrícula veterinario: " + matricula;
                    
                } catch (SQLException e) {
                    System.err.println("Error al crear veterinario: " + e.getMessage());
                    return "Usuario registrado exitosamente. Código: " + codigo + 
                           "<br>Advertencia: No se pudo crear el registro de veterinario";
                }
            }
            
            return "Usuario registrado exitosamente. Código: " + codigo;
            
        } catch (SQLException e) {
            try {
                con.rollback();
                con.setAutoCommit(true);
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            return "Error: " + e.getMessage();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public String cambiarEstadoUsuario(HttpServletRequest request) {
        PreparedStatement ps = null;
        
        try {
            String idUsuario = request.getParameter("idUsuario");
            String nuevoEstado = request.getParameter("estado");
            
            if (idUsuario == null || nuevoEstado == null) {
                return "Error: Faltan parámetros";
            }
            
            String sql = "UPDATE usuario SET estado_usu = ? WHERE id_usuario = ?";
            
            ps = con.prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2, Integer.parseInt(idUsuario));
            
            int filasAfectadas = ps.executeUpdate();
            
            if (filasAfectadas > 0) {
                return "Estado actualizado correctamente";
            } else {
                return "Error: Usuario no encontrado";
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            return "Error: " + e.getMessage();
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    public String cambiarPasswordUsuario(HttpServletRequest request) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            String codigo = request.getParameter("codigo");
            String nuevaPassword = request.getParameter("nuevaPassword");
            
            if (codigo == null || nuevaPassword == null) {
                return "Error: Faltan parámetros";
            }
            
            if (nuevaPassword.length() < 6) {
                return "Error: La contraseña debe tener al menos 6 caracteres";
            }
            
            // Obtener id_usuario
            String sqlGetId = "SELECT id_usuario FROM usuario WHERE codigo = ?";
            ps = con.prepareStatement(sqlGetId);
            ps.setString(1, codigo);
            rs = ps.executeQuery();
            
            if (!rs.next()) {
                return "Error: Usuario no encontrado";
            }
            
            int idUsuario = rs.getInt("id_usuario");
            rs.close();
            ps.close();
            
            // Desactivar contraseña anterior
            String sqlDesactivar = "UPDATE password SET estado_pass = 'INACTIVO' WHERE id_usuario = ?";
            ps = con.prepareStatement(sqlDesactivar);
            ps.setInt(1, idUsuario);
            ps.executeUpdate();
            ps.close();
            
            // Encriptar nueva contraseña
            String passwordEncriptado = encriptarSHA256(nuevaPassword);
            
            // Obtener próximo ID de password
            String sqlMaxPassId = "SELECT COALESCE(MAX(id_pass), 0) + 1 as next_id FROM password";
            ps = con.prepareStatement(sqlMaxPassId);
            rs = ps.executeQuery();
            int nextPassId = 1;
            if (rs.next()) {
                nextPassId = rs.getInt("next_id");
            }
            rs.close();
            ps.close();
            
            // Insertar nueva contraseña
            String sqlInsert = "INSERT INTO password (id_pass, id_usuario, pass, f_creacion, f_vencimiento, " +
                              "intentos, estado_pass) " +
                              "VALUES (?, ?, ?, CURRENT_DATE, CURRENT_DATE + INTERVAL '180 days', 0, 'ACTIVO')";
            
            ps = con.prepareStatement(sqlInsert);
            ps.setInt(1, nextPassId);
            ps.setInt(2, idUsuario);
            ps.setString(3, passwordEncriptado);
            ps.executeUpdate();
            ps.close();
            
            return "Contraseña actualizada correctamente. Válida por 180 días.";
            
        } catch (SQLException e) {
            e.printStackTrace();
            return "Error: " + e.getMessage();
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}