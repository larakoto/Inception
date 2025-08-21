#!/bin/bash

DB_PASS=$(cat $DB_PASS_FILE)
ADMIN_PASS=$(cat $ADMIN_PASS_FILE)
USER_PASS=$(cat $USER_PASS_FILE)

sleep 7
if  ! wp --path="$WPATH" core is-installed --allow-root 2> /dev/null; then    

    mkdir -p "$WPATH"

    wp core download --path="$WPATH" --allow-root

    wp  --path="$WPATH" config create --allow-root \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass=$DB_PASS \
        --dbhost="$DB_HOST"

    wp --path="$WPATH" core install --allow-root \
        --url="https://larakoto.42.fr" \
        --title="Mon WP" \
        --admin_user="$ADMIN_USER" \
        --admin_password=$ADMIN_PASS \
        --admin_email="$ADMIN_EMAIL"     
    wp  --path="$WPATH" user create --allow-root  "$USER" "$USER_MAIL" \
        --role=author \
        --user_pass=$USER_PASS 
    chown -R www-data:www-data "$WPATH"
fi

php-fpm7.4 -F