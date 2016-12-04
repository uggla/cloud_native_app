FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get install -y apache2
COPY index.html /var/www/html/
COPY js /var/www/html/js/
RUN chown -R www-data:www-data /var/www/html
RUN /usr/sbin/a2dissite 000-default
#RUN sed -i -e 's/redishost=.*/redishost=redis/' /home/s/s.conf
EXPOSE 80
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND", "-k", "start"]
