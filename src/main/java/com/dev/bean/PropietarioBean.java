/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.bean;

import com.dev.clases.Propietario;
import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.ws.rs.POST;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 *
 * @author INCOS
 */
public class PropietarioBean {

    //atributos
    private Connection connection;
    private PreparedStatement selectPropietario;
    private PreparedStatement insertPropietario;
    private PreparedStatement buscarPropietario;
    private PreparedStatement updatePropietario;
    private PreparedStatement deletePropietario;
    private PreparedStatement listaPropietarioSelect;
    private VariablesConexion variable;

    //constructor
    public PropietarioBean() throws SQLException {
        variable = new VariablesConexion();
        //estableciendo el inicio de conexion con la BD
        variable.iniciarConexion();
        //obteniendo la conexion
        connection = variable.getConnection();
    }

    //metodos
    @PreDestroy
    public void cerrarConexion() {
        //llamando al metodo para cerrar la conexion
        variable.cerrarConexion();
    }

        public String listadoPropietarios() {
        StringBuilder salida = new StringBuilder();
        StringBuilder query = new StringBuilder();
        //definiendo la consulta sql para mostrar todos los propietarios
        query.append(" select * ");
        query.append(" from propietario ");
        try {
            selectPropietario = connection.prepareStatement(query.toString());
            //obteniendo el resutado de la consulta
            ResultSet resultado = selectPropietario.executeQuery();
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>");
                salida.append(resultado.getInt(1));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(2));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(3));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(4));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(5));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(6));
                salida.append("</td>");
                salida.append("<td>");
                salida.append("<a href=modificarPropietario.jsp?id=").append(resultado.getInt(1)).append(">Modificar</a>");
                salida.append("</td>");
                salida.append("<td>");
                salida.append("<a href='listaPropietario.jsp?id=").append(resultado.getInt(1)).append("'onclick='return confirmarEliminacion();'>Eliminar</a>");
                salida.append("</td>");
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return salida.toString();
    }
    
    public List<Propietario> listadoPropietariosRest() {

        StringBuilder query = new StringBuilder();
        List<Propietario> lista = new ArrayList<>();
        
        //definiendo la consulta sql para mostrar todos los propietarios
        query.append(" select * ");
        query.append(" from propietario ");
        try {
            selectPropietario = connection.prepareStatement(query.toString());
            //obteniendo el resutado de la consulta
            ResultSet resultado = selectPropietario.executeQuery();
            
            Propietario propietario = null;
            
            while (resultado.next()) {
                
                propietario = new Propietario();

                propietario.setIdProp(resultado.getInt(1));
                propietario.setNomProp(resultado.getString(2));
                propietario.setPatProp(resultado.getString(3));
                propietario.setMatProp(resultado.getString(4));
                propietario.setDirProp(resultado.getString(5));
                propietario.setTelProp(resultado.getString(6));
                
                lista.add(propietario);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return lista;
    }

    public Propietario registrarPropietarioRest(Propietario propietario) {

        StringBuilder query = new StringBuilder();
        query.append(" insert into propietario ");
        query.append(" values(nextval('sec_pro'),?,?,?,?,?)");
        try {
            insertPropietario = connection.prepareStatement(query.toString());
            //rescatando los valores de formulario
            String nom = propietario.getNomProp();
            String pat = propietario.getPatProp();
            String mat = propietario.getMatProp();
            String dir = propietario.getDirProp();
            String tel = propietario.getTelProp();
            //pasando los valores rescatados a los parametros de la consulta
            insertPropietario.setString(1, nom);
            insertPropietario.setString(2, pat);
            insertPropietario.setString(3, mat);
            insertPropietario.setString(4, dir);
            insertPropietario.setString(5, tel);
            //ejecutando la consulta

            int nroRegistros = insertPropietario.executeUpdate();
            if (nroRegistros == 1) {
                System.out.println("Datos registrados");
                propietario.setCodigo("200");
                propietario.setMensaje("Datos registrados");
            } else {
                System.out.println("Existio un error en el registro");
                propietario.setCodigo("400");
                propietario.setMensaje("Datos registrados");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            propietario.setCodigo("500");
            propietario.setMensaje(e.getMessage());
        }

        return propietario;
    }
    
    public String registrarPropietario(HttpServletRequest request) {
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        query.append(" insert into propietario ");
        query.append(" values(nextval('sec_pro'),?,?,?,?,?)");
        try {
            insertPropietario = connection.prepareStatement(query.toString());
            //rescatando los valores de formulario
            String nom = request.getParameter("nombreP");
            String pat = request.getParameter("paternoP");
            String mat = request.getParameter("maternoP");
            String dir = request.getParameter("direccionP");
            String tel = request.getParameter("telefonoP");
            //pasando los valores rescatados a los parametros de la consulta
            insertPropietario.setString(1, nom);
            insertPropietario.setString(2, pat);
            insertPropietario.setString(3, mat);
            insertPropietario.setString(4, dir);
            insertPropietario.setString(5, tel);
            //ejecutando la consulta
            int nroRegistros = insertPropietario.executeUpdate();
            if (nroRegistros == 1) {
                mensaje = "Datos registrados";
            } else {
                mensaje = "Existio un error en el registro";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            mensaje = "Error: " + e.getMessage();
        }

        return mensaje;
    }

    public Propietario buscar(Integer idPropietario) {
        Propietario prop = null;
        StringBuilder query = new StringBuilder();
        query.append(" SELECT id_propietario, nombre_prop, paterno_prop, materno_prop, direccion, telefono ");
        query.append(" FROM propietario p ");
        query.append(" where p.id_propietario=? ");

        try {
            prop = new Propietario();
            buscarPropietario = connection.prepareStatement(query.toString());
            //pasando el parametro a la consulta
            buscarPropietario.setInt(1, idPropietario);
            //ejecutar la consulta
            ResultSet resultado = buscarPropietario.executeQuery();
            if (resultado.next()) {
                prop.setIdProp(resultado.getInt(1));
                prop.setNomProp(resultado.getString(2));
                prop.setPatProp(resultado.getString(3));
                prop.setMatProp(resultado.getString(4));
                prop.setDirProp(resultado.getString(5));
                prop.setTelProp(resultado.getString(6));
            } else {
                System.out.println("Error de consulta");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error de conexion");
        }
        return prop;
    }

    public String modificarPropietario(HttpServletRequest request, String idPropietario) {
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        query.append(" UPDATE propietario ");
        query.append(" SET  nombre_prop=?, paterno_prop=?, materno_prop=?, direccion=?, telefono=? ");
        query.append(" WHERE id_propietario=? ");
        try {
            updatePropietario = connection.prepareStatement(query.toString());
            //rescatando los parametros del formulario
            String nom = request.getParameter("nombreP");
            String pat = request.getParameter("paternoP");
            String mat = request.getParameter("maternoP");
            String dir = request.getParameter("direccionP");
            String tel = request.getParameter("telefonoP");
            //pasando los parametros a la consulta
            updatePropietario.setString(1, nom);
            updatePropietario.setString(2, pat);
            updatePropietario.setString(3, mat);
            updatePropietario.setString(4, dir);
            updatePropietario.setString(5, tel);
            updatePropietario.setInt(6, Integer.parseInt(idPropietario == null ? "0" : idPropietario));
            //ejecutando la consulta
            int nroRegistros = updatePropietario.executeUpdate();
            if (nroRegistros == 1) {
                mensaje = "Modificacion registrada";
            } else {
                mensaje = "Error al realizar la modificacion";
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error al realizar la operacion update");
        }

        return mensaje;
    }
    
    public Propietario modificarPropietarioRest(Propietario propietario) {
        
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        query.append(" UPDATE propietario ");
        query.append(" SET  nombre_prop=?, paterno_prop=?, materno_prop=?, direccion=?, telefono=? ");
        query.append(" WHERE id_propietario=? ");
        try {
            updatePropietario = connection.prepareStatement(query.toString());
            //rescatando los parametros del formulario
            String nom = propietario.getNomProp();
            String pat = propietario.getPatProp();
            String mat = propietario.getMatProp();
            String dir = propietario.getDirProp();
            String tel = propietario.getTelProp();
            //pasando los parametros a la consulta
            updatePropietario.setString(1, nom);
            updatePropietario.setString(2, pat);
            updatePropietario.setString(3, mat);
            updatePropietario.setString(4, dir);
            updatePropietario.setString(5, tel);
            updatePropietario.setInt(6, propietario.getIdProp());
            //ejecutando la consulta
            int nroRegistros = updatePropietario.executeUpdate();
            if (nroRegistros == 1) {
                mensaje = "Modificacion registrada";
                propietario.setCodigo("200");
                propietario.setMensaje(mensaje);
            } else {
                mensaje = "Error al realizar la modificacion";
                propietario.setCodigo("400");
                propietario.setMensaje(mensaje);                
            }

        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error al realizar la operacion update");
            propietario.setCodigo("500");
            propietario.setMensaje("Error al realizar la operacion update");
        }

        return propietario;
    }

    public String eliminarPropietario(String idPropietario) {
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        query.append(" DELETE FROM propietario ");
        query.append(" WHERE id_propietario=? ");
        try {
            deletePropietario = connection.prepareStatement(query.toString());
            //le paso el parametro que requiere la consulta
            deletePropietario.setInt(1, Integer.parseInt(idPropietario == null ? "0" : idPropietario));
            //ejecutando la consulta sql
            int nroRegistros = deletePropietario.executeUpdate();
            if (nroRegistros == 1) {
                mensaje = "Registro eliminado correctamente";
            } else {
                mensaje = "Error al realizar la eliminacion";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error al realizar la consulta delete ...");
        }
        return mensaje;
    }

    /**
     * El metodo devuelve los option para listar los propietarios
     *
     * @return los option
     */
    public String selectPropietario() {
        StringBuilder salidaOption = new StringBuilder();
        StringBuilder query = new StringBuilder();
        query.append(" select p.id_propietario,p.paterno_prop || ' '|| p.materno_prop ||' '|| p.nombre_prop as nom_completo ");
        query.append(" from propietario p ");
        query.append(" order by nom_completo ");
        try {
            listaPropietarioSelect=connection.prepareStatement(query.toString());
            ResultSet resultado=listaPropietarioSelect.executeQuery();
            while(resultado.next()){
                salidaOption.append("<option value='");
                salidaOption.append(resultado.getInt(1));
                salidaOption.append("'>");
                salidaOption.append(resultado.getString(2));
                salidaOption.append("</option>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error de conexion");
        }

        return salidaOption.toString();
    }

}
