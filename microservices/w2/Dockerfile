FROM debian:jessie
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN pip3 install pika
RUN useradd w2
COPY config.py w2.conf w2.py /home/w2/
RUN chown -R w2:w2 /home/w2/
RUN sed -i -re 's/rabbithost\s+=.*/rabbithost=rabbit/' /home/w2/w2.conf
USER w2
WORKDIR /home/w2
CMD ["./w2.py"]
