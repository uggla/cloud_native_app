# coding=utf-8

import configparser

# Initialise global variable
logger = None
i = None


def initialise_i():
    """Define i global object so it can be called from anywhere."""
    global i
    i = I()


class I(object):
    def __init__(self):
        self.NAME = "Microservice i"
        self.VERSION = "0.1"
        #
        # Configuration file
        self.conf_file = iConfiguration("i.conf")


class iConfiguration(object):

    def __init__(self, configuration_file):
        self.config = configparser.ConfigParser(allow_no_value=True)
        self.config.read(configuration_file)

    def get_i_port(self):
        return self.config.get("i", "port")

    def get_i_debug(self):
        return self.config.get("i", "debug")

    def get_i_dbparameters(self):
        parameters = {}
        parameters.update({"dbhost": self.config.get("i", "dbhost")})
        parameters.update({"dbuser": self.config.get("i", "dbuser")})
        parameters.update({"dbpasswd": self.config.get("i", "dbpasswd")})
        parameters.update({"dbname": self.config.get("i", "dbname")})
        return parameters
