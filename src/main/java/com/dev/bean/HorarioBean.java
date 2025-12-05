package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class HorarioBean extends VariablesConexion {
    
    // Registrar nuevo horario
    public boolean registrarHorario(int idVeterinario, String diaSemana, String horaInicio, 
                                   String horaFin, String turno, int idUsuarioRegistro) {
        String sql = "INSERT INTO horario_veterinario (id_horario, id_veterinario, dia_semana, " +
                     "hora_inicio, hora_fin, turno, estado, id_usuario_registro) " +
                     "VALUES (?, ?, ?, ?::time, ?::time, ?, 'ACTIVO', ?)";
        
        try {
            // Obtener próximo ID
            String sqlMaxId = "SELECT COALESCE(MAX(id_horario), 0) + 1 FROM horario_veterinario";
            Statement stMaxId = getConexion().createStatement();
            ResultSet rsMaxId = stMaxId.executeQuery(sqlMaxId);
            int nuevoId = 1;
            if (rsMaxId.next()) {
                nuevoId = rsMaxId.getInt(1);
            }
            rsMaxId.close();
            stMaxId.close();
            
            // Insertar horario
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setInt(1, nuevoId);
            ps.setInt(2, idVeterinario);
            ps.setString(3, diaSemana);
            ps.setString(4, horaInicio);
            ps.setString(5, horaFin);
            ps.setString(6, turno);
            ps.setInt(7, idUsuarioRegistro);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            System.out.println("[HorarioBean] Horario registrado - ID: " + nuevoId);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("[HorarioBean] Error al registrar horario: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Listar horarios con información del veterinario
    public ArrayList<Map<String, String>> listadoHorarios() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT h.id_horario, h.id_veterinario, h.dia_semana, " +
                     "h.hora_inicio, h.hora_fin, h.turno, h.estado, " +
                     "v.nombre_vet, v.paterno_vet, v.materno_vet, v.matricula_profesional, v.especialidad " +
                     "FROM horario_veterinario h " +
                     "INNER JOIN veterinario v ON h.id_veterinario = v.id_veterinario " +
                     "ORDER BY v.paterno_vet, h.dia_semana, h.hora_inicio";
        
        try {
            Statement st = getConexion().createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while (rs.next()) {
                Map<String, String> horario = new HashMap<>();
                horario.put("id_horario", String.valueOf(rs.getInt("id_horario")));
                horario.put("id_veterinario", String.valueOf(rs.getInt("id_veterinario")));
                horario.put("dia_semana", rs.getString("dia_semana"));
                horario.put("hora_inicio", rs.getString("hora_inicio"));
                horario.put("hora_fin", rs.getString("hora_fin"));
                horario.put("turno", rs.getString("turno"));
                horario.put("estado", rs.getString("estado"));
                
                String nombreCompleto = rs.getString("nombre_vet") + " " + 
                                       rs.getString("paterno_vet") + " " + 
                                       rs.getString("materno_vet");
                horario.put("veterinario", nombreCompleto);
                horario.put("matricula", rs.getString("matricula_profesional"));
                horario.put("especialidad", rs.getString("especialidad"));
                
                lista.add(horario);
            }
            
            rs.close();
            st.close();
            System.out.println("[HorarioBean] Horarios listados: " + lista.size());
            
        } catch (SQLException e) {
            System.out.println("[HorarioBean] Error al listar horarios: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Listar horarios por veterinario
    public ArrayList<Map<String, String>> listadoHorariosPorVeterinario(int idVeterinario) {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT id_horario, dia_semana, hora_inicio, hora_fin, turno, estado " +
                     "FROM horario_veterinario " +
                     "WHERE id_veterinario = ? " +
                     "ORDER BY CASE dia_semana " +
                     "  WHEN 'LUNES' THEN 1 " +
                     "  WHEN 'MARTES' THEN 2 " +
                     "  WHEN 'MIERCOLES' THEN 3 " +
                     "  WHEN 'JUEVES' THEN 4 " +
                     "  WHEN 'VIERNES' THEN 5 " +
                     "  WHEN 'SABADO' THEN 6 " +
                     "  WHEN 'DOMINGO' THEN 7 " +
                     "END, hora_inicio";
        
        try {
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setInt(1, idVeterinario);
            ResultSet rs = ps.executeQuery();
            
            while (rs.next()) {
                Map<String, String> horario = new HashMap<>();
                horario.put("id_horario", String.valueOf(rs.getInt("id_horario")));
                horario.put("dia_semana", rs.getString("dia_semana"));
                horario.put("hora_inicio", rs.getString("hora_inicio"));
                horario.put("hora_fin", rs.getString("hora_fin"));
                horario.put("turno", rs.getString("turno"));
                horario.put("estado", rs.getString("estado"));
                
                lista.add(horario);
            }
            
            rs.close();
            ps.close();
            
        } catch (SQLException e) {
            System.out.println("[HorarioBean] Error al listar horarios por veterinario: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Cambiar estado del horario
    public boolean cambiarEstadoHorario(int idHorario, String nuevoEstado) {
        PreparedStatement ps = null;

        try {
            String sql = "UPDATE horario_veterinario SET estado = ? WHERE id_horario = ?";

            ps = getConexion().prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idHorario);

            int filasAfectadas = ps.executeUpdate();

            System.out.println("[HorarioBean] Cambiar estado horario ID " + idHorario + 
                              " a " + nuevoEstado + " - Filas afectadas: " + filasAfectadas);

            return filasAfectadas > 0;

        } catch (SQLException e) {
            System.err.println("[HorarioBean] Error al cambiar estado: " + e.getMessage());
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
    
    // Eliminar horario (borrado lógico)
    public boolean eliminarHorario(int idHorario) {
        return cambiarEstadoHorario(idHorario, "INACTIVO");
    }
    
    // Listar veterinarios activos para el combo
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
            System.out.println("[HorarioBean] Error al listar veterinarios activos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
}
