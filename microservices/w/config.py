# coding=utf-8

import configparser

# Initialise global variable
logger = None
w = None


def initialise_w():
    """Define w global object so it can be called from anywhere."""
    global w
    w = W()


class W(object):
    def __init__(self):
        self.NAME = "Microservice w"
        self.VERSION = "0.1"
        #
        # Configuration file
        self.conf_file = wConfiguration("w.conf")


class wConfiguration(object):

    def __init__(self, configuration_file):
        self.config = configparser.ConfigParser(allow_no_value=True)
        self.config.read(configuration_file)

    def get_w_port(self):
        return self.config.get("w", "port")
