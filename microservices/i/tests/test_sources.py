# coding=utf-8

# This is a simple unitary test to be used with CI/CD demo


def test_shutdownroute():
    # Ensure we have a shutdown route in the code source code
    # This route is needed to close the service
    with open("../i.py", 'r') as f:
        flines = f.readlines()
        assert '@app.route("/shutdown", methods=["POST"])\n' in flines
