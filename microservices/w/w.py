#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""Service W define the price won by a customer"""

import base64
import logging
from logging.handlers import RotatingFileHandler
import pprint
from os import listdir
from os.path import isfile
from os.path import join
import random
import time
import subprocess
from flask import Flask
from flask import jsonify
from flask import request
import config

# Initialise Flask
app = Flask(__name__)
app.debug = True

# Affect app logger to a global variable so logger can be used elsewhere.
config.logger = app.logger


@app.route("/play/<id>")
def api_play(id):
    """Define the price for user <id>"""

    # Get list of prices and randomly choose one
    prices = listprices("prices")
    config.logger.info("Prices list: %s", prices)
    price = random.choice(prices)
    config.logger.info("Price win: %s", price)

    # Add a watermark with the id to the image using Imagemagick convert
    cmd = "convert prices/" + \
          price + \
          " -background Khaki label:'id:" + \
          id + \
          "' -gravity center -append /tmp/" + \
          id + "_" + price

    config.logger.info("Command: %s", cmd)

    subprocess.check_call(cmd.split())

    # Ready the watermarked image and encore it to base64
    with open("/tmp/" + id + "_" + price, mode='rb') as file:
        file_content = file.read()
        img = base64.b64encode(file_content)

    config.logger.info("Img: %s", img)

    time.sleep(5)  # Add latency on the service to simulate a long process

    data = {"price": price, "img": img.decode("ascii")}
    resp = jsonify(data)
    resp.status_code = 200
    return resp


@app.route("/shutdown", methods=["POST"])
def shutdown():
    """Shutdown server"""
    shutdown_server()
    config.logger.info("Stopping %s...", config.w.NAME)
    return "Server shutting down..."


@app.route("/", methods=["GET"])
def api_root():
    """Root url, provide service name and version"""
    data = {
        "Service": config.w.NAME,
        "Version": config.w.VERSION
    }

    resp = jsonify(data)
    resp.status_code = 200

    resp.headers["AuthorSite"] = "https://github.com/uggla/openstack_lab"

    return resp


def listprices(path):
    onlyfiles = [f for f in listdir(path) if isfile(join(path, f))]
    return onlyfiles


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
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)


if __name__ == "__main__":
    # Vars
    app_logfile = "w.log"

    # Define a PrettyPrinter for debugging.
    pp = pprint.PrettyPrinter(indent=4)

    # Configure Flask logger
    configure_logger(app.logger, app_logfile)

    # Initialise apps
    config.initialise_w()

    config.logger.info("Starting %s", config.w.NAME)
    app.run(port=int(config.w.conf_file.get_w_port()))
