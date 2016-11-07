#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""
Service B trigger service W in order to define the user price then,
send an amqp message to worker w1 that will write to redis, swift and worker w2 that will send a mail using mailgun.
"""

import logging
from logging.handlers import RotatingFileHandler
import pprint
import os
import sys
import json
from flask import Flask
from flask import jsonify
from flask import request
import requests
import pika
import config

# Initialise Flask
app = Flask(__name__)
app.debug = True

# Affect app logger to a global variable so logger can be used elsewhere.
config.logger = app.logger


@app.route("/user/<id>")
def api_play(id):
    """Retrieve data for user <id>"""
    config.logger.info("*** Start processing id %s ***", id)

    # Call service w
    w = requests.get("http://localhost:8090/play/" + id)
    config.logger.debug(w)
    config.logger.debug(w.json())

    data = w.json()
    config.logger.debug(data["price"])

    # Send message to workers.
    if config.b.conf_file.get_b_rabbithost() == 'localhost':
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(
                host=config.b.conf_file.get_b_rabbithost()))
    else:
        credentials = pika.PlainCredentials(
            config.b.conf_file.get_b_rabbitlogin(),
            config.b.conf_file.get_b_rabbitpassword())
        connection = pika.BlockingConnection(
            pika.ConnectionParameters(
                credentials=credentials,
                host=config.b.conf_file.get_b_rabbithost()))

    channel = connection.channel()

    channel.exchange_declare(exchange='serviceb',
                             exchange_type='direct')

    channel.queue_declare(queue='redis')
    channel.queue_declare(queue='mailgun')

    channel.queue_bind(exchange='serviceb',
                       queue='redis', routing_key='serviceb.msg')
    channel.queue_bind(exchange='serviceb',
                       queue='mailgun', routing_key='serviceb.msg')

    message = json.dumps({"id": id,
                          "price": data["price"],
                          "img": data["img"]})
    channel.basic_publish(exchange='serviceb',
                          routing_key='serviceb.msg',
                          body=message)
    config.logger.debug(" [x] Sent %r" % message)
    connection.close()

    # Send back answer
    data = {"status": "ok"}
    resp = jsonify(data)
    resp.status_code = 200
    config.logger.info("*** End processing id %s ***", id)
    add_headers(resp)
    return resp


@app.route("/shutdown", methods=["POST"])
def shutdown():
    """Shutdown server"""
    shutdown_server()
    config.logger.info("Stopping %s...", config.b.NAME)
    return "Server shutting down..."


@app.route("/", methods=["GET"])
def api_root():
    """Root url, provide service name and version"""
    data = {
        "Service": config.b.NAME,
        "Version": config.b.VERSION
    }

    resp = jsonify(data)
    resp.status_code = 200

    resp.headers["AuthorSite"] = "https://github.com/uggla/openstack_lab"

    add_headers(resp)
    return resp


def shutdown_server():
    """shutdown server"""
    func = request.environ.get("werkzeug.server.shutdown")
    if func is None:
        raise RuntimeError("Not running with the Werkzeug Server")
    func()


def configure_logger(logger, logfile):
    """Configure logger"""
    formatter = logging.Formatter(
        "%(asctime)s :: %(levelname)s :: %(message)s")
    file_handler = RotatingFileHandler(logfile, "a", 1000000, 1)

    # Add logger to file
    if (config.b.conf_file.get_b_debug().title() == 'True'):
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)


def add_headers(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers',
                         'Content-Type,Authorization')


if __name__ == "__main__":
    # Vars
    app_logfile = "b.log"

    # Change diretory to script one
    try:
        os.chdir(os.path.dirname(sys.argv[0]))
    except FileNotFoundError:
        pass

    # Define a PrettyPrinter for debugging.
    pp = pprint.PrettyPrinter(indent=4)

    # Initialise apps
    config.initialise_b()

    # Configure Flask logger
    configure_logger(app.logger, app_logfile)

    config.logger.info("Starting %s", config.b.NAME)
    app.run(port=int(config.b.conf_file.get_b_port()), processes=4, host='0.0.0.0')
