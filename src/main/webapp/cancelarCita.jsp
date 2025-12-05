<%@page import="com.dev.bean.CitaBean"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    if (session.getAttribute("codigo") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String codigoUsuario = (String) session.getAttribute("codigo");
    String idParam = request.getParameter("id");
    String motivoParam = request.getParameter("motivo");
    
    if (idParam == null || motivoParam == null || motivoParam.trim().isEmpty()) {
        response.sendRedirect("gestionCitas.jsp?error=Debe proporcionar un motivo de cancelacion");
        return;
    }
    
    try {
        int idCita = Integer.parseInt(idParam);
        String motivo = motivoParam.trim();
        
        CitaBean bean = new CitaBean();
        boolean resultado = bean.cancelarCita(idCita, motivo, codigoUsuario);
        bean.cerrarConexion();
        
        if (resultado) {
            response.sendRedirect("gestionCitas.jsp?mensaje=Cita cancelada exitosamente&tab=lista");
        } else {
            response.sendRedirect("gestionCitas.jsp?error=Error al cancelar cita&tab=lista");
        }
        
    } catch (NumberFormatException e) {
        response.sendRedirect("gestionCitas.jsp?error=ID invalido&tab=lista");
    } catch (Exception e) {
        response.sendRedirect("gestionCitas.jsp?error=Error: " + e.getMessage() + "&tab=lista");
    }
%>
