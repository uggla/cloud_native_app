FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y python3 
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-redis sed
RUN pip3 install -U pip
RUN pip3 install pika
RUN pip3 install python-swiftclient
RUN pip3 install python-keystoneclient
RUN useradd w1
COPY config.py w1.conf w1.py /home/w1/
RUN chown -R w1:w1 /home/w1/
#RUN sed -i -re 's/rabbithost\s+=.*/rabbithost=rabbit/' /home/w1/w1.conf
#RUN sed -i -re 's/redishost\s+=.*/redishost=redis/' /home/w1/w1.conf
USER w1
WORKDIR /home/w1
CMD ["./w1.py"]
