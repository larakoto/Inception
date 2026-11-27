# Inception

Projet Docker (42 school) composé de trois services — MariaDB, WordPress (PHP-FPM) et NGINX en HTTPS — orchestrés par `docker-compose`. Chaque service est construit depuis son propre `Dockerfile`, les données persistent dans des volumes bindés sur l'hôte et les mots de passe sont fournis sous forme de *Docker secrets* (jamais stockés dans le dépôt).

## Sommaire

- [Prérequis](#prérequis)
- [Structure du dépôt](#structure-du-dépôt)
- [Installation et lancement](#installation-et-lancement)
- [Configuration](#configuration)
- [Architecture](#architecture)
- [Commandes Makefile](#commandes-makefile)
- [Sécurité](#sécurité)
- [Dépannage](#dépannage)

## Prérequis

- Docker et `docker-compose` (le `Makefile` appelle la commande `docker-compose` ; avec Docker Compose v2, installer le plugin ou créer un alias `docker-compose="docker compose"`).
- `make`.
- `pwgen`, utilisé par `srcs/tools/script.sh` pour générer les mots de passe.
- `bash` et `sudo` (nécessaire à `srcs/tools/scriptdelete.sh` pour supprimer les dossiers de données).
- Le port `443` libre sur la machine hôte.
- Environ 1 à 2 Go d'espace disque libre.

## Structure du dépôt

```text
.
├── .gitignore
└── inception/
    ├── Makefile
    └── srcs/
        ├── .env.example              # modèle de configuration, sans secret
        ├── docker-compose.yml        # services, réseau, volumes et secrets
        ├── requirements/
        │   ├── mariadb/
        │   │   ├── Dockerfile
        │   │   ├── conf              # configuration MariaDB (50-server.cnf)
        │   │   └── mariadb.sh        # initialisation de la base et de l'utilisateur
        │   ├── nginx/
        │   │   ├── Dockerfile
        │   │   └── nginx.sh          # certificat auto-signé + vhost HTTPS
        │   └── wordpress/
        │       ├── Dockerfile
        │       ├── php.conf          # configuration du pool PHP-FPM (www.conf)
        │       └── wordpress.sh      # installation WordPress via wp-cli
        └── tools/
            ├── script.sh             # préparation de l'environnement avant build
            └── scriptdelete.sh       # nettoyage complet
```

Fichiers générés localement, ignorés par Git :

- `inception/srcs/.env` : copié depuis `.env.example` au premier `make build`.
- `inception/secrets/db_pass.txt`, `wp_admin_pass.txt`, `wp_user_pass.txt` : mots de passe aléatoires de 15 caractères.
- `/home/larakoto/data/mariadb` et `/home/larakoto/data/wordpress` : données persistantes.

## Installation et lancement

```bash
git clone git@github.com:larakoto/Inception.git
cd Inception/inception
make build
make up
```

Le site est ensuite disponible sur `https://larakoto.42.fr`. Le certificat étant auto-signé, le navigateur affichera un avertissement à accepter. Pour résoudre ce nom localement, ajouter par exemple au fichier `/etc/hosts` :

```text
127.0.0.1   larakoto.42.fr
```

Il est également possible d'ouvrir `https://localhost`, en ignorant l'avertissement de nom de certificat (`CN=localhost`).

Vérification rapide :

```bash
docker-compose -f srcs/docker-compose.yml ps
docker-compose -f srcs/docker-compose.yml logs -f
```

## Configuration

### Variables d'environnement

`srcs/.env.example` est le modèle versionné. `srcs/tools/script.sh` le copie vers `srcs/.env` uniquement si ce dernier n'existe pas. Modifiez `.env.example` avant le premier build, ou éditez directement `srcs/.env` après sa génération.

| Variable       | Valeur par défaut       | Rôle                                      |
| -------------- | ----------------------- | ----------------------------------------- |
| `DB_NAME`      | `wordpress`             | Nom de la base de données                 |
| `DB_USER`      | `wpuser`                | Utilisateur de la base                    |
| `DB_HOST`      | `mariadb:3306`          | Hôte MariaDB sur le réseau Docker         |
| `WPATH`        | `/var/www/html`         | Répertoire d'installation WordPress       |
| `ADMIN_USER`   | `larakoto`              | Administrateur WordPress                  |
| `ADMIN_EMAIL`  | `larakoto@42.fr`        | E-mail de l'administrateur                 |
| `USER`         | `landry`                | Second utilisateur (rôle *author*)        |
| `USER_MAIL`    | `landry@42.fr`          | E-mail de cet utilisateur                 |

Aucun mot de passe ne figure dans ce fichier.

### Mots de passe et secrets

Au premier `make build`, `script.sh` génère trois fichiers dans `inception/secrets/` avec `pwgen -s 15` :

| Fichier               | Utilisation                                     |
| --------------------- | ----------------------------------------------- |
| `db_pass.txt`         | Mot de passe de l'utilisateur MariaDB           |
| `wp_admin_pass.txt`   | Mot de passe du compte administrateur WordPress |
| `wp_user_pass.txt`    | Mot de passe du compte auteur WordPress         |

`docker-compose.yml` déclare ces fichiers comme *secrets* et définit les variables `DB_PASS_FILE`, `USER_PASS_FILE` et `ADMIN_PASS_FILE` pointant vers `/run/secrets/...`. Les scripts conteneurisés lisent leur contenu avec `cat` :

```bash
DB_PASS=$(cat "$DB_PASS_FILE")
```

Pour régénérer les mots de passe, supprimez le dossier `inception/secrets/` puis relancez `make build` / `make up`. Les identifiants déjà créés dans MariaDB et WordPress ne changent pas automatiquement : il faut repartir d'un environnement propre avec `make clean` si vous voulez les remplacer.

### Chemins et nom de domaine

Les chemins de données sont codés en dur dans `srcs/tools/script.sh` et `srcs/docker-compose.yml` (`/home/larakoto/data/mariadb`, `/home/larakoto/data/wordpress`). Adaptez-les avant le premier lancement si besoin.

Le nom de domaine apparaît dans deux endroits :

- `srcs/requirements/nginx/nginx.sh` : `server_name larakoto.42.fr;`
- `srcs/requirements/wordpress/wordpress.sh` : URL d'installation `https://larakoto.42.fr`

Le certificat TLS est généré au démarrage du conteneur NGINX (`openssl req -x509 -nodes -days 365`, RSA 2048, `CN=localhost`) et n'est valable qu'un an.

## Architecture

- **Réseau** : `inception` (driver `bridge`) ; les conteneurs communiquent par leur nom de service (`mariadb`, `wordpress`, `nginx`).
- **MariaDB** : image `debian:12` + `mariadb-server`, configuration dans `conf` (`bind-address = 0.0.0.0`, port `3306`). Au premier démarrage, `mariadb.sh` démarre le service, crée la base, l'utilisateur et ses privilèges, puis lance `mysqld_safe`.
- **WordPress** : image `debian:12` + PHP-FPM 8.2, `php-mysql`, `mariadb-client` et `wp-cli` (téléchargé pendant le build). `wordpress.sh` télécharge le cœur WordPress, crée `wp-config.php`, installe le site et crée le compte auteur, puis lance `php-fpm8.2 -F`. Le pool est configuré via `php.conf` monté comme `config` Docker. Le service écoute sur le port `9000` et n'est pas exposé directement à l'hôte (`expose`).
- **NGINX** : image `debian:12` + `nginx` + `openssl`. `nginx.sh` génère le certificat, écrit le vhost HTTPS et fait proxy vers `wordpress:9000` via FastCGI. Le port `443` du conteneur est publié sur l'hôte. Le dossier `/var/www/html` est monté en lecture seule.
- **Volumes** : `mariadb_data` et `wordpress_data` sont des volumes `bind` vers `/home/larakoto/data/...`, ce qui conserve les données entre deux `make up` / `make down`.

MariaDB et WordPress utilisent `restart: unless-stopped` ; NGINX garde la politique par défaut de Docker Compose (aucun `restart` explicite).

## Commandes Makefile

Exécuter ces commandes depuis le dossier `inception/` :

| Commande     | Action                                                                                        |
| ------------ | --------------------------------------------------------------------------------------------- |
| `make build` | Lance `srcs/tools/script.sh` (préparation `.env`, dossiers de données et secrets), puis construit les images |
| `make up`    | Démarre les trois services avec `docker-compose -f srcs/docker-compose.yml up`               |
| `make down`  | Arrête les conteneurs et supprime les volumes Docker (`down --volumes`)                      |
| `make clean` | Dépend de `down`, puis exécute `scriptdelete.sh` : supprime les dossiers `/home/larakoto/data/*`, `inception/secrets/` et `inception/srcs/.env` |

`make clean` est destructif : la base de données, les fichiers WordPress et les mots de passe générés sont définitivement supprimés.

## Sécurité

- `.gitignore` exclut `.env`, `secrets/` et `secret/` de tout niveau du dépôt ; seul `.env.example` est versionné.
- Les mots de passe sont générés localement et transmis aux conteneurs via des secrets Docker, sous forme de fichiers dans `/run/secrets/`.
- Le certificat auto-signé convient pour un usage local ; utilisez un certificat CA signé pour une exposition publique.
- **Historique Git** : les anciens commits `b7e46a8` (ajout) et `c3f8040` (suppression) contenaient `secret/credential` et `secret/db_password.txt` avec des identifiants en clair (`password=123`, `pass`, `adminpass`). Si le dépôt a été poussé, changez ces identifiants et purgez l'historique avant de le partager.

## Dépannage

- **`pwgen: command not found`** : installer le paquet (`sudo apt install pwgen`) avant `make build`.
- **`docker-compose: command not found`** : installer Docker Compose (ou utiliser le plugin v2 via un alias).
- **Port `443` déjà utilisé** : identifier le processus avec `sudo ss -ltnp | grep ':443'` et l'arrêter, ou modifier le mapping dans `srcs/docker-compose.yml`.
- **Erreur de connexion à la base au premier lancement** : `wordpress.sh` attend 7 secondes ; consulter `docker-compose -f srcs/docker-compose.yml logs mariadb wordpress`.
- **Avertissement HTTPS** : attendu avec un certificat auto-signé ; vérifier que `CN=localhost` correspond bien à l'hôte utilisé.
- **Modifications de `.env` sans effet** : les scripts d'initialisation ne s'exécutent que si la base / l'installation WordPress n'existent pas déjà. Utilisez `make clean` puis `make build && make up` pour repartir de zéro.
- **Plus de secrets après `make clean`** : relancer `make build` pour régénérer `srcs/.env` et les trois fichiers de mots de passe.
