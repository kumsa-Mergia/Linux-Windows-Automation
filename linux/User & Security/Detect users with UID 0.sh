#!/bin/bash

echo "Checking for users with UID 0..."
echo "--------------------------------"

uid0_users=$(awk -F: '$3 == 0 { print $1 }' /etc/passwd)

if [ "$(echo "$uid0_users" | wc -l)" -gt 1 ]; then
    echo "  WARNING: Multiple users with UID 0 detected!"
    echo "$uid0_users"
else
    echo " Only root has UID 0"
fi
