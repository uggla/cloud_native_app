FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y python3 
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-flask
RUN apt-get install -y imagemagick
RUN useradd w
COPY config.py w.conf w.py /home/w/
COPY prices /home/w/prices/
RUN chown -R w:w /home/w/
EXPOSE 8090
USER w
WORKDIR /home/w
CMD ["./w.py"]
