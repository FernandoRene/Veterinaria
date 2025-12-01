/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.bean;

/**
 * La clase obtiene los recursos a los cuales puede acceder dependiendo del rol
 * que tiene el usuario
 *
 * @author INCOS
 */
import com.dev.clases.Recursos;
import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Logger;
import java.util.logging.Level;

public class RolRecursoBean {

    private Connection connection;
    private VariablesConexion variable;
    private PreparedStatement recursos;
    private PreparedStatement insertRol;
    private PreparedStatement insertAcceso;
    private PreparedStatement selectSecuencia;
    //constructor

    public RolRecursoBean() throws SQLException {
        variable = new VariablesConexion();
        variable.iniciarConexion();
        connection = variable.getConnection();
    }

    @PreDestroy
    public void cerrarConexion() {
        if (connection != null) {
            variable.cerrarConexion();
        }
    }

    //obtener la lista de recursos
    public List<Recursos> listaRecursos(String rol) {
        List<Recursos> lista = new ArrayList<>();
        Recursos obj;
        StringBuilder query = new StringBuilder();
        query.append(" select r.id_rec,r.url,r.texto, r.estado ");
        query.append(" from recursos r");
        query.append(" inner join acceso a on a.id_rec=r.id_rec ");
        query.append(" inner join rol ro on ro.id_rol=a.id_rol ");
        query.append(" where ro.nombre_rol=?");
        try {
            recursos = connection.prepareStatement(query.toString());
            recursos.setString(1, rol);
            ResultSet resultado = recursos.executeQuery();
            while (resultado.next()) {
                obj = new Recursos();
                obj.setIdRecurso(resultado.getInt(1));
                obj.setUrl(resultado.getString(2));
                obj.setNombreEnlace(resultado.getString(3));
                obj.setEstado(resultado.getString(4));
                lista.add(obj);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error de conexion");
        }

        return lista;
    }

    public String registrarRolAcceso(String rol, String[] accesos) {
        String mensaje = "";
        int idRol = 0, resAcceso;

        StringBuilder queryRol = new StringBuilder();
        StringBuilder queryAcceso = new StringBuilder();
        StringBuilder querySecuencia = new StringBuilder();
        //consulta para determinar el ultimo valor de la secuencia para rol
        querySecuencia.append(" select last_value from sec_rol ");
        System.out.println("Consulta secuencia: " + querySecuencia);

        //consulta para adicionar un nuevo rol
        queryRol.append(" insert into rol ");
        queryRol.append(" values(nextval('sec_rol'),?,?)");
        //consulta para adicionar acceso al rol creado
        queryAcceso.append(" insert into acceso ");
        queryAcceso.append(" values(nextval('sec_acc'), ?, ?)");
        try {
            connection.setAutoCommit(false);

            selectSecuencia = connection.prepareStatement(querySecuencia.toString());
            ResultSet resultado = selectSecuencia.executeQuery();
            if (resultado.next()) {
                idRol = resultado.getInt(1);
            }
            System.out.println("Nro de secuencia de rol: " + idRol);

            insertRol = connection.prepareStatement(queryRol.toString());
          
            insertRol.setString(1, rol);
            insertRol.setString(2, "ACTIVO");
            //ejecutando la consulta
            int nroRegistro = insertRol.executeUpdate();
            System.out.println("Rol registrado: " + nroRegistro);

            insertAcceso = connection.prepareStatement(queryAcceso.toString());
            for (String recurso : accesos) {
                insertAcceso.setInt(1, Integer.parseInt(recurso));
                insertAcceso.setInt(2, idRol + 1);
                resAcceso = insertAcceso.executeUpdate();
                System.out.println("Acceso registrado: " + resAcceso);
            }

            if (nroRegistro == 1) {
                mensaje = "Rol y Accesos definidos";
                System.out.println("");
            } else {
                mensaje = "Error al realizar el registro";
            }
            connection.commit();

        } catch (SQLException e) {
            Logger.getLogger(RolRecursoBean.class.getName()).log(Level.SEVERE, null, e);
            try {
                // rollbackeando
                connection.rollback();
            } catch (SQLException ex) {
                Logger.getLogger(RolRecursoBean.class.getName()).log(Level.SEVERE, null, ex);
            }

        }

        return mensaje;
    }

}
