#!/bin/bash

# Number of inactive days
INACTIVE_DAYS=90
CURRENT_DATE=$(date +%s)

# Get users with UID >= 1000 (regular users)
awk -F: '$3 >= 1000 {print $1}' /etc/passwd | while read -r USER
do
    # Get last login in seconds since epoch
    LAST_LOGIN=$(lastlog -u "$USER" | awk 'NR==2 {print $4,$5,$6,$7}')

    # Skip users who never logged in
    if [[ "$LAST_LOGIN" == "**Never logged in**" || -z "$LAST_LOGIN" ]]; then
        continue
    fi

    LAST_LOGIN_DATE=$(date -d "$LAST_LOGIN" +%s 2>/dev/null)

    # Skip if date parsing fails
    [[ -z "$LAST_LOGIN_DATE" ]] && continue

    INACTIVE_SECONDS=$((CURRENT_DATE - LAST_LOGIN_DATE))
    INACTIVE_DAYS_CALC=$((INACTIVE_SECONDS / 86400))

    if [[ "$INACTIVE_DAYS_CALC" -ge "$INACTIVE_DAYS" ]]; then
        echo "Locking user: $USER (inactive for $INACTIVE_DAYS_CALC days)"
        usermod -L "$USER"
    fi
done