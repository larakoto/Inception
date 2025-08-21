#!/bin/bash
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
    touch db_pass
    touch wp_admin_pass
    touch wp_user_pass
    pwgen -s 10 > db_pass
    pwgen -s 10 > wp_admin_pass
    pwgen -s 10 > wp_user_pass
fi

if [ ! -f "srcs/.env" ]; then
    mkdir -p "srcs"
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


