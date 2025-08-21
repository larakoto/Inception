FROM debian:11

RUN apt update && apt install -y \
    php php-fpm php-mysql \
    curl wget unzip mariadb-client && \
    apt clean

RUN cd /tmp && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY wordpress.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress.sh
EXPOSE 9000
RUN mkdir -p /run/php
CMD ["/usr/local/bin/wordpress.sh"]