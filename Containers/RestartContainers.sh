#!/bin/bash

echo "Checking stopped containers..."

stopped=$(docker ps -aq -f status=exited)

for container in $stopped; do
    name=$(docker inspect --format='{{.Name}}' $container | sed 's/\///')

    echo "Restarting container: $name"
    docker restart $container
done