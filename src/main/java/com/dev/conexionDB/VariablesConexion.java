/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.conexionDB;

//import jakarta.jms.Connection;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.SQLException;

/**
 *
 * @author INCOS
 */
public class VariablesConexion {
    public static String URL_BBDD="jdbc:postgresql://localhost:5432/modulo9_proyecto";
    public static String DRIVER_BBDD="org.postgresql.Driver";
    public static String USER_BBDD="postgres";
    public static String PSW_BBDD="mel150580";
    //atributo permite obtener la conexion con la base de datos
    private Connection connection;
    
    //metodos
    public void cerrarConexion(){
        if(connection!=null){
            try {
                connection.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    public void iniciarConexion(){
        try {
            Class.forName(DRIVER_BBDD);
            connection=DriverManager.getConnection(URL_BBDD,USER_BBDD,PSW_BBDD);
        } catch (SQLException e) {
            e.printStackTrace();
        }catch(ClassNotFoundException ex){
            ex.printStackTrace();
        }
    }
    //get y set

    public Connection getConnection() {
        return connection;
    }

    public void setConnection(Connection connection) {
        this.connection = connection;
    }
    
    
}
