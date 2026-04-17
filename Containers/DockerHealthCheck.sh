#!/bin/bash

echo "========== Docker Health Check =========="

# Service check
systemctl is-active --quiet docker || systemctl restart docker

# Unhealthy containers
unhealthy=$(docker ps --filter "health=unhealthy" -q)
[ ! -z "$unhealthy" ] && docker restart $unhealthy

# Exited containers
exited=$(docker ps -aq -f status=exited)
[ ! -z "$exited" ] && docker restart $exited

# Disk usage warning
usage=$(df /var/lib/docker | awk 'NR==2 {print $5}' | sed 's/%//')

if [ "$usage" -gt 80 ]; then
    echo "WARNING: Docker disk usage is above 80%"
fi

echo "========================================="