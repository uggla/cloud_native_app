#!/usr/bin/env python3

# Worker 1 called by service B. This worker listen to amqp messages and write
# to redis that the user played, and push the image price to swift.

import os
import sys
import io
import datetime
import time
import json
import logging
from logging.handlers import RotatingFileHandler
import pika
import redis
import swiftclient
import config


def initialize_logger(LOGFILE,
                      CONSOLE_LOGGER_LEVEL,
                      FILE_LOGGER_LEVEL,
                      logger_name=None):
    '''Initialize a global logger to track application behaviour

    :param logfile: Log filename
    :type logfile: str
    :param screen_logger_level: Console log level
                                (logging.DEBUG, logging.ERROR, ..) or nolog
    :type screen_logger_level: logging constant or string
    :param file_logger_level: File log level
    :type file_logger_level: logging constant
    :returns:  logging object

    '''

    logger = logging.getLogger(logger_name)
    logger.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        '%(asctime)s :: %(levelname)s :: %(message)s')

    try:
        file_handler = RotatingFileHandler(
            os.path.expandvars(LOGFILE), 'a', 1000000, 1)
    except IOError:
        print('ERROR: {} does not exist or is not writeable.\n'.format(
            LOGFILE))
        print('       Try to create directory {}'.format(os.path.dirname(
            LOGFILE)))
        print('       using: mkdir -p {}'.format(os.path.dirname(
            LOGFILE)))
        sys.exit(1)

    # First logger to file
    file_handler.setLevel(FILE_LOGGER_LEVEL)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

    # Second logger to console
    if CONSOLE_LOGGER_LEVEL != "nolog":
        steam_handler = logging.StreamHandler()
        steam_handler.setLevel(CONSOLE_LOGGER_LEVEL)
        logger.addHandler(steam_handler)
    return logger

########################################
# Main
########################################

logger = initialize_logger("w1.log", "nolog", logging.DEBUG)
logger.info("*** Starting worker w1 ***")
conf = config.Configuration("w1.conf")

timeout = 0
while 1:
    try:
        if conf.get_w1_rabbithost() == 'localhost':
            connection = pika.BlockingConnection(
                pika.ConnectionParameters(host=conf.get_w1_rabbithost()))
        else:
            credentials = pika.PlainCredentials(conf.get_w1_rabbitlogin(),
                                                conf.get_w1_rabbitpassword())
            connection = pika.BlockingConnection(
                pika.ConnectionParameters(credentials=credentials,
                                          host=conf.get_w1_rabbithost()))
        break
    except pika.exceptions.ConnectionClosed:
        print("Waiting rabbitmq server for 10 more seconds.")
        time.sleep(10)
        timeout += 10
        if timeout >= 30:
            print('ERROR: Rabbitmq is not available !')
            sys.exit(1)

channel = connection.channel()

channel.exchange_declare(exchange='serviceb',
                         exchange_type='direct')


channel.queue_declare(queue='redis')

channel.queue_bind(exchange='serviceb',
                   queue='redis', routing_key='serviceb.msg')

print('Worker w1 running waiting for service b messages. To exit press CTRL+C')


def callback(ch, method, properties, body):
    logger.debug(" [x] %r" % body)
    timestamp = datetime.datetime.now()

    # Write to redis
    data = json.loads(body.decode("utf-8"))
    r = redis.Redis(conf.get_w1_redishost())
    r.set(data["id"], timestamp.strftime("%c"))

    # Check if we need to write redis or swift
    if (conf.get_w1_imagestore() == 'redis'):
        # Write image to redis
        rediskey = data["id"] + ".txt"
        r.set(rediskey, data["img"])
        logger.debug("Data written to redis")
    else:
        # Write image to swift
        os_parameters = conf.get_w1_os_parameters()
        _authurl = os_parameters["os_authurl"]
        _auth_version = os_parameters["os_auth_version"]
        _user = os_parameters["os_user"]
        _key = os_parameters["os_key"]
        _tenant_name = os_parameters["os_tenant_name"]

        conn = swiftclient.Connection(
            authurl=_authurl,
            user=_user,
            key=_key,
            tenant_name=_tenant_name,
            auth_version=_auth_version
        )

        container_name = 'prices'
        conn.put_container(container_name)
        content = io.BytesIO(data["img"].encode())
        filename = data["id"] + ".txt"
        logger.debug("Filename : {}".format(filename))
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
try:
    channel.start_consuming()
except KeyboardInterrupt:
    logger.info("*** Stopping worker w1 ***")
