FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get install -y python3 python3-flask
RUN apt-get install -y python3-pip
RUN pip3 install pika
RUN useradd b
COPY config.py b.conf b.py /home/b/
RUN chown -R b:b /home/b/
RUN sed -i -e 's/rabbithost=.*/rabbithost=rabbit/' /home/b/b.conf
RUN sed -i -e 's#wurl=.*#wurl=http://w:8090/play/#' /home/b/b.conf
EXPOSE 8082
USER b
WORKDIR /home/b
CMD ["./b.py"]
