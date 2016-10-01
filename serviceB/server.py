#! /usr/bin/python
# -*- coding:utf-8 -*-

from flask import Flask, request
from PIL import Image
from StringIO import StringIO
import requests
import os

app = Flask(__name__)

# This route is supposed to lauch the game
# There is few step in this demo that the handler of this route will do :
# 1. Run the game which is supposed to be slow on an external service (HTTP request)
# 2. Change the status of the player in our internal database by querying (HTTP) serviceS
# 3. Generate the corresponding image (thanks to the response of the HTTP gaming request)
# 4. Send an message using rabbitMQ on a service that will listen to this queue for the purpose of notifying the user by mail.

def change_player_status():
    print("changing player status")
    return 0

def notify_user():
    print("notifying user")
    return 0

def genere_image():
    print("generating image")
    r = requests.get(os.getenv('PLAYER_SERVICE'))
    mon_image = StringIO()
    print("image color: " + r.json()["color"]);
    Image.new("RGB", (300,300), r.json()["color"]).save(mon_image, 'BMP')
    res = Flask.make_response(app, mon_image.getvalue())
    res.mimetype = "image/bmp"  # à la place de "text/html"
    return res

@app.route('/play/<id>', methods=['POST'])
def index(id):
    print("request received: route {}").format(request.path)
    change_player_status()
    res = genere_image()
    notify_user()
    return res

if __name__ == '__main__':
    app.run(debug=True)
