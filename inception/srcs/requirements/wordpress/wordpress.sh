#!/bin/bash

mkdir -p /var/www/html


echo "config create !"

wp core download --path=/var/www/html --allow-root

wp  --path=/var/www/html config create --allow-root \
    --dbname=wordpress \
    --dbuser=wpuser \
    --dbpass=pass \
    --dbhost=mariadb:3306 

echo "core install !"

wp --path=/var/www/html core install --allow-root \
    --url="https://localhost" \
    --title="Mon WP" \
    --admin_user=admin \
    --admin_password=adminpass \
    --admin_email=admin@site.com     
echo "user creation !"
wp  --path=/var/www/html user create --allow-root  user1 user1@example.com \
    --role=editor \
    --user_pass=123 
chown -R www-data:www-data /var/www/html

echo "wp done !"
php-fpm7.4 -F