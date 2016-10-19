#!/usr/bin/env python3

# Worker 1 called by service B. This worker listen to amqp messages and write
# to redis that the user played.

import pika
import redis


connection = pika.BlockingConnection(
    pika.ConnectionParameters(host='localhost'))

channel = connection.channel()

channel.exchange_declare(exchange='serviceb',
                         exchange_type='direct')


channel.queue_declare(queue='redis')

channel.queue_bind(exchange='serviceb',
                   queue='redis', routing_key='serviceb.msg')

print('Worker w1 running waiting for service b messages. To exit press CTRL+C')


def callback(ch, method, properties, body):
    print(" [x] %r" % body)
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(callback,
                      queue='redis')

channel.start_consuming()
