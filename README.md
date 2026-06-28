# Guide d'Audit de Sécurité Web - Lab d'Examen

Ce document sert de rapport officiel pour le projet d'**Audit d'application Web** et de guide d'apprentissage pour les débutants. Il explique en détail le fonctionnement des vulnérabilités présentes dans l'application Java Servlet fournie, comment les exploiter à des fins de démonstration, et comment implémenter des contre-mesures efficaces.

---

## 🎯 Concepts de Base (Pour Débutant)

Avant d'entrer dans les détails de l'examen, voici une explication simple des termes de sécurité :
*   **Vulnérabilité (Vulnerability) :** Une faiblesse ou une faille dans le code d'une application qui peut être exploitée par une personne malveillante.
*   **Exploit / Payload :** Le code spécial ou la requête manipulée qu'un attaquant envoie à l'application pour exploiter la faille.
*   **Contre-mesure (Countermeasure) :** La correction du code ou de la configuration pour fermer la faille de sécurité.
*   **La Triade CIA :**
    *   **Confidentialité (Confidentiality) :** S'assurer que seules les personnes autorisées ont accès aux données.
    *   **Intégrité (Integrity) :** S'assurer que les données ne sont pas modifiées ou altérées de manière non autorisée.
    *   **Disponibilité (Availability) :** S'assurer que le système et les données sont accessibles quand on en a besoin.

---

## 🔍 Question 1 : Identification des Vulnérabilités

Le code de `VulnerableServlet` contient trois vulnérabilités majeures et une vulnérabilité secondaire :

### 1. Injection SQL (SQLi)
*   **Localisation dans le code :**
    ```java
    String sql = "SELECT * FROM users WHERE id = " + id;
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(sql);
    ```
*   **Pourquoi le code est vulnérable :** Le paramètre `id` fourni par l'utilisateur via l'URL est concaténé directement dans la requête SQL sans aucune validation ni échappement. Le pilote de base de données interprétera toute commande SQL insérée dans ce paramètre comme faisant partie de la structure de la requête.

### 2. Cross-Site Scripting Reflété (Reflected XSS)
*   **Localisation dans le code :**
    ```java
    out.println("<h1>Bienvenue " + name + " !</h1>");
    ```
*   **Pourquoi le code est vulnérable :** Le servlet prend le paramètre `name` de la requête et le renvoie directement dans la réponse HTML envoyée au navigateur de l'utilisateur sans aucun encodage HTML. Si le paramètre contient des balises HTML ou JavaScript, le navigateur de la victime exécutera le script.

### 3. Inclusion de Fichiers Locaux (LFI / Path Traversal)
*   **Localisation dans le code :**
    ```java
    String target = "/WEB-INF/views/" + page + ".jsp";
    RequestDispatcher rd = request.getRequestDispatcher(target);
    rd.include(request, response);
    ```
*   **Pourquoi le code est vulnérable :** Le paramètre `page` est utilisé directement pour construire le chemin du fichier JSP à inclure via le `RequestDispatcher`. Un attaquant peut manipuler ce paramètre pour inclure des fichiers JSP sensibles (comme `admin.jsp`) ou utiliser des séquences de remontée de répertoire (`../`) pour forcer le serveur à lire d'autres fichiers.

### 4. Divulgation d'informations (Information Disclosure)
*   **Localisation dans le code :**
    ```java
    } catch (Exception e) {
        out.println("<p>Erreur : " + e.getMessage() + "</p>");
    }
    ```
*   **Pourquoi le code est vulnérable :** En cas d'erreur de base de données ou de syntaxe, l'application affiche directement le message de l'exception (`e.getMessage()`) à l'utilisateur. Cela révèle des détails techniques sur la base de données (comme le fait qu'il s'agisse de MySQL) et la structure des requêtes.

---

## 💣 Question 2 : Expositions des Exploits (Exploits & Impacts)

### 1. Exploit d'Injection SQL
*   **URL d'exploitation :**
    `http://localhost:8080/vulnerable?id=1 OR 1=1&name=Guest&page=home`
*   **Mécanisme :** La requête SQL finale devient :
    `SELECT * FROM users WHERE id = 1 OR 1=1`
    Comme la condition `1=1` est toujours vraie, la base de données retourne le premier utilisateur de la table (généralement l'administrateur), contournant ainsi la vérification d'identité.
*   **Impact attendu :** contournement de l'authentification et accès non autorisé à des données confidentielles (Perte de **Confidentialité**).

### 2. Exploit XSS Reflété
*   **URL d'exploitation :**
    `http://localhost:8080/vulnerable?id=1&name=<script>alert(document.cookie)</script>&page=home`
*   **Mécanisme :** Le navigateur reçoit et interprète le code JavaScript inséré dans le paramètre `name`.
*   **Impact attendu :** Vol de cookies de session (session hijacking), redirection de l'utilisateur vers des sites malveillants, ou modification visuelle de la page (Perte de **Confidentialité** et d'**Intégrité**).

### 3. Exploit LFI (Local File Inclusion)
*   **URL d'exploitation :**
    `http://localhost:8080/vulnerable?id=1&name=Guest&page=admin`
*   **Mécanisme :** L'application inclut `/WEB-INF/views/admin.jsp`, permettant à un simple utilisateur d'afficher l'interface d'administration protégée.
*   **Impact attendu :** Accès à des pages d'administration confidentielles et divulgation d'informations sensibles (Perte de **Confidentialité**).

---

## 🛡️ Question 3 : Contre-mesures Détaillées et Triade CIA

Voici les modifications nécessaires pour sécuriser le code :

### 1. Sécurisation contre l'Injection SQL (PreparedStatement)
*   **Code corrigé :**
    ```java
    String sql = "SELECT * FROM users WHERE id = ?";
    PreparedStatement pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(id));
    ResultSet rs = pstmt.executeQuery();
    ```
*   **Explication :** En utilisant un `PreparedStatement`, les données de l'utilisateur sont traitées strictement comme des paramètres et non comme du code SQL exécutable.
*   **Impact CIA :** Garantit la **Confidentialité** (empêche l'accès non autorisé aux données) et l'**Intégrité** (empêche la modification des données par injection de commandes comme `UPDATE`).

### 2. Sécurisation contre le XSS (HTML Escaping)
*   **Code corrigé :**
    ```java
    // Importer la classe de sécurité OWASP : import org.owasp.encoder.Encode;
    String safeName = Encode.forHtml(name);
    out.println("<h1>Bienvenue " + safeName + " !</h1>");
    ```
*   **Explication :** L'utilisation de la bibliothèque standard de sécurité **OWASP Java Encoder** (`Encode.forHtml`) permet d'échapper automatiquement et de manière hautement sécurisée tous les caractères spéciaux HTML (tels que `<`, `>`, `&`, `"`, `'`) afin de neutraliser toute exécution de code JavaScript malveillant.
*   **Impact CIA :** Protège la **Confidentialité** (empêche le vol de cookies de session) et l'**Intégrité** de la page affichée au client.


### 3. Sécurisation contre la LFI (Validation par Whitelist)
*   **Code corrigé :**
    ```java
    Set<String> allowedPages = Set.of("home", "dashboard");
    if (!allowedPages.contains(page)) {
        page = "home";
    }
    String target = "/WEB-INF/views/" + page + ".jsp";
    ```
*   **Explication :** L'utilisation d'une liste blanche (whitelist) garantit que seuls les noms de fichiers explicitement autorisés peuvent être inclus, bloquant toute tentative de remontée de répertoire.
*   **Impact CIA :** Protège la **Confidentialité** (empêche la lecture de fichiers sensibles).

### 4. Sécurisation contre la divulgation d'informations (Exceptions loggées)
*   **Code corrigé :**
    ```java
    } catch (Exception e) {
        // Enregistrer l'erreur en interne dans les logs du serveur
        getServletContext().log("Erreur base de données", e);
        // Afficher un message générique sans détails techniques à l'utilisateur
        out.println("<p>Une erreur interne est survenue. Veuillez contacter l'administrateur.</p>");
    }
    ```
*   **Explication :** Masquer les détails de l'erreur empêche les attaquants de cartographier la structure technique de l'application.
*   **Impact CIA :** Améliore la **Confidentialité** des informations système.

---

## 🛠️ Guide d'Utilisation du Lab dans IntelliJ IDEA

Pour lancer l'application et tester ces vulnérabilités :

1.  **Lancer le projet :**
    Dans **IntelliJ IDEA**, cliquez sur le bouton de lecture vert (**Run** ou **Debug**) en haut à droite avec la configuration de serveur `examen`.
2.  **Ouvrir l'application :**
    Accédez à [http://localhost:8080/](http://localhost:8080/) dans votre navigateur.
3.  **Tester via l'interface :**
    La page d'accueil affiche un formulaire interactif et des liens rapides pré-remplis pour simuler chaque vulnérabilité et observer instantanément les résultats.
