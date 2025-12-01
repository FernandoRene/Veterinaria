/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.serviciosRest;

import com.dev.bean.PropietarioBean;
import com.dev.clases.Propietario;
import jakarta.annotation.PostConstruct;
import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.ext.ParamConverter;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author meli
 */
@Path("/propietario")
public class PropietarioServices {
    
    private PropietarioBean propietarioBean;
    
    @PostConstruct
    public void inicio(){
        try {
            propietarioBean = new PropietarioBean();
        } catch (SQLException ex) {
            Logger.getLogger(PropietarioServices.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
      
    @GET
    @Path("/listar")
    @Produces(MediaType.APPLICATION_JSON)
    public List<Propietario> listar(){
        List<Propietario> lista = propietarioBean.listadoPropietariosRest();
        
        return lista;
    }
    
    @GET
    @Path("/buscar/{idPropietario}")
    @Produces(MediaType.APPLICATION_JSON)
    public Propietario buscar(@PathParam("idPropietario") Integer idPropietario){
        Propietario propietario = propietarioBean.buscar(idPropietario);
        
        return propietario;
    }
    
    @POST
    @Path("/registrar")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)    
    public Propietario registrarPropietario(Propietario propietario){
        
        Propietario propietarioReturn = propietarioBean.registrarPropietarioRest(propietario);
        
        return propietarioReturn;
    }
    
    @POST
    @Path("/modificar")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)    
    public Propietario modificarPropietario(Propietario propietario){
        
        Propietario propietarioOut = propietarioBean.modificarPropietarioRest(propietario);
        return propietarioOut;
    }
    
    
    
    
}
