#!/bin/bash

LOG="/var/log/auth.log"
THRESHOLD=5
LOCK_TIME=900   # 15 minutes

grep "Failed password" "$LOG" | awk '{print $(NF-5)}' | sort | uniq -c | while read count user
do
    if [ "$count" -ge "$THRESHOLD" ]; then
        if ! passwd -S "$user" | grep -q "L"; then
            usermod -L "$user"
            echo "$(date): User $user locked after $count failed attempts" >> /var/log/user_lock.log

            # Auto unlock
            (
              sleep "$LOCK_TIME"
              usermod -U "$user"
              echo "$(date): User $user unlocked" >> /var/log/user_lock.log
            ) &
        fi
    fi
done
