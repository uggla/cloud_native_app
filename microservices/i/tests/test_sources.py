# coding=utf-8

# This is a simple unitary test to be used with CI/CD demo
import pytest
import os


def test_shutdownroute():
    # Ensure we have a shutdown route in the code source code
    # This route is needed to close the service
    root = str(pytest.config.rootdir)
    ipath = os.path.join(root, "microservices/i/i.py")

    print(ipath)
    with open(ipath, 'r') as f:
        flines = f.readlines()
        assert '@app.route("/shutdown", methods=["POST"])\n' in flines
