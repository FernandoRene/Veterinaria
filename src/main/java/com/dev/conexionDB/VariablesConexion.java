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
    public static String URL_BBDD="jdbc:postgresql://localhost:5432/modulo9_proyecto?charSet=UTF-8";
    public static String DRIVER_BBDD="org.postgresql.Driver";
    public static String USER_BBDD="postgres";
    public static String PSW_BBDD="INvoker2025.";
    //atributo permite obtener la conexion con la base de datos
    private Connection connection;
    
    // Constructor - inicializa la conexión automáticamente
    public VariablesConexion() {
        System.out.println("🔵 VariablesConexion - Constructor llamado");
        iniciarConexion();
    }
    
    //metodos
    public void cerrarConexion(){
        if(connection!=null){
            try {
                connection.close();
                System.out.println("✅ Conexión cerrada");
            } catch (SQLException e) {
                System.err.println("❌ Error al cerrar conexión: " + e.getMessage());
                e.printStackTrace();
            }
        }
    }
    
    public void iniciarConexion(){
        System.out.println("🔵 Iniciando conexión...");
        System.out.println("   URL: " + URL_BBDD);
        System.out.println("   Usuario: " + USER_BBDD);
        
        try {
            System.out.println("🔵 Cargando driver: " + DRIVER_BBDD);
            Class.forName(DRIVER_BBDD);
            System.out.println("✅ Driver cargado");
            
            System.out.println("🔵 Conectando a BD...");
            connection=DriverManager.getConnection(URL_BBDD,USER_BBDD,PSW_BBDD);
            
            if (connection != null) {
                System.out.println("✅✅✅ CONEXIÓN EXITOSA ✅✅✅");
            } else {
                System.err.println("❌ Connection es null");
            }
            
        } catch (SQLException e) {
            System.err.println("❌❌❌ ERROR DE CONEXIÓN SQL ❌❌❌");
            System.err.println("URL: " + URL_BBDD);
            System.err.println("Usuario: " + USER_BBDD);
            System.err.println("Mensaje: " + e.getMessage());
            System.err.println("SQLState: " + e.getSQLState());
            e.printStackTrace();
        }catch(ClassNotFoundException ex){
            System.err.println("❌❌❌ DRIVER NO ENCONTRADO ❌❌❌");
            System.err.println("Driver: " + DRIVER_BBDD);
            System.err.println("Agrega postgresql.jar a las librerías del proyecto");
            ex.printStackTrace();
        }
    }
    
    //get y set
    public Connection getConnection() {
        return connection;
    }
    
    // Alias para compatibilidad (algunos beans pueden usar este nombre)
    public Connection getConexion() {
        return connection;
    }

    public void setConnection(Connection connection) {
        this.connection = connection;
    }
}