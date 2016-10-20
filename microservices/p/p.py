#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""Service P get the image price from swift if available"""

import logging
from logging.handlers import RotatingFileHandler
import pprint
import os
import sys
import io
from flask import Flask
from flask import jsonify
from flask import request
import swiftclient
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

    # Write from swift
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

    content = io.BytesIO()
    filename = id + ".txt"
    container_name = 'prices'

    config.logger.debug("Filename : %s", filename)
    try:
        resp_headers, obj_contents = conn.get_object(container_name, filename)
        content.write(obj_contents)
        data = {"status": "ok", "img": content.getvalue().decode("utf-8")}
    except swiftclient.exceptions.ClientException:
        data = {"status": "ko"}

    resp = jsonify(data)
    resp.status_code = 200
    config.logger.info("*** End processing id %s ***", id)
    add_headers(resp)
    return resp


@app.route("/shutdown", methods=["POST"])
def shutdown():
    """Shutdown server"""
    shutdown_server()
    config.logger.info("Stopping %s...", config.p.NAME)
    return "Server shutting down..."


@app.route("/", methods=["GET"])
def api_root():
    """Root url, provide service name and version"""
    data = {
        "Service": config.p.NAME,
        "Version": config.p.VERSION
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
    if (config.p.conf_file.get_p_debug().title() == 'True'):
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
    app_logfile = "p.log"

    # Change diretory to script one
    try:
        os.chdir(os.path.dirname(sys.argv[0]))
    except FileNotFoundError:
        pass

    # Define a PrettyPrinter for debugging.
    pp = pprint.PrettyPrinter(indent=4)

    # Initialise apps
    config.initialise_p()

    # Configure Flask logger
    configure_logger(app.logger, app_logfile)

    config.logger.info("Starting %s", config.p.NAME)
    app.run(port=int(config.p.conf_file.get_p_port()))
