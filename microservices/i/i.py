#!/usr/bin/env python3
# -*- coding: utf-8 -*-


"""Service I get identification from the user"""

import logging
from logging.handlers import RotatingFileHandler
import pprint
import os
import sys
from flask import Flask
from flask import jsonify
from flask import request
import _mysql
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

    dbparameters = config.i.conf_file.get_i_dbparameters()
    db = _mysql.connect(host=dbparameters["dbhost"],
                        user=dbparameters["dbuser"],
                        passwd=dbparameters["dbpasswd"],
                        db=dbparameters["dbname"])

    db.query("""select id_customer,
                firstname,
                lastname,
                email
                from ps_customer where id_customer=""" + id + ";")

    r = db.store_result()

    data = {}
    if r.num_rows():
        lines = r.fetch_row()
        config.logger.debug("User data: %s", lines)
        data.update({"id": id,
                     "firstname": lines[0][1].decode('utf-8'),
                     "lastname": lines[0][2].decode('utf-8'),
                     "email": lines[0][3].decode('utf-8')})
    else:
        config.logger.debug("User id: %s not found", id)
        data.update({"id": "Not found"})

    resp = jsonify(data)
    resp.status_code = 200
    config.logger.info("*** End processing id %s ***", id)
    add_headers(resp)
    return resp


@app.route("/shutdown", methods=["POST"])
def shutdown():
    """Shutdown server"""
    shutdown_server()
    config.logger.info("Stopping %s...", config.i.NAME)
    return "Server shutting down..."


@app.route("/", methods=["GET"])
def api_root():
    """Root url, provide service name and version"""
    data = {
        "Service": config.i.NAME,
        "Version": config.i.VERSION
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
    if (config.i.conf_file.get_i_debug().title() == 'True'):
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
    app_logfile = "i.log"

    # Change diretory to script one
    try:
        os.chdir(os.path.dirname(sys.argv[0]))
    except FileNotFoundError:
        pass

    # Define a PrettyPrinter for debugging.
    pp = pprint.PrettyPrinter(indent=4)

    # Initialise apps
    config.initialise_i()

    # Configure Flask logger
    configure_logger(app.logger, app_logfile)

    config.logger.info("Starting %s", config.i.NAME)
    app.run(port=int(config.i.conf_file.get_i_port()))
