FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
apt-get install -y python3 python3-flask
RUN apt-get install -y python3-pip
RUN pip3 install -U pip
RUN pip3 install python-swiftclient
RUN pip3 install python-swiftclient
RUN useradd p
COPY config.py p.conf p.py /home/p/
RUN chown -R p:p /home/p/
#RUN sed -i -e 's/rabbithost=.*/rabbithost=rabbit/' /home/b/b.conf
EXPOSE 8083
USER p
WORKDIR /home/p
CMD ["./p.py"]
