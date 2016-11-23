# Service i

The purpose of this service is to read the prestashop database and especially ps_customer table to retrieve user data
for a specific id.

## Dependencies

- Python 3
- Flask (python3-flask)
- libmysqlclient-dev
- python3-pip
- pip3 install mysqlclient

## Test with mariadb docker
```
docker run -d -v $PWD/dump:/docker-entrypoint-initdb.d -e MYSQL_ROOT_PASSWORD=toto -e MYSQL_DATABASE=prestashop -e MYSQL_USER=prestashop -e MYSQL_PASSWORD=prestashop1234 -p 3306:3306 mariadb

mysql -h 127.0.0.1 -u prestashop -p prestashop
```

### Python

```
>>> import _mysql
>>> db = _mysql.connect(host='127.0.0.1', user='prestashop', passwd='prestashop1234', db='prestashop')
>>> db.query("""show tables""")
>>> r=db.store_result()
>>> r
<_mysql.result object at 7f8cd6e7df98>
>>> r.fetch_row()
```

### Queries
```
select id_customer, firstname, lastname, email from ps_customer;
```
```
select id_customer, firstname, lastname, email from ps_customer where id_customer=1;
```

## Configuration file

```
[i]
port=8080
debug=True
dbhost=127.0.0.1
dbuser=prestashop
dbpasswd=prestashop1234
dbname=prestashop
```

* Port: Tcp port number used by the server.
* debug: Add information to log file to debug the app.
* dbhost: Database host running the mariadb instance.
* dbuser: User name to connect to the database.
* dbpasswd: Password to connect to the database.
* dbname: Database name.

## API

### Request
GET /

### Response

Return service name and version

```json
{
    "Service": "Microservice i",
    "Version": "0.1"
}
```

## Request
GET /user/id

### Response

Return user data or not found if the id does not exist.

```json
{
    "email": "pub@prestashop.com",
    "firstname": "John",
    "id": "1",
    "lastname": "DOE"
}
```

or
```json
{
    "id": "Not found"
}
```


## Request
POST /shutdown

### Response

Stop the application server

