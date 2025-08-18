FROM debian:11

RUN apt update && apt install -y mariadb-server
COPY mariadb.sh /usr/local/bin
COPY conf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod +x /usr/local/bin/mariadb.sh 
EXPOSE 3306
CMD ["/usr/local/bin/mariadb.sh"]