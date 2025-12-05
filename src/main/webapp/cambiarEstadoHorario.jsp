<%@page import="com.dev.bean.HorarioBean"%>
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
    String idHorarioStr = request.getParameter("id");
    String nuevoEstado = request.getParameter("estado");
    
    System.out.println("[cambiarEstadoHorario.jsp] ID: " + idHorarioStr + ", Estado: " + nuevoEstado);
    
    if (idHorarioStr != null && nuevoEstado != null) {
        try {
            int idHorario = Integer.parseInt(idHorarioStr);
            
            // Validar que el estado sea válido
            if (!"ACTIVO".equals(nuevoEstado) && !"INACTIVO".equals(nuevoEstado)) {
                throw new IllegalArgumentException("Estado inválido: " + nuevoEstado);
            }
            
            HorarioBean bean = new HorarioBean();
            boolean resultado = bean.cambiarEstadoHorario(idHorario, nuevoEstado);
            bean.cerrarConexion();
            
            System.out.println("[cambiarEstadoHorario.jsp] Resultado: " + resultado);
            
            if (resultado) {
                response.sendRedirect("gestionHorarios.jsp?mensaje=Estado actualizado correctamente&tab=lista");
            } else {
                response.sendRedirect("gestionHorarios.jsp?error=No se pudo actualizar el estado&tab=lista");
            }
            
        } catch (NumberFormatException e) {
            System.err.println("[cambiarEstadoHorario.jsp] Error NumberFormat: " + e.getMessage());
            response.sendRedirect("gestionHorarios.jsp?error=ID de horario invalido&tab=lista");
        } catch (Exception e) {
            System.err.println("[cambiarEstadoHorario.jsp] Error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("gestionHorarios.jsp?error=Error: " + e.getMessage() + "&tab=lista");
        }
    } else {
        System.err.println("[cambiarEstadoHorario.jsp] Faltan parametros");
        response.sendRedirect("gestionHorarios.jsp?error=Faltan parametros&tab=lista");
    }
%>
