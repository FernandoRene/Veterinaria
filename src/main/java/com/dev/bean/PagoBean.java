package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class PagoBean extends VariablesConexion {
    
    // Registrar nuevo pago
    public boolean registrarPago(int idMascota, Integer idCita, String tipoAtencion, 
                                double monto, String metodoPago, String nroComprobante,
                                String observaciones, int idUsuarioRegistro) {
        
        String sql = "INSERT INTO pago_atencion (id_pago, id_mascota, id_cita, tipo_atencion, " +
                     "monto, metodo_pago, nro_comprobante, observaciones, estado, " +
                     "fecha_pago, id_usuario_registro) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'PAGADO', CURRENT_TIMESTAMP, ?)";
        
        try {
            // Obtener próximo ID
            String sqlMaxId = "SELECT COALESCE(MAX(id_pago), 0) + 1 FROM pago_atencion";
            Statement stMaxId = getConexion().createStatement();
            ResultSet rsMaxId = stMaxId.executeQuery(sqlMaxId);
            int nuevoId = 1;
            if (rsMaxId.next()) {
                nuevoId = rsMaxId.getInt(1);
            }
            rsMaxId.close();
            stMaxId.close();
            
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setInt(1, nuevoId);
            ps.setInt(2, idMascota);
            
            if (idCita != null && idCita > 0) {
                ps.setInt(3, idCita);
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            
            ps.setString(4, tipoAtencion);
            ps.setDouble(5, monto);
            ps.setString(6, metodoPago);
            ps.setString(7, nroComprobante);
            ps.setString(8, observaciones);
            ps.setInt(9, idUsuarioRegistro);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            System.out.println("[PagoBean] Pago registrado - ID: " + nuevoId + ", Monto: " + monto);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("[PagoBean] Error al registrar pago: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Listar todos los pagos con información completa
    public ArrayList<Map<String, String>> listadoPagos() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT p.id_pago, p.tipo_atencion, p.monto, p.metodo_pago, " +
                     "p.nro_comprobante, p.observaciones, p.estado, p.fecha_pago, " +
                     "m.nombre_mascota, m.tipo, m.raza, " +
                     "pr.nombre_prop, pr.paterno_prop, pr.materno_prop, pr.telefono_prop, " +
                     "c.nro_cita, c.fecha_cita " +
                     "FROM pago_atencion p " +
                     "INNER JOIN mascota m ON p.id_mascota = m.id_mascota " +
                     "INNER JOIN propietario pr ON m.id_propietario = pr.id_propietario " +
                     "LEFT JOIN cita_medica c ON p.id_cita = c.id_cita " +
                     "ORDER BY p.fecha_pago DESC";
        
        try {
            Statement st = getConexion().createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while (rs.next()) {
                Map<String, String> pago = new HashMap<>();
                pago.put("id_pago", String.valueOf(rs.getInt("id_pago")));
                pago.put("tipo_atencion", rs.getString("tipo_atencion"));
                pago.put("monto", String.format("%.2f", rs.getDouble("monto")));
                pago.put("metodo_pago", rs.getString("metodo_pago"));
                pago.put("nro_comprobante", rs.getString("nro_comprobante"));
                pago.put("observaciones", rs.getString("observaciones"));
                pago.put("estado", rs.getString("estado"));
                pago.put("fecha_pago", rs.getString("fecha_pago"));
                
                // Información de la mascota
                pago.put("mascota", rs.getString("nombre_mascota"));
                pago.put("tipo", rs.getString("tipo"));
                pago.put("raza", rs.getString("raza"));
                
                // Información del propietario
                String propietario = rs.getString("nombre_prop") + " " + 
                                    rs.getString("paterno_prop") + " " + 
                                    rs.getString("materno_prop");
                pago.put("propietario", propietario);
                pago.put("telefono_propietario", rs.getString("telefono_prop"));
                
                // Información de la cita (si existe)
                String nroCita = rs.getString("nro_cita");
                if (nroCita != null) {
                    pago.put("nro_cita", nroCita);
                    pago.put("fecha_cita", rs.getString("fecha_cita"));
                } else {
                    pago.put("nro_cita", "N/A");
                    pago.put("fecha_cita", "N/A");
                }
                
                lista.add(pago);
            }
            
            rs.close();
            st.close();
            System.out.println("[PagoBean] Pagos listados: " + lista.size());
            
        } catch (SQLException e) {
            System.out.println("[PagoBean] Error al listar pagos: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Cambiar estado del pago
    public boolean cambiarEstadoPago(int idPago, String nuevoEstado) {
        String sql = "UPDATE pago_atencion SET estado = ? WHERE id_pago = ?";
        
        try {
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setString(1, nuevoEstado);
            ps.setInt(2, idPago);
            
            int resultado = ps.executeUpdate();
            ps.close();
            
            System.out.println("[PagoBean] Estado pago actualizado - ID: " + idPago + " -> " + nuevoEstado);
            return resultado > 0;
            
        } catch (SQLException e) {
            System.out.println("[PagoBean] Error al cambiar estado pago: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // Obtener total de pagos por periodo
    public double obtenerTotalPagos(String fechaInicio, String fechaFin) {
        String sql = "SELECT COALESCE(SUM(monto), 0) as total " +
                     "FROM pago_atencion " +
                     "WHERE estado = 'PAGADO' " +
                     "AND fecha_pago::date BETWEEN ?::date AND ?::date";
        
        try {
            PreparedStatement ps = getConexion().prepareStatement(sql);
            ps.setString(1, fechaInicio);
            ps.setString(2, fechaFin);
            
            ResultSet rs = ps.executeQuery();
            double total = 0;
            
            if (rs.next()) {
                total = rs.getDouble("total");
            }
            
            rs.close();
            ps.close();
            
            return total;
            
        } catch (SQLException e) {
            System.out.println("[PagoBean] Error al obtener total pagos: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    // Listar mascotas activas con sus propietarios
    public ArrayList<Map<String, String>> listadoMascotasActivas() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT m.id_mascota, m.nombre_mascota, m.tipo, m.raza, " +
                     "p.nombre_prop, p.paterno_prop, p.materno_prop " +
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
                
                lista.add(mascota);
            }
            
            rs.close();
            st.close();
            
        } catch (SQLException e) {
            System.out.println("[PagoBean] Error al listar mascotas activas: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
    
    // Listar citas completadas sin pago
    public ArrayList<Map<String, String>> listadoCitasSinPago() {
        ArrayList<Map<String, String>> lista = new ArrayList<>();
        
        String sql = "SELECT c.id_cita, c.nro_cita, c.fecha_cita, c.tipo_consulta, " +
                     "m.id_mascota, m.nombre_mascota, m.tipo, " +
                     "p.nombre_prop, p.paterno_prop, p.materno_prop, " +
                     "v.nombre_vet, v.paterno_vet, v.materno_vet " +
                     "FROM cita_medica c " +
                     "INNER JOIN mascota m ON c.id_mascota = m.id_mascota " +
                     "INNER JOIN propietario p ON m.id_propietario = p.id_propietario " +
                     "INNER JOIN veterinario v ON c.id_veterinario = v.id_veterinario " +
                     "WHERE c.estado = 'ATENDIDA' " +
                     "AND c.id_cita NOT IN (SELECT id_cita FROM pago_atencion WHERE id_cita IS NOT NULL) " +
                     "ORDER BY c.fecha_cita DESC";
        
        try {
            Statement st = getConexion().createStatement();
            ResultSet rs = st.executeQuery(sql);
            
            while (rs.next()) {
                Map<String, String> cita = new HashMap<>();
                cita.put("id_cita", String.valueOf(rs.getInt("id_cita")));
                cita.put("nro_cita", rs.getString("nro_cita"));
                cita.put("fecha_cita", rs.getString("fecha_cita"));
                cita.put("tipo_consulta", rs.getString("tipo_consulta"));
                cita.put("id_mascota", String.valueOf(rs.getInt("id_mascota")));
                
                String mascota = rs.getString("nombre_mascota") + " (" + rs.getString("tipo") + ")";
                cita.put("mascota", mascota);
                
                String propietario = rs.getString("nombre_prop") + " " + 
                                    rs.getString("paterno_prop") + " " + 
                                    rs.getString("materno_prop");
                cita.put("propietario", propietario);
                
                String veterinario = rs.getString("nombre_vet") + " " + 
                                    rs.getString("paterno_vet") + " " + 
                                    rs.getString("materno_vet");
                cita.put("veterinario", veterinario);
                
                lista.add(cita);
            }
            
            rs.close();
            st.close();
            
        } catch (SQLException e) {
            System.out.println("[PagoBean] Error al listar citas sin pago: " + e.getMessage());
            e.printStackTrace();
        }
        
        return lista;
    }
}
