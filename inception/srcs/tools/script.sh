#!/bin/bash


PROJECT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_DIR" || exit 1

if [ ! -f "srcs/.env" ]; then
    cat > "srcs/.env" <<EOF
DB_NAME=wordpress
DB_USER=wpuser
DB_HOST=mariadb:3306
WPATH=/var/www/html
ADMIN_USER=larakoto
ADMIN_EMAIL=larakoto@42.fr
USER=landry
USER_MAIL=landry@42.fr
EOF
fi

wordpressFolder="/home/larakoto/data/wordpress"
mariadbFolder="/home/larakoto/data/mariadb"


if [ ! -d "$mariadbFolder" ]; then    
    mkdir -p $mariadbFolder 
fi

if [ ! -d "$wordpressFolder" ]; then
    mkdir -p $wordpressFolder
fi

if [ ! -d "./secrets" ]; then
    mkdir -p ./secrets
    cd ./secrets
    touch db_pass.txt
    touch wp_admin_pass.txt
    touch wp_user_pass.txt
    pwgen -s  15  > db_pass.txt
    pwgen -s  15  > wp_admin_pass.txt
    pwgen -s  15  > wp_user_pass.txt
fi




