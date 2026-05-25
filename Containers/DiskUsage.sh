#!/bin/bash

echo "Docker Volume Disk Usage"

docker system df -v

echo ""
echo "Top 10 Largest Volumes:"

du -sh /var/lib/docker/volumes/* 2>/dev/null | sort -rh | head -10