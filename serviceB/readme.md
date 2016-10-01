# Service B : Most complex service of this architecture

Here you'll find a python webapp that is doing:
* HTTP requests
* Image generation
* Object storing
* Messaging

It will communicate with all of the other webapps/services in this stack.

## Installation & prerequisites

You will need python (2.7) and pip.
Python libraries used are:
* flask
* Pillow

### Linux

```
sudo apt-get install python python-pip
sudo pip install flask
sudo pip install Pillow
sudo pip install requests
```

### MacOS

```
curl -O http://python-distribute.org/distribute_setup.py
python distribute_setup.py
easy_install pip
pip install flask
pip install Pillow
pip install requests
```

or if you have homebrew

```
brew install python
pip install flask
pip install Pillow
pip install requests
```
