<%@page import="com.dev.bean.CitaBean"%>
<%@page import="com.dev.clases.UsuarioRol"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    // Verificar sesión
    HttpSession sesion = request.getSession(false);
    
    if (sesion == null || sesion.getAttribute("usuarioRol") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    UsuarioRol usuarioRol = (UsuarioRol) sesion.getAttribute("usuarioRol");
    
    // Obtener parámetros
    String idCitaStr = request.getParameter("id");
    String nuevoEstado = request.getParameter("estado");
    
    System.out.println("[cambiarEstadoCita.jsp] ID: " + idCitaStr + ", Estado: " + nuevoEstado);
    
    if (idCitaStr != null && nuevoEstado != null) {
        try {
            int idCita = Integer.parseInt(idCitaStr);
            
            // Validar que el estado sea válido
            if (!"PROGRAMADA".equals(nuevoEstado) && 
                !"CONFIRMADA".equals(nuevoEstado) && 
                !"ATENDIDA".equals(nuevoEstado) && 
                !"CANCELADA".equals(nuevoEstado) &&
                !"PENDIENTE".equals(nuevoEstado)) {
                throw new IllegalArgumentException("Estado inválido: " + nuevoEstado);
            }
            
            CitaBean bean = new CitaBean();
            boolean resultado = bean.cambiarEstadoCita(idCita, nuevoEstado);
            bean.cerrarConexion();
            
            System.out.println("[cambiarEstadoCita.jsp] Resultado: " + resultado);
            
            if (resultado) {
                response.sendRedirect("gestionCitas.jsp?mensaje=Estado de cita actualizado correctamente&tab=lista");
            } else {
                response.sendRedirect("gestionCitas.jsp?error=No se pudo actualizar el estado de la cita&tab=lista");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("[cambiarEstadoCita.jsp] Error NumberFormat: " + e.getMessage());
            response.sendRedirect("gestionCitas.jsp?error=ID de cita invalido&tab=lista");
        } catch (Exception e) {
            System.err.println("[cambiarEstadoCita.jsp] Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("gestionCitas.jsp?error=Error: " + e.getMessage() + "&tab=lista");
        }
    } else {
        System.err.println("[cambiarEstadoCita.jsp] Faltan parametros");
        response.sendRedirect("gestionCitas.jsp?error=Faltan parametros&tab=lista");
    }
%>
