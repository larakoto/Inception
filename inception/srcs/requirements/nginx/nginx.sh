#!/bin/bash
mkdir -p /etc/nginx/ssl
mkdir -p /var/www/html


openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/CN=localhost"

cat > /etc/nginx/sites-available/default <<EOF
server {
    listen 443 ssl;
    server_name larakoto.42.fr;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    ssl_protocols TLSv1.2;
    ssl_prefer_server_ciphers on;

    root /var/www/html;
    index index.php;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_pass wordpress:9000;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

nginx -g "daemon off;"