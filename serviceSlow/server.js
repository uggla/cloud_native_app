'use strict';

const express = require('express');
var app       = express();
const server  = require('http').Server(app);

const responseTime = process.env.SLOW | 0; // time (milliseconds) to give the answer back on the route /calculate

app.set('port', process.env.PORT | 8080);

app.get('/calculate', (req, res) => {
  setTimeout(() => {
    res.status(200).json({
      color: "#" + Math.floor(Math.random()*16777215).toString(16) 
    });
  }, responseTime);
});

server.listen(app.get('port'), (err) => {
  if (err) throw err;
  console.log('server listening on port: ' + app.get('port'));
});
