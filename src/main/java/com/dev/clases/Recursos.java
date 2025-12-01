/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.clases;

import java.io.Serializable;

/**
 *
 * @author INCOS
 */
public class Recursos implements Serializable{
    //atributos
    private int idRecurso;
    private String url;
    private String nombreEnlace;
    private String estado;
    // constructor

    public Recursos() {
        this.url="";
        this.nombreEnlace="";
        this.estado="";
    }
    //getter y setter

    public int getIdRecurso() {
        return idRecurso;
    }

    public void setIdRecurso(int idRecurso) {
        this.idRecurso = idRecurso;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getNombreEnlace() {
        return nombreEnlace;
    }

    public void setNombreEnlace(String nombreEnlace) {
        this.nombreEnlace = nombreEnlace;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    
    
}
