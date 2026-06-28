package com.security.examen;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProductServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String searchQuery = request.getParameter("query");
        List<Map<String, Object>> productsList = new ArrayList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String databaseUrl = "jdbc:mysql://localhost:3306/app";
            String databaseUser = "root";
            String databasePassword = new String(new char[]{'r', 'o', 'o', 't'});

            String sql;
            if (searchQuery != null && !searchQuery.trim().isEmpty()) {
                sql = "SELECT * FROM products WHERE name LIKE '%" + searchQuery + "%'";
            } else {
                sql = "SELECT * FROM products";
            }
            request.setAttribute("executedSql", sql);

            try (Connection conn = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
                 Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {

                while (rs.next()) {
                    Map<String, Object> product = new HashMap<>();
                    product.put("id", rs.getInt("id"));
                    product.put("name", rs.getString("name"));
                    product.put("price", rs.getBigDecimal("price"));
                    product.put("stock", rs.getInt("stock"));
                    productsList.add(product);
                }
            }
        } catch (Exception e) {
            request.setAttribute("dbError", e.getMessage());
        }

        request.setAttribute("products", productsList);
        RequestDispatcher requestDispatcher = request.getRequestDispatcher("/WEB-INF/views/products.jsp");
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            String databaseUrl = "jdbc:mysql://localhost:3306/app";
            String databaseUser = "root";
            String databasePassword = new String(new char[]{'r', 'o', 'o', 't'});

            if ("add".equals(action)) {
                String name = request.getParameter("name");
                String priceStr = request.getParameter("price");
                String stockStr = request.getParameter("stock");

                String sql = "INSERT INTO products (name, price, stock) VALUES (?, ?, ?)";
                try (Connection conn = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
                     PreparedStatement pstmt = conn.prepareStatement(sql)) {
                    pstmt.setString(1, name);
                    pstmt.setBigDecimal(2, new BigDecimal(priceStr));
                    pstmt.setInt(3, Integer.parseInt(stockStr));
                    pstmt.executeUpdate();
                }
            } else if ("delete".equals(action)) {
                String id = request.getParameter("id");
                String sql = "DELETE FROM products WHERE id = " + id;
                try (Connection conn = DriverManager.getConnection(databaseUrl, databaseUser, databasePassword);
                     Statement stmt = conn.createStatement()) {
                    stmt.executeUpdate(sql);
                }
            }
        } catch (Exception e) {
            session.setAttribute("crudError", e.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/products");
    }
}
