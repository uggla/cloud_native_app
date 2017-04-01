FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y apache2
COPY index.html /var/www/html/
COPY favicon.ico /var/www/html/
COPY js /var/www/html/js/
COPY css /var/www/html/css/
COPY img /var/www/html/img/
COPY templates/cna.conf.docker /etc/apache2/sites-available/cna.conf
COPY js/config.js /var/www/html/js/config.js
RUN chown -R www-data:www-data /var/www/html
RUN /usr/sbin/a2dissite 000-default
# Configure reverse proxy
RUN /usr/sbin/a2enmod proxy_http
RUN /usr/sbin/a2ensite cna
EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND", "-k", "start"]
