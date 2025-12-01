///*
// * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
// * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Filter.java to edit this template
// */
//package com.dev.filtros;
//
//import com.dev.clases.UsuarioRol;
//import java.io.IOException;
//import jakarta.servlet.Filter;
//import jakarta.servlet.FilterChain;
//import jakarta.servlet.FilterConfig;
//import jakarta.servlet.RequestDispatcher;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.ServletRequest;
//import jakarta.servlet.ServletResponse;
//import jakarta.servlet.annotation.WebFilter;
//import jakarta.servlet.annotation.WebInitParam;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpSession;
//
///**
// *
// * @author meli
// */
//@WebFilter(filterName = "LoginFilter2", urlPatterns = {"/*"}, initParams = {
//    @WebInitParam(name = "loginActionURI", value = "/MaestriaMod9/loginServlet")})
//public class LoginFilter2 implements Filter {
//    
//    private String LOGIN_ACTION_URI;
//    
//    @Override
//    public void init(FilterConfig filterConfig) throws ServletException {
//        // recupernado parametros iniciales del Filtro
//        LOGIN_ACTION_URI = filterConfig.getInitParameter("loginActionURI");
//    }
//
//    @Override
//    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
//        
//        HttpServletRequest req = (HttpServletRequest) request;
//        HttpSession session = req.getSession();
//        String path = req.getRequestURI();
//        
//        System.out.println("PATH: " + path);
//        
//        // se va a excluir a los path de servicios rest
//        if (path.contains("/rest/")
//                || path.contains("/imagenes/")
//                || path.contains("/js/")
//                || path.contains("/css/")) {
//
//            chain.doFilter(request, response); // se deja pasar sin filtrar
//            return;
//        }
//        
//        UsuarioRol user = (UsuarioRol) session.getAttribute("usuarioRol");
//        
//        // verificando que NO está autentico
//        if (user == null && !LOGIN_ACTION_URI.equals(req.getRequestURI())){
//            RequestDispatcher rd = req.getRequestDispatcher("/login.jsp");
//            rd.forward(request, response);
//            return;
//        }
//        // si no esta 
//        chain.doFilter(request, response);
//    }
//
//    
//}
