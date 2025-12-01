/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.bean;

import com.dev.clases.EncriptadoSHA256;
import com.dev.clases.UsuarioRol;
import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import java.sql.ResultSet;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.logging.Logger;
import java.util.logging.Level;

/**
 *
 * @author INCOS
 */
public class UsuarioBean {

    private VariablesConexion variable;
    private Connection connection;
    private PreparedStatement selectUsuario;
    private PreparedStatement insertUsuario;
    private PreparedStatement insertPassword;
    private PreparedStatement tiempoPassword;

    //constructor
    public UsuarioBean() throws SQLException {
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

    //metodos
    public String listadoUsuario() {
        StringBuilder salida = new StringBuilder();
        StringBuilder query = new StringBuilder();
        //consulta
        query.append(" select u.nombre_usu,u.paterno_usu, u.materno_usu, u.direccion_usu,u.telefono_usu,u.nro_cedula, r.nombre_rol ");
        query.append(" from usuario u ");
        query.append(" inner join rol r on r.id_rol=u.id_rol ");
        query.append(" where u.estado_usu='ACTIVO' ");
        query.append(" order by u.paterno_usu ");
        
        try {

            selectUsuario = connection.prepareStatement(query.toString());
            //ejecucion de la consulta sql
            ResultSet resultado = selectUsuario.executeQuery();
            //como el objeto resultado devuelve n registros iteramos con un while
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
                salida.append("</tr>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return salida.toString();
    }

    /**
     * el metodo registrara a un usuario y guardara su contraseña con la fecha
     * actual y calculara la fecha final despues de 6 mese, estos datos se
     * guardan en la tabla password
     *
     * @param request
     * @return
     */
    public String registrarUsuario(HttpServletRequest request) {
        String mensaje, codigo, pass, password;
        mensaje = codigo = pass = password = "";
        int idUsuario = 0;
        EncriptadoSHA256 obj = new EncriptadoSHA256();
        StringBuilder queryUsuario = new StringBuilder();
        StringBuilder querySecuencia = new StringBuilder();
        StringBuilder queryPassword = new StringBuilder();

        //me permite ver el ultimo valor asignado a la secuencia
        querySecuencia.append(" select last_value from sec_usu ");
        System.out.println("Consulta secuencia: " + querySecuencia);

        queryUsuario.append(" insert into usuario ");
        queryUsuario.append(" values(nextval('sec_usu'),?,?,?,?,?,?,?,?,?) ");

        System.out.println("Consulta insert usuario: " + queryUsuario);
        //insert password
        queryPassword.append(" insert into password ");
        queryPassword.append(" values(nextval('sec_pas'),?,?,?,?,?,?)");
        System.out.println("Consulta insert password: " + queryPassword);

        try {
            //empezando el bloque transaccional
            connection.setAutoCommit(false);
            //ejecutando la consulta de la secuencia, para obtener el id de usuario
            PreparedStatement consulta = connection.prepareStatement(querySecuencia.toString());
            ResultSet res = consulta.executeQuery();
            if (res.next()) {
                idUsuario = res.getInt(1);
            }
            System.out.println("Nro de secuencia de usuario: " + idUsuario);

            insertUsuario = connection.prepareStatement(queryUsuario.toString());
            //obteniendo los datos del formulario
            String nom = request.getParameter("nombre");
            String pat = request.getParameter("paterno");
            String mat = request.getParameter("materno");
            String dir = request.getParameter("direccion");
            String tel = request.getParameter("telefono");
            String nroCed = request.getParameter("nroCedula");
            int codRol = Integer.parseInt(request.getParameter("rol"));
            //generando el codigo del usuario
            codigo = codigo + nom.toLowerCase().charAt(0) + pat.toLowerCase() + "." + mat.toLowerCase().charAt(0);
            // generando el password con la siguiente secuencia,dos caracter del nombre seguido de los 2 primeros numeros de ci
            //2 letras del apellido paterno seguido de los 2 siguientes digitos del ci, 2 caracteress del apellido paterno
            //seguido de los 2 siguientes digitos del ci, añadir a la tabla de password
            pass = pass + nom.toUpperCase().substring(0, 2) + nroCed.substring(0, 2) + pat.toLowerCase().substring(0, 2) + nroCed.substring(2, 4)
                    + mat.toUpperCase().substring(0, 2) + nroCed.substring(4, 6);
            //encriptando el password
            System.out.println("Password generado: " + pass);
            password = obj.sha256(pass);
            //pasando los datos a los parametros respectivos de la consulta sql
            insertUsuario.setInt(1, codRol);
            insertUsuario.setString(2, nom);
            insertUsuario.setString(3, pat);
            insertUsuario.setString(4, mat);
            insertUsuario.setString(5, dir);
            insertUsuario.setString(6, tel);
            insertUsuario.setString(7, nroCed);
            insertUsuario.setString(8, codigo);
            //cuando se registra un nuevo usuario se define su estado en ACTIVO
            insertUsuario.setString(9, "ACTIVO");
            //ejecutando la consulta
            int nroRegistro = insertUsuario.executeUpdate();
            System.out.println("Usuario registrado");
            //pasando los parametros para registrar password
            insertPassword = connection.prepareStatement(queryPassword.toString());
            //se adiciona 1 al valor ultimo asignado a la secuencia.
            insertPassword.setInt(1, idUsuario + 1);
            insertPassword.setString(2, password);
            //fecha actual del sistema
            insertPassword.setDate(3, java.sql.Date.valueOf(LocalDate.now()));
            //sumando a la fecha actual 6 meses para determinar los 6 meses de validez del password
            LocalDate fVencimiento = LocalDate.now().plusMonths(6);
            insertPassword.setDate(4, java.sql.Date.valueOf(fVencimiento));
            insertPassword.setInt(5, 0);
            //el password se creara con el estado ACTIVO
            insertPassword.setString(6, "ACTIVO");
            //ejecutando la consulta de password
            int resultado = insertPassword.executeUpdate();
            System.out.println("Password registrado");

            if (nroRegistro == 1 && resultado == 1) {
                mensaje = "Datos de usuario registrado";
            } else {
                mensaje = "Error de registro";
            }
            // comiteando transaccion
            connection.commit();

        } catch (SQLException e) {
            Logger.getLogger(UsuarioBean.class.getName()).log(Level.SEVERE, null, e);
            try {
                // rollbackeando
                connection.rollback();
            } catch (SQLException ex) {
                Logger.getLogger(UsuarioBean.class.getName()).log(Level.SEVERE, null, ex);
            }

        }
        return mensaje;
    }

    public UsuarioRol verificarValidez(HttpServletRequest request) {

        String pass = "";
        UsuarioRol usuario = new UsuarioRol();
        EncriptadoSHA256 obj = new EncriptadoSHA256();
        LocalDate hoy = LocalDate.now();
        StringBuilder queryValidez = new StringBuilder();
        queryValidez.append(" select u.nombre_usu||' '||u.paterno_usu as nombre, p.f_vencimiento, r.nombre_rol ");
        queryValidez.append(" from usuario u ");
        queryValidez.append(" inner join password p on p.id_usuario=u.id_usuario ");
        queryValidez.append(" inner join rol r on r.id_rol=u.id_rol ");
        queryValidez.append(" where u.estado_usu='ACTIVO' and p.estado_pass='ACTIVO' and u.codigo=? and p.pass=?");
        try {
            tiempoPassword = connection.prepareStatement(queryValidez.toString());
            //rescatando los parametros del formulario
            String codigo = request.getParameter("codigo");
            String password = request.getParameter("password");

            //pasando los parametros a la consulta
            tiempoPassword.setString(1, codigo);
            pass = obj.sha256(password);
            tiempoPassword.setString(2, pass);
            ResultSet resultado = tiempoPassword.executeQuery();
            if (resultado.next()) {
                System.out.println("Consulta de validez de password ejecutada");
                java.sql.Date fv = resultado.getDate(2);
                LocalDate fVencimiento = fv.toLocalDate();
                long tiempo = ChronoUnit.DAYS.between(fVencimiento, hoy);             
                    usuario.setNombreCompleto(resultado.getString(1));
                    usuario.setCodigo(codigo);                   
                    usuario.setRol(resultado.getString(3));
                    usuario.setVigenciaDias((int) tiempo);
              
                //seteando los datos del usuario
            } else {
                usuario = null;
            }

        } catch (SQLException e) {
            e.printStackTrace();

        }
        return usuario;
    }

}
