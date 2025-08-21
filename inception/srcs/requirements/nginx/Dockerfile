FROM debian:11
RUN apt update && apt install  -y nginx openssl
COPY nginx.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx.sh
EXPOSE 443
CMD ["/usr/local/bin/nginx.sh"]