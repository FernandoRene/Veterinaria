/*
 * VeterinarioBean.java
 * Bean para gestión de veterinarios
 */
package com.dev.bean;

import com.dev.clases.Veterinario;
import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * Bean para la gestión de veterinarios de la clínica
 * Incluye operaciones CRUD completas
 * @author Fernando
 */
public class VeterinarioBean {
    
    // Atributos
    private Connection connection;
    private PreparedStatement selectVeterinario;
    private PreparedStatement insertVeterinario;
    private PreparedStatement updateVeterinario;
    private PreparedStatement deleteVeterinario;
    private PreparedStatement buscarVeterinario;
    private PreparedStatement selectVeterinariosPorEspecialidad;
    private PreparedStatement selectVeterinariosActivos;
    private VariablesConexion variable;
    
    // Constructor
    public VeterinarioBean() throws SQLException {
        variable = new VariablesConexion();
        variable.iniciarConexion();
        connection = variable.getConnection();
    }
    
    // Método para cerrar conexión
    @PreDestroy
    public void cerrarConexion() {
        variable.cerrarConexion();
    }
    
    /**
     * Lista todos los veterinarios para mostrar en tabla HTML
     * @return String con filas HTML de la tabla
     */
    public String listadoVeterinarios() {
        StringBuilder salida = new StringBuilder();
        StringBuilder query = new StringBuilder();
        
        query.append(" SELECT id_veterinario, nombre_vet, paterno_vet, materno_vet, ");
        query.append(" ci_vet, matricula_profesional, especialidad, telefono, email, estado ");
        query.append(" FROM veterinario ");
        query.append(" ORDER BY paterno_vet, nombre_vet ");
        
        try {
            selectVeterinario = connection.prepareStatement(query.toString());
            ResultSet resultado = selectVeterinario.executeQuery();
            
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>").append(resultado.getInt(1)).append("</td>");
                salida.append("<td>").append(resultado.getString(2)).append("</td>");
                salida.append("<td>").append(resultado.getString(3)).append("</td>");
                salida.append("<td>").append(resultado.getString(4)).append("</td>");
                salida.append("<td>").append(resultado.getString(5)).append("</td>");
                salida.append("<td>").append(resultado.getString(6)).append("</td>");
                salida.append("<td>").append(resultado.getString(7)).append("</td>");
                salida.append("<td>").append(resultado.getString(8)).append("</td>");
                salida.append("<td>").append(resultado.getString(9)).append("</td>");
                
                // Badge de estado
                String estado = resultado.getString(10);
                String badgeClass = estado.equals("ACTIVO") ? "badge-success" : "badge-secondary";
                salida.append("<td><span class='badge ").append(badgeClass).append("'>")
                      .append(estado).append("</span></td>");
                
                // Acciones
                salida.append("<td>");
                salida.append("<a href='modificarVeterinario.jsp?id=").append(resultado.getInt(1))
                      .append("' class='btn btn-sm btn-primary'>Editar</a> ");
                salida.append("<a href='cambiarEstadoVeterinario.jsp?id=").append(resultado.getInt(1))
                      .append("' class='btn btn-sm btn-warning'>Cambiar Estado</a>");
                salida.append("</td>");
                
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error al listar veterinarios: " + e.getMessage());
        }
        
        return salida.toString();
    }
    
    /**
     * Lista veterinarios en formato List para REST o procesamiento
     * @return List de objetos Veterinario
     */
    public List<Veterinario> listarVeterinariosLista() {
        List<Veterinario> lista = new ArrayList<>();
        StringBuilder query = new StringBuilder();
        
        query.append(" SELECT id_veterinario, nombre_vet, paterno_vet, materno_vet, ");
        query.append(" ci_vet, matricula_profesional, especialidad, telefono, email, ");
        query.append(" direccion, fecha_contratacion, estado ");
        query.append(" FROM veterinario ");
        query.append(" WHERE estado = 'ACTIVO' ");
        query.append(" ORDER BY paterno_vet, nombre_vet ");
        
        try {
            selectVeterinario = connection.prepareStatement(query.toString());
            ResultSet resultado = selectVeterinario.executeQuery();
            
            while (resultado.next()) {
                Veterinario vet = new Veterinario();
                vet.setIdVeterinario(resultado.getInt(1));
                vet.setNombreVet(resultado.getString(2));
                vet.setPaternoVet(resultado.getString(3));
                vet.setMaternoVet(resultado.getString(4));
                vet.setCiVet(resultado.getString(5));
                vet.setMatriculaProfesional(resultado.getString(6));
                vet.setEspecialidad(resultado.getString(7));
                vet.setTelefono(resultado.getString(8));
                vet.setEmail(resultado.getString(9));
                vet.setDireccion(resultado.getString(10));
                vet.setFechaContratacion(resultado.getString(11));
                vet.setEstado(resultado.getString(12));
                
                lista.add(vet);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return lista;
    }
    
    /**
     * Registra un nuevo veterinario
     * @param request HttpServletRequest con los datos del formulario
     * @return Mensaje de éxito o error
     */
    public String registrarVeterinario(HttpServletRequest request) {
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        
        query.append(" INSERT INTO veterinario ");
        query.append(" (id_veterinario, nombre_vet, paterno_vet, materno_vet, ci_vet, ");
        query.append(" matricula_profesional, especialidad, telefono, email, direccion, estado) ");
        query.append(" VALUES (nextval('sec_vet'), ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVO') ");
        
        try {
            insertVeterinario = connection.prepareStatement(query.toString());
            
            // Obtener parámetros del formulario
            String nombre = request.getParameter("nombreV");
            String paterno = request.getParameter("paternoV");
            String materno = request.getParameter("maternoV");
            String ci = request.getParameter("ciV");
            String matricula = request.getParameter("matriculaV");
            String especialidad = request.getParameter("especialidadV");
            String telefono = request.getParameter("telefonoV");
            String email = request.getParameter("emailV");
            String direccion = request.getParameter("direccionV");
            
            // Validaciones básicas
            if (nombre == null || nombre.trim().isEmpty() ||
                paterno == null || paterno.trim().isEmpty() ||
                ci == null || ci.trim().isEmpty() ||
                matricula == null || matricula.trim().isEmpty()) {
                return "Error: Todos los campos obligatorios deben ser completados";
            }
            
            // Setear parámetros
            insertVeterinario.setString(1, nombre);
            insertVeterinario.setString(2, paterno);
            insertVeterinario.setString(3, materno);
            insertVeterinario.setString(4, ci);
            insertVeterinario.setString(5, matricula);
            insertVeterinario.setString(6, especialidad);
            insertVeterinario.setString(7, telefono);
            insertVeterinario.setString(8, email);
            insertVeterinario.setString(9, direccion);
            
            // Ejecutar inserción
            int registros = insertVeterinario.executeUpdate();
            
            if (registros == 1) {
                mensaje = "Veterinario registrado exitosamente";
            } else {
                mensaje = "Error al registrar veterinario";
            }
            
        } catch (SQLException e) {
            
            // Manejo de errores específicos
            if (e.getMessage().contains("duplicate key") || 
                e.getMessage().contains("unique constraint")) {
                if (e.getMessage().contains("ci_vet")) {
                    mensaje = "Error: La cédula de identidad ya está registrada";
                } else if (e.getMessage().contains("matricula")) {
                    mensaje = "Error: La matrícula profesional ya está registrada";
                } else {
                    mensaje = "Error: Datos duplicados";
                }
            } else {
                mensaje = "Error de base de datos: " + e.getMessage();
            }
        }
        
        return mensaje;
    }
    
    /**
     * Busca un veterinario por su ID
     * @param idVeterinario ID del veterinario a buscar
     * @return Objeto Veterinario con los datos
     */
    public Veterinario buscarVeterinario(Integer idVeterinario) {
        Veterinario vet = null;
        StringBuilder query = new StringBuilder();
        
        query.append(" SELECT id_veterinario, nombre_vet, paterno_vet, materno_vet, ");
        query.append(" ci_vet, matricula_profesional, especialidad, telefono, email, ");
        query.append(" direccion, fecha_contratacion, estado ");
        query.append(" FROM veterinario ");
        query.append(" WHERE id_veterinario = ? ");
        
        try {
            buscarVeterinario = connection.prepareStatement(query.toString());
            buscarVeterinario.setInt(1, idVeterinario);
            
            ResultSet resultado = buscarVeterinario.executeQuery();
            
            if (resultado.next()) {
                vet = new Veterinario();
                vet.setIdVeterinario(resultado.getInt(1));
                vet.setNombreVet(resultado.getString(2));
                vet.setPaternoVet(resultado.getString(3));
                vet.setMaternoVet(resultado.getString(4));
                vet.setCiVet(resultado.getString(5));
                vet.setMatriculaProfesional(resultado.getString(6));
                vet.setEspecialidad(resultado.getString(7));
                vet.setTelefono(resultado.getString(8));
                vet.setEmail(resultado.getString(9));
                vet.setDireccion(resultado.getString(10));
                vet.setFechaContratacion(resultado.getString(11));
                vet.setEstado(resultado.getString(12));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return vet;
    }
    
    /**
     * Modifica los datos de un veterinario existente
     * @param request HttpServletRequest con los datos del formulario
     * @param idVeterinario ID del veterinario a modificar
     * @return Mensaje de éxito o error
     */
    public String modificarVeterinario(HttpServletRequest request, String idVeterinario) {
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        
        query.append(" UPDATE veterinario SET ");
        query.append(" nombre_vet = ?, paterno_vet = ?, materno_vet = ?, ");
        query.append(" ci_vet = ?, matricula_profesional = ?, especialidad = ?, ");
        query.append(" telefono = ?, email = ?, direccion = ? ");
        query.append(" WHERE id_veterinario = ? ");
        
        try {
            updateVeterinario = connection.prepareStatement(query.toString());
            
            // Obtener parámetros
            String nombre = request.getParameter("nombreV");
            String paterno = request.getParameter("paternoV");
            String materno = request.getParameter("maternoV");
            String ci = request.getParameter("ciV");
            String matricula = request.getParameter("matriculaV");
            String especialidad = request.getParameter("especialidadV");
            String telefono = request.getParameter("telefonoV");
            String email = request.getParameter("emailV");
            String direccion = request.getParameter("direccionV");
            
            // Setear parámetros
            updateVeterinario.setString(1, nombre);
            updateVeterinario.setString(2, paterno);
            updateVeterinario.setString(3, materno);
            updateVeterinario.setString(4, ci);
            updateVeterinario.setString(5, matricula);
            updateVeterinario.setString(6, especialidad);
            updateVeterinario.setString(7, telefono);
            updateVeterinario.setString(8, email);
            updateVeterinario.setString(9, direccion);
            updateVeterinario.setInt(10, Integer.parseInt(idVeterinario));
            
            // Ejecutar actualización
            int registros = updateVeterinario.executeUpdate();
            
            if (registros == 1) {
                mensaje = "Veterinario modificado exitosamente";
            } else {
                mensaje = "Error al modificar veterinario";
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            mensaje = "Error de base de datos: " + e.getMessage();
        }
        
        return mensaje;
    }
    
    /**
     * Cambia el estado de un veterinario (ACTIVO/INACTIVO)
     * @param idVeterinario ID del veterinario
     * @param nuevoEstado Nuevo estado (ACTIVO o INACTIVO)
     * @return Mensaje de éxito o error
     */
    public String cambiarEstadoVeterinario(String idVeterinario, String nuevoEstado) {
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        
        query.append(" UPDATE veterinario SET estado = ? WHERE id_veterinario = ? ");
        
        try {
            updateVeterinario = connection.prepareStatement(query.toString());
            updateVeterinario.setString(1, nuevoEstado);
            updateVeterinario.setInt(2, Integer.parseInt(idVeterinario));
            
            int registros = updateVeterinario.executeUpdate();
            
            if (registros == 1) {
                mensaje = "Estado actualizado a " + nuevoEstado;
            } else {
                mensaje = "Error al cambiar estado";
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            mensaje = "Error: " + e.getMessage();
        }
        
        return mensaje;
    }
    
    /**
     * Genera opciones de select HTML con veterinarios activos
     * @return String con opciones HTML
     */
    public String selectVeterinarios() {
        StringBuilder salidaOption = new StringBuilder();
        StringBuilder query = new StringBuilder();
        
        query.append(" SELECT id_veterinario, ");
        query.append(" nombre_vet || ' ' || paterno_vet || ' ' || materno_vet as nombre_completo, ");
        query.append(" especialidad ");
        query.append(" FROM veterinario ");
        query.append(" WHERE estado = 'ACTIVO' ");
        query.append(" ORDER BY paterno_vet, nombre_vet ");
        
        try {
            selectVeterinariosActivos = connection.prepareStatement(query.toString());
            ResultSet resultado = selectVeterinariosActivos.executeQuery();
            
            while (resultado.next()) {
                salidaOption.append("<option value='");
                salidaOption.append(resultado.getInt(1));
                salidaOption.append("'>");
                salidaOption.append(resultado.getString(2));
                salidaOption.append(" - ").append(resultado.getString(3));
                salidaOption.append("</option>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return salidaOption.toString();
    }
    
    /**
     * Filtra veterinarios por especialidad
     * @param especialidad Especialidad a filtrar
     * @return String con filas HTML de la tabla
     */
    public String filtrarPorEspecialidad(String especialidad) {
        StringBuilder salida = new StringBuilder();
        StringBuilder query = new StringBuilder();
        
        query.append(" SELECT id_veterinario, nombre_vet, paterno_vet, materno_vet, ");
        query.append(" ci_vet, matricula_profesional, especialidad, telefono, estado ");
        query.append(" FROM veterinario ");
        query.append(" WHERE especialidad = ? AND estado = 'ACTIVO' ");
        query.append(" ORDER BY paterno_vet, nombre_vet ");
        
        try {
            selectVeterinariosPorEspecialidad = connection.prepareStatement(query.toString());
            selectVeterinariosPorEspecialidad.setString(1, especialidad);
            
            ResultSet resultado = selectVeterinariosPorEspecialidad.executeQuery();
            
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>").append(resultado.getInt(1)).append("</td>");
                salida.append("<td>").append(resultado.getString(2)).append(" ")
                      .append(resultado.getString(3)).append("</td>");
                salida.append("<td>").append(resultado.getString(5)).append("</td>");
                salida.append("<td>").append(resultado.getString(6)).append("</td>");
                salida.append("<td>").append(resultado.getString(7)).append("</td>");
                salida.append("<td>").append(resultado.getString(8)).append("</td>");
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return salida.toString();
    }
    
    
    public String cambiarEstadoVeterinario(HttpServletRequest request) {
    PreparedStatement ps = null;
    
    try {
        String idVeterinario = request.getParameter("idVeterinario");
        String nuevoEstado = request.getParameter("estado");
        
        if (idVeterinario == null || nuevoEstado == null) {
            return "Error: Faltan parámetros";
        }
        
        String sql = "UPDATE veterinario SET estado = ? WHERE id_veterinario = ?";
        
        ps = connection.prepareStatement(sql);
        ps.setString(1, nuevoEstado);
        ps.setInt(2, Integer.parseInt(idVeterinario));
        
        int filasAfectadas = ps.executeUpdate();
        
        if (filasAfectadas > 0) {
            return "Estado actualizado correctamente";
        } else {
            return "Error: Veterinario no encontrado";
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
}