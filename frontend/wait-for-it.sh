#!/bin/sh
#   Use this script to test if a service is up and running
#   Usage: ./wait-for-it.sh host:port [-- command args]
#   Example: ./wait-for-it.sh backend:8080 -- nginx -g 'daemon off;'

TIMEOUT=15
HOST=$(echo $1 | cut -d: -f1)
PORT=$(echo $1 | cut -d: -f2)
shift

echo "Waiting for $HOST:$PORT ..."
for i in $(seq $TIMEOUT); do
    nc -z $HOST $PORT && break
    sleep 1
done

>&2 echo "$HOST:$PORT is available, starting command..."
exec "$@"

