# Service Slow : Voluntary slow service

This is a service that can be considered as a third party application. It'll be use to show that you can still scale your application, even if you didn't had the chance of optimizing every service of your architecture.
Imagine this application was developed by someone else, and you need to use it. It's slow and you'll need to integrate it in your web architecture. However we will see that it won't make it less scalable.

## Installation & prerequisites

You will need nodejs (6.0.0) and npm.

### Linux

```
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### MacOS

If you have brew:
```
curl "https://nodejs.org/dist/latest/node-${VERSION:-$(wget -qO- https://nodejs.org/dist/latest/ | sed -nE 's|.*>node-(.*)\.pkg</a>.*|\1|p')}.pkg" > "$HOME/Downloads/node-latest.pkg" && sudo installer -store -pkg "$HOME/Downloads/node-latest.pkg" -target "/"
```

or if you have homebrew

```
brew install node
```
