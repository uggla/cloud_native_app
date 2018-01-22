#!/bin/bash -xe

set +e

for i in db web rabbit redis b i p s w w1 w2
do
  RESULT=$(docker service ls | grep $i | tr -s ' ' | cut -d' ' -f 4 | sed -E 's|([[:digit:]]+)/\1||')
  if [ ! -z "$RESULT" ]; then
      exit 1
  fi
done
