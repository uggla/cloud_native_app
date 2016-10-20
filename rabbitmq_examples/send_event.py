#!/usr/bin/env python
import pika
import sys

connection = pika.BlockingConnection(
    pika.ConnectionParameters(host='localhost'))

channel = connection.channel()

channel.exchange_declare(exchange='serviceb',
                         exchange_type='direct')

channel.queue_declare(queue='redis')
channel.queue_declare(queue='mailgun')

channel.queue_bind(exchange='serviceb',
                   queue='redis', routing_key='serviceb.msg')
channel.queue_bind(exchange='serviceb',
                   queue='mailgun', routing_key='serviceb.msg')

message = ' '.join(sys.argv[1:]) or "info: Hello World!"
channel.basic_publish(exchange='serviceb',
                      routing_key='serviceb.msg',
                      body=message)
print(" [x] Sent %r" % message)
connection.close()
