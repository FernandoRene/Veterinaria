/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 *
 * @author INCOS
 */
public class RolBean {
    // atributos

    private Connection connection;
    private PreparedStatement selectVeterinario;
    private PreparedStatement insertRol;
    private PreparedStatement insertAcceso;
    private VariablesConexion variable;

    //constructor    
    public RolBean() throws SQLException {
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

    //listar los roles en un select
    public String listaRolSelect() {
        StringBuilder query = new StringBuilder();
        StringBuilder salidaSelect = new StringBuilder();
        query.append(" select r.id_rol,r.nombre_rol ");
        query.append(" from rol r");
        query.append(" order by r.nombre_rol ");
        try {
            selectVeterinario = connection.prepareStatement(query.toString());
            ResultSet resultado = selectVeterinario.executeQuery();
            while (resultado.next()) {
                salidaSelect.append("<option value='");
                salidaSelect.append(resultado.getInt(1));
                salidaSelect.append("'>");
                salidaSelect.append(resultado.getString(2));
                salidaSelect.append("</option>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error de conexion");
        }
        return salidaSelect.toString();
    }
    
    public String registrarRolAcceso(HttpServletRequest request) {
        String mensaje = "";
        StringBuilder queryRol = new StringBuilder();
        StringBuilder queryAcceso = new StringBuilder();
        //consulta para registrar un nuevo rol
        queryRol.append(" insert into rol ");
        queryRol.append(" values(nextval('sec_rol'),?,?)");
        //consulta para añadir acceso por cada recurso seleccionado (falta)
        try {
            insertRol = connection.prepareStatement(queryRol.toString());
            //rescatando los valores de formulario
            String nom = request.getParameter("nombre");           
            //pasando los valores rescatados a los parametros de la consulta
            insertRol.setString(1, nom);
            insertRol.setString(2,"ACTIVO");            
            //ejecutando la consulta
            int nroRegistros = insertRol.executeUpdate();
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


}
