package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class CitaBean extends VariablesConexion {
    
    // Registrar nueva cita
    public boolean registrarCita(int idMascota, int idVeterinario, String tipoConsulta,
                                String fechaCita, String horaCita, int duracionMinutos,
                                String motivo, int idUsuarioRegistro) {
        
        String sql = "INSERT INTO cita_medica (id_cita, nro_cita, id_mascota, id_veterinario, " +
                     "tipo_consulta, fecha_cita, hora_cita, duracion_minutos, motivo, estado, " +
                     "fecha_registro, id_usuario_registro) " +
                     "VALUES (?, ?, ?, ?, ?, ?::date, ?::time, ?, ?, 'PROGRAMADA', CURRENT_TIMESTAMP, ?)";
        
        try {
            // Obtener próximo ID
            String sqlMaxId = "SELECT COALESCE(MAX(id_cita), 0) + 1 FROM cita_medica";
            Statement stMaxId = getConexion().createStatement();
            ResultSet rsMaxId = stMaxId.executeQuery(sqlMaxId);
            int nuevoId = 1;
            if (rsMaxId.next()) {
                nuevoId = rsMaxId.getInt(1);
            }
            rsMaxId.close();
            stMaxId.close();
            
            // Generar número de cita: CITA-YYYYMMDD-XXX
            String nroCita = "CITA-" + fechaCita.replace("-", "") + "-" + String.format("%03d", nuevoId);
            
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setInt(1, nuevoId);
            ps.setString(2, nroCita);
            ps.setInt(3, idMascota);
            ps.setInt(4, idVeterinario);
            ps.setString(5, tipoConsulta);
            ps.setString(6, fechaCita);
            ps.setString(7, horaCita);
            ps.setInt(8, duracionMinutos);
            ps.setString(9, motivo);
            ps.setInt(10, idUsuarioRegistro);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            System.out.println("[CitaBean] Cita registrada - ID: " + nuevoId + ", Nro: " + nroCita);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("[CitaBean] Error al registrar cita: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Listar todas las citas con información completa
    public ArrayList<Map<String, String>> listadoCitas() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT c.id_cita, c.nro_cita, c.tipo_consulta, c.fecha_cita, c.hora_cita, " +
                     "c.duracion_minutos, c.motivo, c.estado, c.fecha_registro, " +
                     "m.nombre_mascota, m.tipo, m.raza, " +
                     "p.nombre_prop, p.paterno_prop, p.materno_prop, p.telefono, " +
                     "v.nombre_vet, v.paterno_vet, v.materno_vet, v.matricula_profesional " +
                     "FROM cita_medica c " +
                     "INNER JOIN mascota m ON c.id_mascota = m.id_mascota " +
                     "INNER JOIN propietario p ON m.id_propietario = p.id_propietario " +
                     "INNER JOIN veterinario v ON c.id_veterinario = v.id_veterinario " +
                     "ORDER BY c.fecha_cita DESC, c.hora_cita DESC";
        
        try {
            Statement st = getConexion().createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while (rs.next()) {
                Map<String, String> cita = new HashMap<>();
                cita.put("id_cita", String.valueOf(rs.getInt("id_cita")));
                cita.put("nro_cita", rs.getString("nro_cita"));
                cita.put("tipo_consulta", rs.getString("tipo_consulta"));
                cita.put("fecha_cita", rs.getString("fecha_cita"));
                cita.put("hora_cita", rs.getString("hora_cita"));
                cita.put("duracion_minutos", String.valueOf(rs.getInt("duracion_minutos")));
                cita.put("motivo", rs.getString("motivo"));
                cita.put("estado", rs.getString("estado"));
                cita.put("fecha_registro", rs.getString("fecha_registro"));
                
                // Información de la mascota
                cita.put("mascota", rs.getString("nombre_mascota"));
                cita.put("especie", rs.getString("tipo"));
                cita.put("raza", rs.getString("raza"));
                
                // Información del propietario
                String propietario = rs.getString("nombre_prop") + " " + 
                                    rs.getString("paterno_prop") + " " + 
                                    rs.getString("materno_prop");
                cita.put("propietario", propietario);
                cita.put("telefono_propietario", rs.getString("telefono"));
                
                // Información del veterinario
                String veterinario = rs.getString("nombre_vet") + " " + 
                                    rs.getString("paterno_vet") + " " + 
                                    rs.getString("materno_vet");
                cita.put("veterinario", veterinario);
                cita.put("matricula_vet", rs.getString("matricula_profesional"));
                
                lista.add(cita);
            }
            
            rs.close();
            st.close();
            System.out.println("[CitaBean] Citas listadas: " + lista.size());
            
        } catch (SQLException e) {
            System.out.println("[CitaBean] Error al listar citas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Cambiar estado de la cita
    public boolean cambiarEstadoCita(int idCita, String nuevoEstado) {
        PreparedStatement ps = null;

        try {
            String sql = "UPDATE cita_medica SET estado = ? WHERE id_cita = ?";

            ps = getConexion().prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idCita);

            int filasAfectadas = ps.executeUpdate();

            System.out.println("[CitaBean] Cambiar estado cita ID " + idCita + 
                              " a " + nuevoEstado + " - Filas afectadas: " + filasAfectadas);

            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("[CitaBean] Error al cambiar estado: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    
    // Cancelar cita
    public boolean cancelarCita(int idCita, String motivoCancelacion, String usuarioCancelacion) {
        String sql = "UPDATE cita_medica SET estado = 'CANCELADA', " +
                     "motivo_cancelacion = ?, fecha_cancelacion = CURRENT_TIMESTAMP, " +
                     "usuario_cancelacion = ? WHERE id_cita = ?";
        
        try {
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setString(1, motivoCancelacion);
            ps.setString(2, usuarioCancelacion);
            ps.setInt(3, idCita);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            System.out.println("[CitaBean] Cita cancelada - ID: " + idCita);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("[CitaBean] Error al cancelar cita: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Agregar observaciones a la cita
    public boolean agregarObservaciones(int idCita, String observaciones) {
        String sql = "UPDATE cita_medica SET observaciones = ? WHERE id_cita = ?";
        
        try {
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setString(1, observaciones);
            ps.setInt(2, idCita);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("[CitaBean] Error al agregar observaciones: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Listar mascotas activas con sus propietarios
    public ArrayList<Map<String, String>> listadoMascotasActivas() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT m.id_mascota, m.nombre_mascota, m.tipo, m.raza, m.genero, " +
                     "p.nombre_prop, p.paterno_prop, p.materno_prop, p.telefono " +
                     "FROM mascota m " +
                     "INNER JOIN propietario p ON m.id_propietario = p.id_propietario " +
                     "WHERE m.estado = 'ACTIVO' " +
                     "ORDER BY m.nombre_mascota";
        
        try {
            Statement st = getConexion().createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while (rs.next()) {
                Map<String, String> mascota = new HashMap<>();
                mascota.put("id_mascota", String.valueOf(rs.getInt("id_mascota")));
                
                String nombreMascota = rs.getString("nombre_mascota") + " (" + 
                                      rs.getString("tipo") + " - " + 
                                      rs.getString("raza") + ")";
                mascota.put("nombre_mascota", nombreMascota);
                
                String propietario = rs.getString("nombre_prop") + " " + 
                                    rs.getString("paterno_prop") + " " + 
                                    rs.getString("materno_prop");
                mascota.put("propietario", propietario);
                mascota.put("telefono", rs.getString("telefono"));
                
                lista.add(mascota);
            }
            
            rs.close();
            st.close();
            
        } catch (SQLException e) {
            System.out.println("[CitaBean] Error al listar mascotas activas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Listar veterinarios activos
    public ArrayList<Map<String, String>> listadoVeterinariosActivos() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT id_veterinario, nombre_vet, paterno_vet, materno_vet, " +
                     "matricula_profesional, especialidad " +
                     "FROM veterinario " +
                     "WHERE estado = 'ACTIVO' " +
                     "ORDER BY paterno_vet, nombre_vet";
        
        try {
            Statement st = getConexion().createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while (rs.next()) {
                Map<String, String> vet = new HashMap<>();
                vet.put("id_veterinario", String.valueOf(rs.getInt("id_veterinario")));
                
                String nombreCompleto = rs.getString("nombre_vet") + " " + 
                                       rs.getString("paterno_vet") + " " + 
                                       rs.getString("materno_vet");
                vet.put("nombre_completo", nombreCompleto);
                vet.put("matricula", rs.getString("matricula_profesional"));
                vet.put("especialidad", rs.getString("especialidad"));
                
                lista.add(vet);
            }
            
            rs.close();
            st.close();
            
        } catch (SQLException e) {
            System.out.println("[CitaBean] Error al listar veterinarios activos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
}
