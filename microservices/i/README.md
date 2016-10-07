# Service i

The purpose of this service is to define if the player win something.
A price is ramdomly selected, and an image is generated with the id of the player.
The ourput is a json with the price and the image data.

## Dependencies

- Python 3
- python3-mysql
- Flask (python3-flask)

## Test with mariadb docker
```
docker run -d -v $PWD/dump:/docker-entrypoint-initdb.d -e MYSQL_ROOT_PASSWORD=toto -e MYSQL_DATABASE=prestashop -e MYSQL_USER=prestashop -e MYSQL_PASSWORD=prestashop1234 -p 3306:3306 mariadb

mysql -h 192.168.0.60 -u prestashop -p prestashop


```

### Python

```
>>> import _mysql
>>> db = _mysql.connect(host='192.168.0.60', user='prestashop', passwd='prestashop1234', db='prestashop')
>>> db.query("""show tables""")
>>> r=db.store_result()
>>> r
<_mysql.result object at 7f8cd6e7df98>
>>> r.fetch_row()
```

## Configuration file

```
[i]
port=8080
debug=False
```

* Port: Tcp port number used by the server.
* tmpfile: Location of the temporary price imaged.
* tempo: Latency introduced.
* debug: Add information to log file to debug the app.

## API

### Request
GET /

### Response

Return service name and version

```json
{

    "Service": "Microservice w",
    "Version": "0.1"

}
```

## Request
GET /play/id

### Response

Return price and base64 image data

```json
{

    "img": "/9j/4AAQSkZJRgABAQEASABIAAD/7RPqUGhvdG9zaG9wIDMuMAA4QklNBCUAAAAAABAAAAAAAAAAAAAAAAAAAAAAOEJJTQPtAAAAAAAQAEgAAAABAAIASAAAAAEAAjhCSU0EJgAAAAAADgAAAAAAAAAAAAA/gAAAOEJJTQQNAAAAAAAEAAAAHjh...
    "price": "usbkey.jpg"

}
```

## Request
POST /shutdown

### Response

Stop the application server

