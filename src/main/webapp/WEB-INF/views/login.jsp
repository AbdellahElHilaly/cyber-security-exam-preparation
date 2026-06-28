<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Connexion - SQL Injection Lab</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #0f172a;
            color: #e2e8f0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .login-card {
            background-color: #1e293b;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            width: 400px;
            border: 1px solid #334155;
        }
        .login-card h2 {
            margin-top: 0;
            color: #38bdf8;
            margin-bottom: 25px;
            text-align: center;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #94a3b8;
            font-weight: 600;
        }
        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 12px;
            background-color: #0f172a;
            border: 1px solid #475569;
            border-radius: 4px;
            color: #fff;
            box-sizing: border-box;
        }
        input[type="submit"] {
            width: 100%;
            background-color: #2563eb;
            color: #fff;
            border: none;
            padding: 12px;
            border-radius: 4px;
            cursor: pointer;
            font-weight: 600;
            margin-top: 10px;
            transition: background-color 0.2s;
        }
        input[type="submit"]:hover {
            background-color: #1d4ed8;
        }
        .error-message {
            background-color: #f43f5e22;
            color: #f43f5e;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid #f43f5e44;
            font-size: 0.9rem;
            text-align: center;
        }
        .back-link {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #94a3b8;
            text-decoration: none;
            font-size: 0.9rem;
        }
        .back-link:hover {
            color: #e2e8f0;
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="login-card">
        <h2>Connexion Lab SQLi</h2>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="login" method="POST">
            <div class="form-group">
                <label for="username">Nom d'utilisateur :</label>
                <input type="text" id="username" name="username" placeholder="Entrez votre nom d'utilisateur">
            </div>
            
            <div class="form-group">
                <label for="password">Mot de passe :</label>
                <input type="password" id="password" name="password" placeholder="Entrez votre mot de passe">
            </div>

            <input type="submit" value="Se connecter">
        </form>

        <% if (request.getAttribute("executedSql") != null) { %>
            <div style="margin-top: 20px; background-color: #0f172a; padding: 15px; border-radius: 4px; border: 1px solid #334155;">
                <div style="color: #94a3b8; font-size: 0.8rem; font-weight: 600; margin-bottom: 5px; text-transform: uppercase; letter-spacing: 0.05em;">SQL Query Executed:</div>
                <code style="color: #38bdf8; font-family: monospace; font-size: 0.85rem; word-break: break-all;"><%= request.getAttribute("executedSql") %></code>
            </div>
        <% } %>

        <a href="<%= request.getContextPath() %>/" class="back-link">Retour à l'accueil</a>
    </div>
</body>
</html>
