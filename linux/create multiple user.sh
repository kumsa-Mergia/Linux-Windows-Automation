#!/bin/bash

USERS="naole kaleb zerihune"

# Prompt for password securely (no echo)
read -s -p "Enter password for new users: " PASSWORD
echo
read -s -p "Confirm password: " CONFIRM
echo

if [ "$PASSWORD" != "$CONFIRM" ]; then
    echo "Passwords do not match"
    exit 1
fi

for user in $USERS; do
    /usr/sbin/useradd -m -s /bin/bash "$user"
    echo "$user:$PASSWORD" | chpasswd
    passwd -e "$user"
    /usr/sbin/usermod -aG sudo "$user"
done
