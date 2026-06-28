<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestion des Produits - SQLi Lab</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f172a;
            color: #e2e8f0;
            margin: 0;
            padding: 40px;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #334155;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #38bdf8;
            margin: 0;
        }
        .user-info {
            background-color: #1e293b;
            padding: 10px 20px;
            border-radius: 4px;
            border: 1px solid #334155;
            font-size: 0.9rem;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        .grid {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 30px;
        }
        .card {
            background-color: #1e293b;
            border-radius: 8px;
            padding: 20px;
            border: 1px solid #334155;
        }
        .card h2 {
            margin-top: 0;
            color: #f43f5e;
            font-size: 1.2rem;
            margin-bottom: 20px;
        }
        .search-box {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .search-box input[type="text"] {
            flex-grow: 1;
            padding: 10px;
            background-color: #0f172a;
            border: 1px solid #475569;
            border-radius: 4px;
            color: #fff;
        }
        .search-box button {
            background-color: #2563eb;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
        }
        .search-box button:hover {
            background-color: #1d4ed8;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #334155;
        }
        th {
            background-color: #0f172a;
            color: #94a3b8;
            font-weight: 600;
        }
        .btn-delete {
            background-color: #ef4444;
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8rem;
        }
        .btn-delete:hover {
            background-color: #dc2626;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            color: #94a3b8;
            font-size: 0.9rem;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            background-color: #0f172a;
            border: 1px solid #475569;
            border-radius: 4px;
            color: #fff;
            box-sizing: border-box;
        }
        .btn-submit {
            width: 100%;
            background-color: #10b981;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
        }
        .btn-submit:hover {
            background-color: #059669;
        }
        .error-msg {
            color: #ef4444;
            margin-bottom: 15px;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Product Dashboard (SQL Lab)</h1>
            <div class="user-info">
                Utilisateur : <strong><%= session.getAttribute("username") %></strong> | 
                Rôle : <strong><%= session.getAttribute("rule") %></strong>
            </div>
        </div>

        <% if (request.getAttribute("dbError") != null) { %>
            <div class="error-msg">
                Erreur de recherche : <%= request.getAttribute("dbError") %>
            </div>
        <% } %>

        <% if (session.getAttribute("crudError") != null) { %>
            <div class="error-msg">
                Erreur d'édition : <%= session.getAttribute("crudError") %>
                <% session.removeAttribute("crudError"); %>
            </div>
        <% } %>

        <div class="grid">
            <div class="card">
                <h2>Liste des Produits</h2>
                
                <form action="products" method="GET" class="search-box">
                    <input type="text" name="query" placeholder="Rechercher un produit (vulnérable SQLi)..." value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>">
                    <button type="submit">Rechercher</button>
                </form>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Nom</th>
                            <th>Prix</th>
                            <th>Stock</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            List<Map<String, Object>> products = (List<Map<String, Object>>) request.getAttribute("products");
                            if (products != null && !products.isEmpty()) {
                                for (Map<String, Object> product : products) {
                        %>
                                <tr>
                                    <td><%= product.get("id") %></td>
                                    <td><%= product.get("name") %></td>
                                    <td><%= product.get("price") %> €</td>
                                    <td><%= product.get("stock") %></td>
                                    <td>
                                        <form action="products?action=delete" method="POST" style="display:inline;">
                                            <input type="hidden" name="id" value="<%= product.get("id") %>">
                                            <button type="submit" class="btn-delete">Supprimer</button>
                                        </form>
                                    </td>
                                </tr>
                        <%
                                }
                            } else {
                        %>
                            <tr>
                                <td colspan="5" style="text-align: center; color: #94a3b8;">Aucun produit trouvé</td>
                            </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <div class="card">
                <h2>Ajouter un Produit</h2>
                <form action="products?action=add" method="POST">
                    <div class="form-group">
                        <label for="name">Nom du produit :</label>
                        <input type="text" id="name" name="name" required>
                    </div>
                    <div class="form-group">
                        <label for="price">Prix (€) :</label>
                        <input type="text" id="price" name="price" placeholder="Ex: 5.50" required>
                    </div>
                    <div class="form-group">
                        <label for="stock">Quantité en stock :</label>
                        <input type="text" id="stock" name="stock" placeholder="Ex: 100" required>
                    </div>
                    <button type="submit" class="btn-submit">Ajouter</button>
                </form>
            </div>
        </div>

        <% if (request.getAttribute("executedSql") != null) { %>
            <div class="card" style="margin-top: 30px;">
                <h2 style="color: #38bdf8; margin-bottom: 10px;">SQL Query Executed</h2>
                <div style="background-color: #0f172a; padding: 15px; border-radius: 4px; border: 1px solid #334155;">
                    <code style="color: #38bdf8; font-family: monospace; font-size: 0.9rem; word-break: break-all;"><%= request.getAttribute("executedSql") %></code>
                </div>
            </div>
        <% } %>
    </div>
</body>
</html>
