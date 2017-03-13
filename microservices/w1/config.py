# coding=utf-8

import configparser


class Configuration(object):

    def __init__(self, configuration_file):
        self.config = configparser.ConfigParser(allow_no_value=True)
        self.config.read(configuration_file)

    def get_w1_rabbithost(self):
        return self.config.get("w1", "rabbithost")

    def get_w1_rabbitlogin(self):
        return self.config.get("w1", "rabbitlogin")

    def get_w1_rabbitpassword(self):
        return self.config.get("w1", "rabbitpassword")

    def get_w1_debug(self):
        return self.config.get("w1", "debug")

    def get_w1_redishost(self):
        return self.config.get("w1", "redishost")

    def get_w1_imagestore(self):
        return self.config.get("w1", "imagestore")

    def get_w1_os_parameters(self):
        parameters = {}
        parameters.update(
            {"os_authurl": self.config.get("w1", "os_authurl")})
        parameters.update(
            {"os_auth_version": self.config.get("w1", "os_auth_version")})
        parameters.update(
            {"os_user": self.config.get("w1", "os_user")})
        parameters.update(
            {"os_key": self.config.get("w1", "os_key")})
        parameters.update(
            {"os_tenant_name": self.config.get("w1", "os_tenant_name")})
        return parameters
