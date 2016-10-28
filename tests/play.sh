#!/bin/bash

# Generate http requests to check app scalability

# $1 = url
# $2 = start id
# $3 = end id
# ex : play.sh http://localhost:8000/index.html

for i in $(seq $2 $3)
do
	firefox $1?id=$i\&forceplay=true &
done

wait
exit 0
