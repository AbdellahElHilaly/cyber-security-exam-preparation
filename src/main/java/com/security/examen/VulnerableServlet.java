package com.security.examen;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class VulnerableServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
            String id = request.getParameter("id");
            String page = request.getParameter("page");
            String name = request.getParameter("name");

        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
            String sql = "";
            String debugMessage = "";
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String databaseUrl = "jdbc:mysql://localhost:3306/app";
                String databaseUser = "root";
                String databasePassword = new String(new char[]{'r', 'o', 'o', 't'});
                sql = "SELECT * FROM users WHERE id = " + id;

                try (Connection conn = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
                     Statement stmt = conn.createStatement();
                     ResultSet rs = stmt.executeQuery(sql)) {
                    if (rs.next()) {
                        out.println("<h1>Bienvenue " + name + " !</h1>");
                    } else {
                        out.println("<h1>Utilisateur inconnu</h1>");
                    }
                }
                debugMessage = "<p style='color: blue; font-family: monospace; font-size: 0.9rem; background-color: white; padding: 10px; border-radius: 4px; border: 1px solid #334155;'>Requête SQL exécutée : " + sql + "</p>";
            } catch (Exception e) {
                out.println("<p>Erreur : " + e.getMessage() + "</p>");
                debugMessage = "<p style='color: blue; font-family: monospace; font-size: 0.9rem; background-color: white; padding: 10px; border-radius: 4px; border: 1px solid #ef4444;'>Requête SQL tentée : " + sql + "</p>";
            }

            try {
                String target = "/WEB-INF/views/" + page + ".jsp";
                RequestDispatcher rd = request.getRequestDispatcher(target);
                rd.include(request, response);
            } catch (ServletException | IOException e) {
                out.println("<p>Erreur d'inclusion : " + e.getMessage() + "</p>");
            }

            if (!debugMessage.isEmpty()) {
                out.println(debugMessage);
            }
        }
    }
}
