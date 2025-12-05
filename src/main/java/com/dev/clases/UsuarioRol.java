/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.clases;

import java.io.Serializable;

/**
 *
 * @author meli
 */
public class UsuarioRol implements Serializable{
    private String nombreCompleto;
    private String codigo;  
    private String rol;
    private int  vigenciaDias;
    
    //constructor

    public UsuarioRol() {
        this.nombreCompleto = "";
        this.codigo = "";     
        this.rol = "";
        this.vigenciaDias = 0;
    }

 
   
    //getter y setter

    public String getNombreCompleto() {
        return nombreCompleto;
    }
    
    public void setNombreCompleto(String nombreCompleto) {
        this.nombreCompleto = nombreCompleto;
    }
    
    
    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

 

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public int getVigenciaDias() {
        return vigenciaDias;
    }

    public void setVigenciaDias(int vigenciaDias) {
        this.vigenciaDias = vigenciaDias;
    }
        
}
