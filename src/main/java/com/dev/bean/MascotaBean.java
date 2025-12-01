/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import jakarta.servlet.http.HttpServletRequest;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


/**
 *
 * @author INCOS
 */
public class MascotaBean {
    //atributos

    private Connection connection;
    private PreparedStatement selectMascota;
    private PreparedStatement buscarMascotaTipo;
    private PreparedStatement buscarMascotaPropietario;
    private PreparedStatement insertMascota;
    private VariablesConexion variable;
    //constructor

    public MascotaBean() throws SQLException {
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

    public String listaMascotas() {
        StringBuilder salida = new StringBuilder();
        StringBuilder query = new StringBuilder();
        //definiendo la consulta sql para mostrar todos los propietarios
        query.append(" select p.nombre_prop,p.paterno_prop,m.nombre_mascota,m.tipo,m.color,m.raza,m.f_nacimiento,m.peso,m.genero ");
        query.append(" from mascota m ");
        query.append(" inner join propietario p on p.id_propietario=m.id_propietario ");
        try {
            selectMascota = connection.prepareStatement(query.toString());
            //obteniendo el resutado de la consulta
            ResultSet resultado = selectMascota.executeQuery();
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>");
                salida.append(resultado.getString(1));
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
                salida.append(resultado.getString(7));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(8));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(9));
                salida.append("</td>");
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return salida.toString();
    }

    public String buscarMascota(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        StringBuilder salida = new StringBuilder();
        query.append(" select m.nombre_mascota,m.tipo,m.raza,m.color,m.peso,p.nombre_prop||' '||p.paterno_prop ");
        query.append(" from mascota m ");
        query.append(" inner join propietario p on p.id_propietario=m.id_propietario ");
        query.append(" where m.tipo=? ");

        try {
            buscarMascotaTipo = connection.prepareStatement(query.toString());
            String tipo = request.getParameter("listaTipo");
            buscarMascotaTipo.setString(1, tipo);
            System.out.println("consulta:" + query);
            ResultSet resultado = buscarMascotaTipo.executeQuery();
            //la ejecucion de la consuta devueve varios registros
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>");
                salida.append(resultado.getString(1));
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
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en la ejecucion de la consulta");
        }
        return salida.toString();
    }
  public String buscarMascotaPropietario(String idPropietario) {
        StringBuilder query = new StringBuilder();
        StringBuilder salida = new StringBuilder();
        query.append(" select m.nombre_mascota,m.tipo,m.raza,m.color,m.peso,m.f_nacimiento,p.nombre_prop||' '||p.paterno_prop as propietario ");
        query.append(" from mascota m ");
        query.append(" inner join propietario p on p.id_propietario=m.id_propietario ");
        query.append(" where m.id_propietario=? ");

        try {
            buscarMascotaPropietario = connection.prepareStatement(query.toString());            
            buscarMascotaPropietario.setInt(1, Integer.parseInt(idPropietario));
            System.out.println("consulta:" + query);
            ResultSet resultado = buscarMascotaPropietario.executeQuery();
            //la ejecucion de la consuta devueve varios registros
           
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>");
                salida.append(resultado.getString(1));
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
                salida.append(resultado.getDate(6));
                salida.append("</td>"); 
                  salida.append("<td>");
                salida.append(resultado.getString(7));
                salida.append("</td>"); 
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en la ejecucion de la consulta");
        }
        return salida.toString();
    }

    public String registrarMascota(HttpServletRequest request, InputStream fileContent) {
        //  ManejoFechas obj=new ManejoFechas();
        String mensaje = "";
        StringBuilder query = new StringBuilder();
        query.append(" INSERT INTO mascota(id_mascota, id_propietario, nombre_mascota, tipo, color, raza,f_nacimiento, peso,genero, foto ) ");
        query.append(" VALUES (nextval('sec_mas'), ?, ?, ?, ?, ?, ?, ?, ?, ?) ");
        System.out.println("consulta: " + query.toString());
        try {
            insertMascota = connection.prepareStatement(query.toString());
            //rescatando los datos del formulario de registroMascota.jsp
            int idPropietario = Integer.parseInt(request.getParameter("idPropietario"));
            String nombre = request.getParameter("nombreM");
            String tipo = request.getParameter("tipoM");
            String raza = request.getParameter("razaM");
            String color = request.getParameter("colorM");
            double peso = Double.parseDouble(request.getParameter("pesoM"));
            String nacimiento = request.getParameter("fMascota");
            String genero = request.getParameter("genero");
            //pasando los parametros a la consulta
            insertMascota.setInt(1, idPropietario);
            insertMascota.setString(2, nombre);
            insertMascota.setString(3, tipo);
            insertMascota.setString(4, color);
            insertMascota.setString(5, raza);
            insertMascota.setDate(6, java.sql.Date.valueOf(nacimiento));
            insertMascota.setDouble(7, peso);
            insertMascota.setString(8, genero);
            insertMascota.setBinaryStream(9, fileContent);

            //ejecutando la consulta
            int nroRegistro = insertMascota.executeUpdate();
            System.out.println("Resultado de ejecucion: " + nroRegistro);
            if (nroRegistro == 1) {
                mensaje = "Se registro correctamente los datos de la mascota";
            } else {
                mensaje = "Error al realizar el insert";
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error al realizar el insert");
        }
        return mensaje;
    }
}
