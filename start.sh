SLOW=5000 node serviceSlow/server.js &
PLAYER_SERVICE=http://127.0.0.1:8080/calculate python serviceB/server.py &
