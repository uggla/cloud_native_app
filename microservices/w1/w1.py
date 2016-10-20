#!/usr/bin/env python3

# Worker 1 called by service B. This worker listen to amqp messages and write
# to redis that the user played.

import io
import datetime
import json
import pika
import redis
import swiftclient


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
    timestamp = datetime.datetime.now()

    # Write to redis
    data = json.loads(body.decode("utf-8"))
    r = redis.Redis("localhost")
    r.set(data["id"], timestamp.strftime("%c"))

    # Write to swift
    _authurl = 'http://10.3.222.89:5000/v2.0/'
    _auth_version = '2'
    _user = 'admin'
    _key = 'password'
    _tenant_name = 'demo'

    conn = swiftclient.Connection(
        authurl=_authurl,
        user=_user,
        key=_key,
        tenant_name=_tenant_name,
        auth_version=_auth_version
    )

    container_name = 'prices'
    conn.put_container(container_name)

#    with open('local.txt', 'rb') as local:
#        conn.put_object(
#            container_name,
#            'local_object.txt',
#            contents=local,
#            content_type='text/plain'
#        )

    content = io.BytesIO(data["img"].encode())
    filename = data["id"] + ".txt"
    print("Filename : {}".format(filename))
    conn.put_object(
        container_name,
        filename,
        contents=content.read(),
        content_type='text/plain'
    )


    # Acknowledge message
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(callback,
                      queue='redis')

channel.start_consuming()
