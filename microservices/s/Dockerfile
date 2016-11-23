FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get install -y python3 python3-flask
RUN apt-get install -y python3-redis sed
RUN useradd s
COPY config.py s.conf s.py /home/s/
RUN chown -R s:s /home/s/
RUN sed -i -e 's/redishost=.*/redishost=redis/' /home/s/s.conf
EXPOSE 8081
USER s
WORKDIR /home/s
CMD ["./s.py"]
