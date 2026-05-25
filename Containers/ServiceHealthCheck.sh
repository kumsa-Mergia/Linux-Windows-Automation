#!/bin/bash

echo "Checking Docker service..."

if systemctl is-active --quiet docker; then
    echo "Docker service is running"
else
    echo "Docker service is NOT running. Attempting restart..."
    systemctl restart docker

    if systemctl is-active --quiet docker; then
        echo "Docker restarted successfully"
    else
        echo "Failed to restart Docker"
    fi
fi

# Check Docker CLI responsiveness
docker info > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "Docker is responsive"
else
    echo "Docker is NOT responding"
fi