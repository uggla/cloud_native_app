#!/usr/bin/env python
import pika

connection = pika.BlockingConnection(
    pika.ConnectionParameters(host='localhost'))

channel = connection.channel()

channel.exchange_declare(exchange='event',
                         exchange_type='direct')


channel.queue_declare(queue='redis')
channel.queue_declare(queue='mailgun')

channel.queue_bind(exchange='event',
                   queue='redis', routing_key='mymsg')

channel.queue_bind(exchange='event',
                   queue='mailgun', routing_key='mymsg')

print(' [*] Waiting for logs. To exit press CTRL+C')


def callback(ch, method, properties, body):
    print(" [x] %r" % body)

channel.basic_consume(callback,
                      queue='redis')

channel.start_consuming()
