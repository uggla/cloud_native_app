#!/usr/bin/env python
import pika

connection = pika.BlockingConnection(
    pika.ConnectionParameters(host='localhost'))

channel = connection.channel()

channel.exchange_declare(exchange='serviceb',
                         exchange_type='direct')


channel.queue_declare(queue='redis')

channel.queue_bind(exchange='serviceb',
                   queue='redis', routing_key='serviceb.msg')

print(' [*] Waiting for logs. To exit press CTRL+C')


def callback(ch, method, properties, body):
    print(" [x] %r" % body)
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(callback,
                      queue='redis')

channel.start_consuming()
