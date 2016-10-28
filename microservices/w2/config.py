# coding=utf-8

import configparser


class Configuration(object):

    def __init__(self, configuration_file):
        self.config = configparser.ConfigParser(allow_no_value=True)
        self.config.read(configuration_file)

    def get_w2_rabbithost(self):
        return self.config.get("w2", "rabbithost")

    def get_w2_rabbitlogin(self):
        return self.config.get("w2", "rabbitlogin")

    def get_w2_rabbitpassword(self):
        return self.config.get("w2", "rabbitpassword")

    def get_w2_debug(self):
        return self.config.get("w2", "debug")
