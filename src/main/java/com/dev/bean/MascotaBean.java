/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.dev.bean;

import com.dev.conexionDB.VariablesConexion;
import jakarta.annotation.PreDestroy;
import jakarta.servlet.http.HttpServletRequest;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.Map;


/**
 *
 * @author INCOS
 */
public class MascotaBean implements AutoCloseable {
    //atributos

    private Connection connection;
    private PreparedStatement selectMascota;
    private PreparedStatement buscarMascotaTipo;
    private PreparedStatement buscarMascotaPropietario;
    private PreparedStatement insertMascota;
    private VariablesConexion variable;
    //constructor

    public MascotaBean() throws SQLException {
        variable = new VariablesConexion();
        //estableciendo el inicio de conexion con la BD
        variable.iniciarConexion();
        //obteniendo la conexion
        connection = variable.getConnection();
    }
    //metodos

    @PreDestroy
    public void cerrarConexion() {
        //llamando al metodo para cerrar la conexion
        variable.cerrarConexion();
    }

    public String listaMascotas() {
        StringBuilder salida = new StringBuilder();
        StringBuilder query = new StringBuilder();

        // CONSULTA: NO incluyas la columna 'foto' directamente si es muy grande
        query.append("SELECT m.id_mascota, m.nombre_mascota, m.tipo, m.raza, ");
        query.append("m.color, m.genero, m.f_nacimiento, m.peso, ");
        query.append("p.nombre_prop || ' ' || p.paterno_prop AS propietario, ");
        query.append("CASE WHEN m.foto IS NULL THEN 0 ELSE 1 END AS tiene_foto ");
        query.append("FROM mascota m ");
        query.append("INNER JOIN propietario p ON p.id_propietario = m.id_propietario ");
        query.append("ORDER BY m.id_mascota");

        try {
            selectMascota = connection.prepareStatement(query.toString());
            ResultSet resultado = selectMascota.executeQuery();

            while (resultado.next()) {
                salida.append("<tr>");

                int idMascota = resultado.getInt("id_mascota");
                String nombre = resultado.getString("nombre_mascota");
                String tipo = resultado.getString("tipo");
                String raza = resultado.getString("raza");
                String color = resultado.getString("color");
                String genero = resultado.getString("genero");
                java.sql.Date fechaNac = resultado.getDate("f_nacimiento");
                double peso = resultado.getDouble("peso");
                String propietario = resultado.getString("propietario");
                int tieneFoto = resultado.getInt("tiene_foto");

                // 1. ID
                salida.append("<td>").append(idMascota).append("</td>");

                // 2. IMAGEN - Solo indicador, no cargar el BLOB
                salida.append("<td style='text-align: center;'>");
                if (tieneFoto == 1) {
                    // Mostrar botón para ver imagen
                    salida.append("<div onclick=\"verFoto('").append(idMascota).append("')\" ");
                    salida.append("style='cursor:pointer;width:40px;height:40px;border-radius:50%;");
                    salida.append("background:#667eea;color:white;display:flex;align-items:center;");
                    salida.append("justify-content:center;font-size:16px;margin:0 auto;' ");
                    salida.append("title='Click para ver foto'>");
                    salida.append("📷");
                    salida.append("</div>");
                    salida.append("<small style='font-size:10px;color:#666;'>Ver foto</small>");
                } else {
                    // Icono según tipo de mascota
                    String icono = getIconoPorTipo(tipo);
                    salida.append("<div style='width:40px;height:40px;border-radius:50%;");
                    salida.append("background:#f0f0f0;display:flex;align-items:center;");
                    salida.append("justify-content:center;font-size:20px;margin:0 auto;'>");
                    salida.append(icono);
                    salida.append("</div>");
                    salida.append("<small style='font-size:10px;color:#999;'>Sin foto</small>");
                }
                salida.append("</td>");

                // 3. Nombre
                salida.append("<td><strong>").append(nombre).append("</strong></td>");

                // 4. Raza
                salida.append("<td>").append(raza).append("</td>");

                // 5. Especie
                salida.append("<td>").append(tipo).append("</td>");

                // 6. Color
                salida.append("<td>");
                if (color != null && !color.trim().isEmpty()) {
                    salida.append(color);
                } else {
                    salida.append("<span style='color:#999;'>—</span>");
                }
                salida.append("</td>");

                // 7. Sexo
                salida.append("<td>");
                salida.append("<span style='display:inline-block;padding:4px 8px;border-radius:12px;");
                salida.append("font-size:12px;font-weight:600;");
                if ("Macho".equals(genero)) {
                    salida.append("background:#d1ecf1;color:#0c5460;'>♂ ");
                } else {
                    salida.append("background:#f8d7da;color:#721c24;'>♀ ");
                }
                salida.append(genero).append("</span>");
                salida.append("</td>");

                // 8. Fecha de nacimiento
                salida.append("<td>");
                if (fechaNac != null) {
                    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                    salida.append(sdf.format(fechaNac));
                } else {
                    salida.append("<span style='color:#999;'>—</span>");
                }
                salida.append("</td>");

                // 9. Peso
                salida.append("<td>");
                if (peso > 0) {
                    salida.append(String.format("%.1f", peso).replace(".", ",")).append(" kg");
                } else {
                    salida.append("<span style='color:#999;'>—</span>");
                }
                salida.append("</td>");

                // 10. Propietario
                salida.append("<td>").append(propietario).append("</td>");

                // 11. Acciones
                salida.append("<td style='white-space: nowrap;'>");
                salida.append("<a href='editarMascota.jsp?id=").append(idMascota)
                      .append("' style='padding:5px 10px;background:#17a2b8;color:white;")
                      .append("border-radius:3px;text-decoration:none;margin-right:5px;'>")
                      .append("✏️ Editar</a>");
                salida.append("<a href='eliminarMascota.jsp?id=").append(idMascota)
                      .append("' style='padding:5px 10px;background:#dc3545;color:white;")
                      .append("border-radius:3px;text-decoration:none;' ")
                      .append("onclick='return confirm(\"¿Eliminar a ").append(nombre).append("?\");'>")
                      .append("🗑️ Eliminar</a>");
                salida.append("</td>");

                salida.append("</tr>");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            salida.append("<tr><td colspan='11' style='color:red;text-align:center;padding:20px;'>")
                  .append("Error al cargar datos: ").append(e.getMessage())
                  .append("</td></tr>");
        }

        return salida.toString();
    }
    
    // Método para obtener solo la foto (si se necesita)
    public byte[] getFotoMascota(int idMascota) {
        byte[] fotoBytes = null;
        String query = "SELECT foto FROM mascota WHERE id_mascota = ?";

        try {
            PreparedStatement pstmt = connection.prepareStatement(query);
            pstmt.setInt(1, idMascota);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                // Para PostgreSQL con tipo bytea
                fotoBytes = rs.getBytes("foto");
            }

            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return fotoBytes;
    }

    // Método auxiliar para obtener icono según tipo
    private String getIconoPorTipo(String tipo) {
        if (tipo == null) return "🐕";

        switch (tipo.toLowerCase()) {
            case "perro": return "🐕";
            case "gato": return "🐈";
            case "ave": return "🐦";
            case "pájaro": return "🐦";
            case "conejo": return "🐇";
            case "hamster": return "🐹";
            case "roedor": return "🐭";
            case "pez": return "🐠";
            case "tortuga": return "🐢";
            default: return "🐕";
        }
    }

    // Método auxiliar para colores
    private String getColorHex(String colorName) {
        if (colorName == null) return "#CCCCCC";

        Map<String, String> colores = new HashMap<>();
        colores.put("blanco", "#FFFFFF");
        colores.put("negro", "#000000");
        colores.put("café", "#8B4513");
        colores.put("cafe", "#8B4513");
        colores.put("marrón", "#A52A2A");
        colores.put("marrón", "#A52A2A");
        colores.put("gris", "#808080");
        colores.put("dorado", "#FFD700");
        colores.put("atigrado", "#654321");
        colores.put("naranja", "#FFA500");
        colores.put("blanco", "#FFFFFF");
        colores.put("cafe claro", "#D2B48C");
        colores.put("café claro", "#D2B48C");

        return colores.getOrDefault(colorName.toLowerCase(), "#CCCCCC");
    }
    
    // Método para obtener la foto de una mascota

    public String buscarMascota(HttpServletRequest request) {
        StringBuilder query = new StringBuilder();
        StringBuilder salida = new StringBuilder();
        query.append(" select m.nombre_mascota,m.tipo,m.raza,m.color,m.peso,p.nombre_prop||' '||p.paterno_prop ");
        query.append(" from mascota m ");
        query.append(" inner join propietario p on p.id_propietario=m.id_propietario ");
        query.append(" where m.tipo=? ");

        try {
            buscarMascotaTipo = connection.prepareStatement(query.toString());
            String tipo = request.getParameter("listaTipo");
            buscarMascotaTipo.setString(1, tipo);
            System.out.println("consulta:" + query);
            ResultSet resultado = buscarMascotaTipo.executeQuery();
            //la ejecucion de la consuta devueve varios registros
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>");
                salida.append(resultado.getString(1));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(2));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(3));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(4));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(5));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(6));
                salida.append("</td>");
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en la ejecucion de la consulta");
        }
        return salida.toString();
    }
  public String buscarMascotaPropietario(String idPropietario) {
        StringBuilder query = new StringBuilder();
        StringBuilder salida = new StringBuilder();
        query.append(" select m.nombre_mascota,m.tipo,m.raza,m.color,m.peso,m.f_nacimiento,p.nombre_prop||' '||p.paterno_prop as propietario ");
        query.append(" from mascota m ");
        query.append(" inner join propietario p on p.id_propietario=m.id_propietario ");
        query.append(" where m.id_propietario=? ");

        try {
            buscarMascotaPropietario = connection.prepareStatement(query.toString());            
            buscarMascotaPropietario.setInt(1, Integer.parseInt(idPropietario));
            System.out.println("consulta:" + query);
            ResultSet resultado = buscarMascotaPropietario.executeQuery();
            //la ejecucion de la consuta devueve varios registros
           
            while (resultado.next()) {
                salida.append("<tr>");
                salida.append("<td>");
                salida.append(resultado.getString(1));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(2));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(3));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(4));
                salida.append("</td>");
                salida.append("<td>");
                salida.append(resultado.getString(5));
                salida.append("</td>"); 
                 salida.append("<td>");
                salida.append(resultado.getDate(6));
                salida.append("</td>"); 
                  salida.append("<td>");
                salida.append(resultado.getString(7));
                salida.append("</td>"); 
                salida.append("</tr>");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("Error en la ejecucion de la consulta");
        }
        return salida.toString();
    }

    public String registrarMascota(HttpServletRequest request, InputStream fileContent) {
        String mensaje = "";

        try {
            // DEBUG: Imprimir todos los parámetros recibidos
            System.out.println("=== DEBUG: Parámetros recibidos ===");
            System.out.println("idPropietario: " + request.getParameter("idPropietario"));
            System.out.println("nombreM: " + request.getParameter("nombreM"));
            System.out.println("tipoM: " + request.getParameter("tipoM"));
            System.out.println("razaM: " + request.getParameter("razaM"));
            System.out.println("colorM: " + request.getParameter("colorM"));
            System.out.println("genero: " + request.getParameter("genero"));
            System.out.println("fMascota: " + request.getParameter("fMascota"));
            System.out.println("pesoM: " + request.getParameter("pesoM"));
            System.out.println("fileContent: " + (fileContent != null ? "Presente" : "Nulo"));

            // Crear ByteArrayOutputStream para almacenar la imagen si existe
            ByteArrayOutputStream baos = null;
            byte[] fotoBytes = null;

            if (fileContent != null) {
                baos = new ByteArrayOutputStream();
                byte[] buffer = new byte[8192];
                long totalBytes = 0;
                int bytesRead;

                while ((bytesRead = fileContent.read(buffer)) != -1) {
                    baos.write(buffer, 0, bytesRead);
                    totalBytes += bytesRead;

                    // Limitar a 2MB
                    if (totalBytes > 2 * 1024 * 1024) {
                        mensaje = "❌ La imagen es demasiado grande (máx. 2MB)";
                        return mensaje;
                    }
                }

                fotoBytes = baos.toByteArray();
                System.out.println("Tamaño de imagen: " + fotoBytes.length + " bytes");
            }

            // Continuar con la inserción normal...
            StringBuilder query = new StringBuilder();
            query.append("INSERT INTO mascota(id_mascota, id_propietario, nombre_mascota, tipo, ");
            query.append("color, raza, f_nacimiento, peso, genero, foto) ");
            query.append("VALUES (nextval('sec_mas'), ?, ?, ?, ?, ?, ?, ?, ?, ?)");

            System.out.println("Consulta SQL: " + query.toString());

            insertMascota = connection.prepareStatement(query.toString());

            // Extraer y asignar parámetros
            int paramIndex = 1;

            // 1. id_propietario
            String idPropStr = request.getParameter("idPropietario");
            if (idPropStr != null && !idPropStr.trim().isEmpty()) {
                insertMascota.setInt(paramIndex++, Integer.parseInt(idPropStr));
            } else {
                mensaje = "❌ Error: ID de propietario requerido";
                return mensaje;
            }

            // 2. nombre_mascota
            String nombre = request.getParameter("nombreM");
            if (nombre != null && !nombre.trim().isEmpty()) {
                insertMascota.setString(paramIndex++, nombre.trim());
            } else {
                mensaje = "❌ Error: Nombre de mascota requerido";
                return mensaje;
            }

            // 3. tipo (especie)
            String tipo = request.getParameter("tipoM");
            if (tipo != null && !tipo.trim().isEmpty()) {
                insertMascota.setString(paramIndex++, tipo.trim());
            } else {
                mensaje = "❌ Error: Tipo de mascota requerido";
                return mensaje;
            }

            // 4. color
            String color = request.getParameter("colorM");
            if (color != null && !color.trim().isEmpty()) {
                insertMascota.setString(paramIndex++, color.trim());
            } else {
                insertMascota.setNull(paramIndex++, java.sql.Types.VARCHAR);
            }

            // 5. raza
            String raza = request.getParameter("razaM");
            if (raza != null && !raza.trim().isEmpty()) {
                insertMascota.setString(paramIndex++, raza.trim());
            } else {
                mensaje = "❌ Error: Raza de mascota requerida";
                return mensaje;
            }

            // 6. f_nacimiento (fecha)
            String fechaStr = request.getParameter("fMascota");
            if (fechaStr != null && !fechaStr.trim().isEmpty()) {
                try {
                    insertMascota.setDate(paramIndex++, java.sql.Date.valueOf(fechaStr));
                } catch (IllegalArgumentException e) {
                    System.out.println("Error parseando fecha: " + e.getMessage());
                    insertMascota.setNull(paramIndex++, java.sql.Types.DATE);
                }
            } else {
                insertMascota.setNull(paramIndex++, java.sql.Types.DATE);
            }

            // 7. peso
            String pesoStr = request.getParameter("pesoM");
            if (pesoStr != null && !pesoStr.trim().isEmpty()) {
                try {
                    insertMascota.setDouble(paramIndex++, Double.parseDouble(pesoStr));
                } catch (NumberFormatException e) {
                    System.out.println("Error parseando peso: " + e.getMessage());
                    insertMascota.setNull(paramIndex++, java.sql.Types.DECIMAL);
                }
            } else {
                insertMascota.setNull(paramIndex++, java.sql.Types.DECIMAL);
            }

            // 8. genero (sexo)
            String genero = request.getParameter("genero");
            if (genero != null && !genero.trim().isEmpty()) {
                insertMascota.setString(paramIndex++, genero.trim());
            } else {
                mensaje = "❌ Error: Género de mascota requerido";
                return mensaje;
            }

            // 9. foto
            if (fotoBytes != null && fotoBytes.length > 0) {
                ByteArrayInputStream bais = new ByteArrayInputStream(fotoBytes);
                insertMascota.setBinaryStream(paramIndex, bais, fotoBytes.length);
            } else {
                insertMascota.setNull(paramIndex, java.sql.Types.BLOB);
            }

            System.out.println("Ejecutando inserción con " + (paramIndex - 1) + " parámetros...");

            // Ejecutar inserción
            int filasAfectadas = insertMascota.executeUpdate();
            System.out.println("Filas afectadas: " + filasAfectadas);

            if (filasAfectadas == 1) {
                mensaje = "✅ Mascota '" + nombre + "' registrada exitosamente";
            } else {
                mensaje = "❌ Error: No se pudo registrar la mascota (0 filas afectadas)";
            }

        } catch (SQLException e) {
            e.printStackTrace();
            mensaje = "❌ Error SQL: " + e.getMessage();
            System.out.println("Error SQL completo:");
            System.out.println("SQLState: " + e.getSQLState());
            System.out.println("Error Code: " + e.getErrorCode());
        } catch (Exception e) {
            e.printStackTrace();
            mensaje = "❌ Error: " + e.getMessage();
        }

        return mensaje;
    }
    
    // Método alternativo que no requiere foto
public String registrarMascotaSimple2(HttpServletRequest request) {
    String mensaje = "";
    StringBuilder query = new StringBuilder();
    
    query.append("INSERT INTO mascota(id_mascota, id_propietario, nombre_mascota, tipo, color, raza, ");
    query.append("genero) VALUES (nextval('sec_mas'), ?, ?, ?, ?, ?, ?)");
    
    System.out.println("consulta: " + query.toString());
    
    try {
        insertMascota = connection.prepareStatement(query.toString());
        
        // Parámetros obligatorios
        insertMascota.setInt(1, Integer.parseInt(request.getParameter("idPropietario")));
        insertMascota.setString(2, request.getParameter("nombreM"));
        insertMascota.setString(3, request.getParameter("tipoM"));
        insertMascota.setString(4, request.getParameter("colorM") != null ? request.getParameter("colorM") : "");
        insertMascota.setString(5, request.getParameter("razaM"));
        insertMascota.setString(6, request.getParameter("genero"));
        
        int nroRegistro = insertMascota.executeUpdate();
        
        if (nroRegistro == 1) {
            mensaje = "Mascota registrada exitosamente";
        } else {
            mensaje = "Error al registrar la mascota";
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
        mensaje = "Error en la base de datos: " + e.getMessage();
    }
    
    return mensaje;
}
    
    @Override
    public void close() throws Exception {
        // Llama a tu método existente para cerrar la conexión
        cerrarConexion(); 
        // O cierra la conexión directamente, por ejemplo:
        // if (connection != null && !connection.isClosed()) {
        //     connection.close();
        // }
    }
}
