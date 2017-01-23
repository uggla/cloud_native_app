FROM mariadb:latest
COPY ./dump/prestashop_fullcustomer.dump.sql /docker-entrypoint-initdb.d/prestashop_fullcustomer.dump.sql
RUN chmod 644 /docker-entrypoint-initdb.d/prestashop_fullcustomer.dump.sql
