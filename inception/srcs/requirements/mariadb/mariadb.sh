#!/bin/bash
if [ ! -d "/var/lib/mysql/wordpress" ]; then
    echo "Initialisation de la base de données..."
    service  mariadb start
    sleep 2
    until mysqladmin ping --silent; do
        sleep 1
    done
    mysql -e "CREATE DATABASE IF NOT EXISTS wordpress;"
    mysql -e "CREATE USER IF NOT EXISTS 'wpuser'@'%' IDENTIFIED BY 'pass';"
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
    service  mariadb stop
fi
mysqld_safe

