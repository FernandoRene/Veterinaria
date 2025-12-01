/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.clases;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 *
 * @author INCOS
 */
public class ManejoFechas {

    public Date convertirStringDate(String fecha) {
        Date fechaDate = null;
        try {
            SimpleDateFormat formato = new SimpleDateFormat("yyyy-MM-dd");
            fechaDate = formato.parse(fecha);
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("error de casteo");
        }
        return fechaDate;
    }

}
