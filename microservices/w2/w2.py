#!/usr/bin/env python3

# Worker 1 called by service B. This worker listen to amqp messages and write
# to redis that the user played, and push the image price to swift.

import os
import sys
import datetime
import json
import logging
from logging.handlers import RotatingFileHandler
import pika
import requests
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


def mailgun(domain, apikey, id, to, price):
    return requests.post(
        "https://api.mailgun.net/v3/" + domain + "/messages",
        auth=("api", apikey),
        data={"from": "w2 service <mailgun@" + domain + ">",
              "to": [to],
              "subject": "User id: " + id + " played the game",
              "text": "User id: " + id +
              " won : " + price +
              ", please contact him to agree about delivery conditions."})


########################################
# Main
########################################

logger = initialize_logger("w2.log", "nolog", logging.DEBUG)
logger.info("*** Starting worker w2 ***")
conf = config.Configuration("w2.conf")

try:
    domain = os.environ["W2_DOMAIN"]
    apikey = os.environ["W2_APIKEY"]
    to = os.environ["W2_TO"]
except KeyError:
    print("Please export :")
    print("W2_DOMAIN : with your mailgun domain")
    print("W2_APIKEY : with your mailgun apikey")
    print("W2_TO : with your mail recipient")
    sys.exit(1)


if conf.get_w2_rabbithost() == 'localhost':
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host=conf.get_w2_rabbithost()))
else:
    credentials = pika.PlainCredentials(conf.get_w2_rabbitlogin(),
                                        conf.get_w2_rabbitpassword())
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(credentials=credentials,
                                  host=conf.get_w2_rabbithost()))

channel = connection.channel()

channel.exchange_declare(exchange='serviceb',
                         exchange_type='direct')


channel.queue_declare(queue='mailgun')

channel.queue_bind(exchange='serviceb',
                   queue='mailgun', routing_key='serviceb.msg')

print('Worker w2 running waiting for service b messages. To exit press CTRL+C')


def callback(ch, method, properties, body):
    logger.debug(" [x] %r" % body)
    data = json.loads(body.decode("utf-8"))

    # Send email using mailgun external service
    response = mailgun(domain, apikey, data["id"], to, data["price"])
    logger.debug(response.json())

    # Acknowledge message
    ch.basic_ack(delivery_tag=method.delivery_tag)

channel.basic_consume(callback,
                      queue='mailgun')
try:
    channel.start_consuming()
except KeyboardInterrupt:
    logger.info("*** Stopping worker w2 ***")
