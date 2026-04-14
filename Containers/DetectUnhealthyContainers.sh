#!/bin/bash

echo "Checking for unhealthy containers..."

unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}")

if [ -z "$unhealthy" ]; then
    echo "No unhealthy containers"
else
    echo "Unhealthy containers detected:"
    echo "$unhealthy"

    for c in $unhealthy; do
        echo "Restarting $c..."
        docker restart $c
    done
fi