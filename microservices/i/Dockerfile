FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get install -y python3 python3-flask
RUN apt-get install -y libmysqlclient-dev python3-pip sed
RUN pip3 install mysqlclient
RUN useradd i
COPY config.py i.conf i.py /home/i/
RUN chown -R i:i /home/i/
RUN sed -i -e 's/dbhost=.*/dbhost=mariadb/' /home/i/i.conf
EXPOSE 8080
USER i
WORKDIR /home/i
CMD ["./i.py"]
