#!/bin/bash

# Generate http requests to check b service scalability

# $1 = url
# $2 = start id
# $3 = end id
# ex : time b.sh http://localhost:8082 1 10

err=0

for i in $(seq $2 $3)
do
	curl $1/srvb/user/$i
	if [ $? -ne 0 ]; then
		err=1
	fi
done

exit $err
