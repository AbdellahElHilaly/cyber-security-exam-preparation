package com.security.examen;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher requestDispatcher = request.getRequestDispatcher("/WEB-INF/views/login.jsp");
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String usernameParameter = request.getParameter("username");
        String passwordParameter = request.getParameter("password");

        String sql = "";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String databaseUrl = "jdbc:mysql://localhost:3306/app";
            String databaseUser = "root";
            String databasePassword = new String(new char[]{'r', 'o', 'o', 't'});

            sql = "SELECT * FROM users WHERE username = '" + usernameParameter 
                       + "' AND password = '" + passwordParameter + "'";
            request.setAttribute("executedSql", sql);

            try (Connection conn = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {
                
                if (rs.next()) {
                    HttpSession session = request.getSession();
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("rule", rs.getString("rule"));
                    response.sendRedirect(request.getContextPath() + "/products");
                } else {
                    request.setAttribute("error", "Identifiants incorrects");
                    RequestDispatcher requestDispatcher = request.getRequestDispatcher("/WEB-INF/views/login.jsp");
                    requestDispatcher.forward(request, response);
                }
            }
        } catch (Exception e) {
            request.setAttribute("error", "Erreur base de données : " + e.getMessage());
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/WEB-INF/views/login.jsp");
            requestDispatcher.forward(request, response);
        }
    }
}
