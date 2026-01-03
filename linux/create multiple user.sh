#!/bin/bash

USERS="naole kaleb zerihune"
PASSWORD="*******"

# Create users with home directories and bash shell
for user in $USERS; do
    /usr/sbin/useradd -m -s /bin/bash "$user"
done

# Set password for each user
for user in $USERS; do
    echo "$user:$PASSWORD" | chpasswd
done

# Force password change at first login
for user in $USERS; do
    passwd -e "$user"
done

# Add users to sudo group
for user in $USERS; do
    /usr/sbin/usermod -aG sudo "$user"
done
