#!/bin/bash
# --------------------------------------------------
# Linux OS Patch Status Checker
# Supports: RHEL/CentOS/Rocky/Alma & Ubuntu/Debian
# Run as root
# --------------------------------------------------

set -e

DATE=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/var/log/os_patch_status.log"
SEC_UPDATES_LOG="/var/log/security_updates.log"
REG_UPDATES_LOG="/var/log/regular_updates.log"

echo "============================================"
echo " OS PATCH STATUS REPORT - $DATE"
echo "============================================"

# Detect OS
if [ -f /etc/redhat-release ]; then
    OS="rhel"
elif [ -f /etc/debian_version ]; then
    OS="debian"
else
    echo "Unsupported OS"
    exit 1
fi

echo "🖥 Detected OS: $OS"
echo "Current Kernel: $(uname -r)"

# Patch Status Checker
echo "Checking available updates..."

if [ "$OS" = "rhel" ]; then
    yum updateinfo list security > "$SEC_UPDATES_LOG"
    yum check-update | grep -v -f <(yum updateinfo list security | awk '{print $2}') > "$REG_UPDATES_LOG" || true
    UPDATES=$(yum check-update 2>/dev/null | grep -v "^$" | wc -l)
    LAST_UPDATE=$(rpm -qa --last | head -1)
    [ $(needs-restarting -r &>/dev/null; echo $?) -eq 0 ] && REBOOT="YES" || REBOOT="NO"
else
    apt update -qq >/dev/null 2>&1
    apt list --upgradable 2>/dev/null | grep -v "Listing..." > "$REG_UPDATES_LOG"
    grep -i security "$REG_UPDATES_LOG" > "$SEC_UPDATES_LOG" || true
    grep -vi security "$REG_UPDATES_LOG" > "${REG_UPDATES_LOG}.tmp"
    mv "${REG_UPDATES_LOG}.tmp" "$REG_UPDATES_LOG"
    UPDATES=$(wc -l < "$SEC_UPDATES_LOG") # optional: total updates
    LAST_UPDATE=$(zgrep "upgrade " /var/log/apt/history.log* | tail -1)
    [ -f /var/run/reboot-required ] && REBOOT="YES" || REBOOT="NO"
fi

echo "Available Updates: $UPDATES"
echo "Security Updates Log: $SEC_UPDATES_LOG"
echo "Regular Updates Log: $REG_UPDATES_LOG"
echo "Reboot Required: $REBOOT"

# Log Summary
{
    echo "[$DATE] OS:$OS | Kernel:$(uname -r) | Security Updates: $(wc -l < "$SEC_UPDATES_LOG") | Regular Updates: $(wc -l < "$REG_UPDATES_LOG") | Reboot:$REBOOT"
    echo "Last Upgrade (trimmed): ${LAST_UPDATE:0:200}..."
} >> "$LOG_FILE"

echo "============================================"
echo "Script completed. Logs saved to:"
echo "  $LOG_FILE"
echo "  $SEC_UPDATES_LOG"
echo "  $REG_UPDATES_LOG"
echo "============================================"