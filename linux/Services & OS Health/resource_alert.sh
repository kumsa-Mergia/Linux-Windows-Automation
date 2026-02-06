#!/bin/bash

# =========================
# CONFIGURATION
# =========================
CPU_THRESHOLD=80        # CPU usage percentage
MEM_THRESHOLD=70        # Memory usage percentage
LOG_FILE="/var/log/resource_alert.log"
ALERT_EMAIL="admin@example.com"   # leave empty to disable email

DATE=$(date '+%Y-%m-%d %H:%M:%S')

# =========================
# CHECK CPU USAGE
# =========================
HIGH_CPU=$(ps -eo pid,comm,%cpu --sort=-%cpu | awk -v cpu="$CPU_THRESHOLD" 'NR>1 && $3>cpu')

# =========================
# CHECK MEMORY USAGE
# =========================
HIGH_MEM=$(ps -eo pid,comm,%mem --sort=-%mem | awk -v mem="$MEM_THRESHOLD" 'NR>1 && $3>mem')

# =========================
# ALERT FUNCTION
# =========================
send_alert() {
    MESSAGE="$1"

    echo "[$DATE] $MESSAGE" >> "$LOG_FILE"

    if [[ -n "$ALERT_EMAIL" ]]; then
        echo "$MESSAGE" | mail -s "Linux Resource Alert" "$ALERT_EMAIL"
    fi
}

# =========================
# PROCESS ALERTS
# =========================
if [[ -n "$HIGH_CPU" ]]; then
    send_alert "HIGH CPU USAGE DETECTED:\n$HIGH_CPU"
fi

if [[ -n "$HIGH_MEM" ]]; then
    send_alert "HIGH MEMORY USAGE DETECTED:\n$HIGH_MEM"
fi
#!/bin/bash

# =========================
# CONFIGURATION
# =========================
CPU_THRESHOLD=80
MEM_THRESHOLD=70
LOG_FILE="/var/log/resource_alert.log"
ALERT_EMAIL=""   # keep empty to disable email

DATE=$(date '+%Y-%m-%d %H:%M:%S')
ALERT_FOUND=0

echo "-------------------------------------"
echo " OS Resource Health Check"
echo " Time: $DATE"
echo "-------------------------------------"

# =========================
# CHECK CPU USAGE
# =========================
HIGH_CPU=$(ps -eo pid,comm,%cpu --sort=-%cpu | awk -v cpu="$CPU_THRESHOLD" 'NR>1 && $3>cpu')

if [[ -n "$HIGH_CPU" ]]; then
    ALERT_FOUND=1
    echo "**** HIGH CPU USAGE DETECTED:"
    echo "$HIGH_CPU"
    echo "[$DATE] HIGH CPU USAGE DETECTED:" >> "$LOG_FILE"
    echo "$HIGH_CPU" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
else
    echo "**** CPU usage is normal"
fi

# =========================
# CHECK MEMORY USAGE
# =========================
HIGH_MEM=$(ps -eo pid,comm,%mem --sort=-%mem | awk -v mem="$MEM_THRESHOLD" 'NR>1 && $3>mem')

if [[ -n "$HIGH_MEM" ]]; then
    ALERT_FOUND=1
    echo "**** HIGH MEMORY USAGE DETECTED:"
    echo "$HIGH_MEM"
    echo "[$DATE] HIGH MEMORY USAGE DETECTED:" >> "$LOG_FILE"
    echo "$HIGH_MEM" >> "$LOG_FILE"
    echo >> "$LOG_FILE"
else
    echo "**** Memory usage is normal"
fi

# =========================
# FINAL STATUS
# =========================
if [[ "$ALERT_FOUND" -eq 0 ]]; then
    echo "**** System Status: HEALTHY"
else
    echo "**** System Status: ATTENTION REQUIRED"
fi

echo "-------------------------------------"