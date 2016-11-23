# Service s

The purpose of this service is to read the redis key value store in order to know if a user has already played the game.

## Dependencies

- Python 3
- python3-redis
- Flask (python3-flask)

## Test with redis docker
```
docker run -v redisdata:/data --name myredis -d redis redis-server --appendonly yes

docker run -ti --link myredis:redis --rm redis redis-cli -h redis -p 6379
redis:6379> set key toto
OK
redis:6379> get key
"toto"
```

## Configuration file

```
[s]
port=8081
debug=True
redishost=127.0.0.1
```

* Port: Tcp port number used by the server.
* debug: Add information to log file to debug the app.
* redishost: Database host running the redis instance.

## API

### Request
GET /

### Response

Return service name and version

```json
{
    "Service": "Microservice s",
    "Version": "0.1"
}
```

## Request
GET /user/id

### Response

Return user data or not found if the id does not exist.

```json
{
    id: "1",
    status: "Fri Oct 30 20:43:12 2016"
}
```

or
```json
{
    id: "1",
    status: "not_played"
}
```


## Request
POST /shutdown

### Response

Stop the application server

