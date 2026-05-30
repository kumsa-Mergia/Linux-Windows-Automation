# VM Reboot Analysis Scripts - Complete Guide

## What's New

Your original script only analyzed the **last boot**. These improved versions provide:

✅ **Last 10 reboots** - Full history  
✅ **Exact timestamps** - When each reboot occurred  
✅ **Username + UID** - Who initiated the reboot  
✅ **Exact reason** - Why the reboot happened  
✅ **Detailed context** - Specific command/error details  

---

## Two Versions Available

### 1. **reboot_analysis_simple.sh** ⭐ RECOMMENDED
- **Best for**: Regular sysadmins, quick troubleshooting
- Clean tabular output
- Shows all info in one line per reboot
- Easy to read and parse
- Fast execution

### 2. **reboot_analysis.sh** (Full Featured)
- **Best for**: Deep forensics, complex environments
- Verbose detailed output
- More aggressive pattern matching
- Better for edge cases
- Includes system summary

---

## Setup & Usage

### Make Executable
```bash
chmod +x reboot_analysis_simple.sh
chmod +x reboot_analysis.sh
```

### Run the Script
```bash
# Simple version (recommended)
./reboot_analysis_simple.sh

# Full version
./reboot_analysis.sh
```

### Run as Root (Optional, for more detail)
```bash
sudo ./reboot_analysis_simple.sh
```

---

## Example Output

```
======================================
  VM REBOOT ROOT CAUSE ANALYSIS
  Last 10 Reboots with Details
======================================

Boot# | Timestamp                 | Reason               | User:UID        | Details
------|---------------------------|----------------------|-----------------|----------------------------
Boot#1 | May 24 15:32:14          | MANUAL REBOOT        | admin:1000      | COMMAND=sudo reboot
Boot#2 | May 24 10:15:22          | CLEAN SHUTDOWN       | root:0          | Graceful system shutdown completed
Boot#3 | May 24 08:47:50          | OUT OF MEMORY        | kernel:0        | OOM Killer: killed httpd
Boot#4 | May 23 22:33:01          | WATCHDOG TIMEOUT     | kernel:0        | Watchdog timeout
Boot#5 | May 23 18:15:44          | MANUAL REBOOT        | deploy:1001     | COMMAND=sudo systemctl reboot
Boot#6 | May 23 12:08:15          | KERNEL PANIC         | kernel:0        | Kernel panic detected
Boot#7 | May 23 05:22:33          | SERVICE TIMEOUT      | systemd:0       | Init timeout
Boot#8 | May 22 20:11:50          | UNEXPECTED SHUTDOWN  | unknown:unknown | No graceful shutdown sequence found
Boot#9 | May 22 14:45:22          | MANUAL REBOOT        | admin:1000      | COMMAND=shutdown -r now
Boot#10| May 22 09:18:05          | CLEAN SHUTDOWN       | root:0          | Graceful system shutdown completed

======================================
SUMMARY
======================================
Current User: root:0
Current Uptime: 5 hours, 12 minutes
Hostname: prod-server-01
Kernel: 5.15.0-107-generic
```

---

## Reboot Reasons Explained

| Reason | Cause | Action Needed |
|--------|-------|---------------|
| **MANUAL REBOOT** | Admin explicitly rebooted via `sudo reboot` or `systemctl reboot` | Check audit logs if unauthorized |
| **CLEAN SHUTDOWN** | Graceful shutdown completed normally | No action, expected behavior |
| **KERNEL PANIC** | Kernel fatal error (bug, hardware issue) | Check hardware, kernel logs, update drivers |
| **WATCHDOG TIMEOUT** | System became unresponsive, watchdog forced reboot | Check for hung processes, high load |
| **OUT OF MEMORY** | System ran out of RAM, OOM killer terminated processes | Add memory, check app memory leaks |
| **SERVICE TIMEOUT** | Critical service failed to start/stop in time | Check service logs, increase timeouts |
| **UNEXPECTED SHUTDOWN** | No graceful shutdown detected, possible power loss | Check power supply, PDU, UPS logs |
| **UNKNOWN** | Insufficient log evidence | Increase journalctl retention or check hardware |

---

## Key Improvements Over Original Script

### ❌ Original Script Issues:
```bash
# Only looked at last boot
LOG=$(journalctl -b -1 --no-pager)

# Poor user extraction - only root:0
WHO=$(echo "$MANUAL_CMD" | awk -F'sudo\\[' '{print $2}' | awk -F']' '{print $1}')

# Limited to one reboot analysis
```

### ✅ New Script Improvements:

1. **Loop Through 10 Boots**
```bash
journalctl --list-boots -n 10  # Gets last 10
# Then analyze each: journalctl -b "$BOOT_ID"
```

2. **Extract Real Username + UID**
```bash
uid=$(echo "$sudo_line" | grep -oP 'uid=\K[0-9]+')
uname=$(id -un "$uid")  # Convert UID to username
USER="$uname:$uid"
```

3. **Better Cause Detection**
- Checks kernel logs for panics/crashes
- Detects watchdog timeouts
- Finds OOM kill patterns
- Identifies service timeouts
- Distinguishes clean vs dirty shutdown

4. **Exact Timestamps**
```bash
boot_time=$(journalctl -b "$boot_id" --no-pager -n 1 | awk '{print $1, $2, $3}')
```

5. **Better Output Formatting**
- Color-coded for easy reading
- Tabular format for all 10 boots at once
- System summary at bottom

---

## Troubleshooting

### No output or error?

**Problem**: `journalctl: command not found`  
**Solution**: Install systemd-journal-remote or use `/var/log/messages`

**Problem**: Permissions denied  
**Solution**: Run with `sudo ./reboot_analysis_simple.sh`

**Problem**: Only shows 1-2 boots  
**Solution**: Wait for more boots to accumulate, or check journal retention:
```bash
journalctl --disk-usage
journalctl --vacuum-time=30d  # Keep 30 days
```

---

## Customization

### Show Last 20 Boots Instead of 10
Edit line with `--list-boots -n 10` → `--list-boots -n 20`

### Ignore Certain Users
Add filter before analysis:
```bash
if [[ "$USER" == "backup:1002" ]]; then
    continue
fi
```

### Add Custom Reboot Patterns
In the analyze_reboot function, add new elif block:
```bash
elif echo "$SYSLOG" | grep -qi "YOUR_PATTERN"; then
    REASON="YOUR_CUSTOM_REASON"
```

### Export to CSV
Pipe output through awk:
```bash
./reboot_analysis_simple.sh | grep -v "^-" | awk -F'|' '{gsub(/^[ \t]+|[ \t]+$/, ""); print $2","$3","$4","$5}' > reboots.csv
```

---

## Dependencies

- `bash` (4.0+)
- `journalctl` (systemd)
- `grep`, `awk`, `sed` (standard utilities)
- Linux kernel with systemd journal support

Most modern Linux distros have all these.

---

## Performance

- **Execution Time**: 1-3 seconds for 10 boots
- **Journal Size**: Depends on journalctl retention (default: 10% of /var)
- **No Impact**: Read-only, doesn't modify anything

---

## Use Cases

1. **Post-Incident Analysis**
```bash
./reboot_analysis_simple.sh > incident_report.txt
```

2. **Monitor Reboot Patterns**
```bash
# Cron job to log reboots monthly
0 0 1 * * /path/to/reboot_analysis_simple.sh >> /var/log/reboot_analysis.log
```

3. **Automated Alerting**
```bash
if ./reboot_analysis_simple.sh | grep -q "KERNEL PANIC"; then
    send_alert "Kernel panic detected!"
fi
```

4. **Audit Trail**
```bash
# Who rebooted the server and when?
./reboot_analysis_simple.sh | grep "MANUAL"
```

---

## Next Steps

1. Download one of the scripts
2. Make it executable: `chmod +x script_name.sh`
3. Run it: `./script_name.sh`
4. Bookmark for future troubleshooting

For more details on a specific reboot:
```bash
journalctl -b 0 -p alert..emerg  # Just errors/alerts
journalctl -b 0 --grep="pattern" # Search for pattern
journalctl -b 0 -u service_name  # Specific service logs
```

---

## Questions?

Check your system's journal retention:
```bash
journalctl --status
```

Verify journalctl has data:
```bash
journalctl --list-boots
journalctl -n 20  # Last 20 lines
```
