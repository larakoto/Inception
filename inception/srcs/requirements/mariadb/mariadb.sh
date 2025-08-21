#!/bin/bash
DB_PASS=$(cat $DB_PASS_FILE)

if [ ! -d "/var/lib/mysql/wordpress" ]; then
    service  mariadb start
    sleep 2
    until mysqladmin ping --silent; do
        sleep 1
    done
    mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';"
    mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'%';"
    mysql -e "FLUSH PRIVILEGES;"
    service  mariadb stop
fi
mysqld_safe
