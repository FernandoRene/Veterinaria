/*
 * Veterinario.java
 * Clase modelo para veterinarios
 */
package com.dev.clases;

import java.io.Serializable;

/**
 * Clase que representa un veterinario de la clínica
 * @author Fernando
 */
public class Veterinario implements Serializable {
    
    // Atributos
    private int idVeterinario;
    private String nombreVet;
    private String paternoVet;
    private String maternoVet;
    private String ciVet;
    private String matriculaProfesional;
    private String especialidad;
    private String telefono;
    private String email;
    private String direccion;
    private String fechaContratacion;
    private String estado;
    
    // Para respuestas REST (opcional)
    private String codigo;
    private String mensaje;
    
    // Constructor vacío
    public Veterinario() {
    }
    
    // Constructor con parámetros principales
    public Veterinario(String nombreVet, String paternoVet, String maternoVet, 
                       String ciVet, String matriculaProfesional, String especialidad) {
        this.nombreVet = nombreVet;
        this.paternoVet = paternoVet;
        this.maternoVet = maternoVet;
        this.ciVet = ciVet;
        this.matriculaProfesional = matriculaProfesional;
        this.especialidad = especialidad;
        this.estado = "ACTIVO";
    }
    
    // Getters y Setters
    
    public int getIdVeterinario() {
        return idVeterinario;
    }
    
    public void setIdVeterinario(int idVeterinario) {
        this.idVeterinario = idVeterinario;
    }
    
    public String getNombreVet() {
        return nombreVet;
    }
    
    public void setNombreVet(String nombreVet) {
        this.nombreVet = nombreVet;
    }
    
    public String getPaternoVet() {
        return paternoVet;
    }
    
    public void setPaternoVet(String paternoVet) {
        this.paternoVet = paternoVet;
    }
    
    public String getMaternoVet() {
        return maternoVet;
    }
    
    public void setMaternoVet(String maternoVet) {
        this.maternoVet = maternoVet;
    }
    
    public String getCiVet() {
        return ciVet;
    }
    
    public void setCiVet(String ciVet) {
        this.ciVet = ciVet;
    }
    
    public String getMatriculaProfesional() {
        return matriculaProfesional;
    }
    
    public void setMatriculaProfesional(String matriculaProfesional) {
        this.matriculaProfesional = matriculaProfesional;
    }
    
    public String getEspecialidad() {
        return especialidad;
    }
    
    public void setEspecialidad(String especialidad) {
        this.especialidad = especialidad;
    }
    
    public String getTelefono() {
        return telefono;
    }
    
    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getDireccion() {
        return direccion;
    }
    
    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }
    
    public String getFechaContratacion() {
        return fechaContratacion;
    }
    
    public void setFechaContratacion(String fechaContratacion) {
        this.fechaContratacion = fechaContratacion;
    }
    
    public String getEstado() {
        return estado;
    }
    
    public void setEstado(String estado) {
        this.estado = estado;
    }
    
    public String getCodigo() {
        return codigo;
    }
    
    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }
    
    public String getMensaje() {
        return mensaje;
    }
    
    public void setMensaje(String mensaje) {
        this.mensaje = mensaje;
    }
    
    // Métodos auxiliares
    
    /**
     * Obtiene el nombre completo del veterinario
     * @return Nombre completo
     */
    public String getNombreCompleto() {
        return nombreVet + " " + paternoVet + 
               (maternoVet != null ? " " + maternoVet : "");
    }
    
    /**
     * Verifica si el veterinario está activo
     * @return true si está activo, false si no
     */
    public boolean isActivo() {
        return "ACTIVO".equals(estado);
    }
    
    @Override
    public String toString() {
        return "Veterinario{" +
                "idVeterinario=" + idVeterinario +
                ", nombreCompleto='" + getNombreCompleto() + '\'' +
                ", ci='" + ciVet + '\'' +
                ", matricula='" + matriculaProfesional + '\'' +
                ", especialidad='" + especialidad + '\'' +
                ", estado='" + estado + '\'' +
                '}';
    }
}