FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get install -y python3
RUN apt-get install -y python3-pip
RUN pip3 install pika
RUN useradd w1
COPY config.py w1.conf w1.py /home/w1/
RUN chown -R w1:w1 /home/w1/
USER w1
WORKDIR /home/w1
CMD ["./w1.py"]
