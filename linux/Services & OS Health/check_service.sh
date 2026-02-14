#!/bin/bash
# Script: check_services.sh
# Purpose: Verify critical services are running

# List of critical services to monitor
SERVICES=("ssh" "chrony" "docker" "node_exporter")   # Add or remove your services here

# Log file for recording service status
LOGFILE="/var/log/service_check.log"

echo "Service Check Report - $(date)" | tee -a "$LOGFILE"
echo "----------------------------------------" | tee -a "$LOGFILE"

for service in "${SERVICES[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "[OK] $service is running" | tee -a "$LOGFILE"
    else
        echo "[ALERT] $service is NOT running" | tee -a "$LOGFILE"
        # Uncomment the next line to try restarting the service automatically
        # systemctl restart "$service" && echo "[INFO] $service restarted successfully" | tee -a "$LOGFILE"
    fi
done

echo "----------------------------------------" | tee -a "$LOGFILE"