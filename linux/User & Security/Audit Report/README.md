# Sudo Access Audit Report Script

## Overview

`sudo_access_audit_report.sh` is a Linux automation script that generates a comprehensive **sudo access audit report**.  
It helps system administrators and auditors identify **who has sudo privileges**, **how sudo is configured**, and **how sudo has been used** on a system.

The script is designed for **security audits, compliance checks, and operational reviews**.

---

## Features

The script collects and reports the following information:

- Users belonging to sudo-enabled groups (`sudo`, `wheel`)
- Active sudo rules from:
  - `/etc/sudoers`
  - `/etc/sudoers.d/`
- Detection of **passwordless sudo (NOPASSWD)** entries
- Recent sudo command usage (last 30 days)
- Logged unauthorized sudo attempts (if present)
- Hostname and report generation timestamp

---

## Supported Systems

Tested on:

- Ubuntu / Debian-based systems
- RHEL / CentOS / Rocky / Alma Linux (with minor log path differences)

> Note: The script automatically checks common authentication log locations.

---

## Requirements

- Bash shell
- `sudo` privileges
- Access to authentication logs:
  - `/var/log/auth.log` (Debian/Ubuntu)
  - `/var/log/secure` (RHEL-based)
  - or `journalctl`

---

## Installation

1. Copy the script to the target system:

   ```bash
   cp sudo_access_audit_report.sh /data/
   ```

2. Make it executable:

   ```bash
   chmod +x sudo_access_audit_report.sh
   ```

---

## Usage

Run the script with sudo privileges:

```bash
sudo ./sudo_access_audit_report.sh
```

---

## Output

The audit report is generated in `/tmp` with the following naming format:

```
/tmp/sudo_audit_<hostname>_<YYYY-MM-DD>.txt
```

### Example:

```
/tmp/sudo_audit_kumsa-test_2026-01-27.txt
```

---

## Sample Report Sections

- **Users in sudo-enabled groups**
- **/etc/sudoers entries**
- **/etc/sudoers.d entries**
- **Passwordless sudo (NOPASSWD)**
- **Recent sudo usage**
- **Unauthorized sudo attempts (if any)**

---

## Security Considerations

- The report may contain sensitive security information.
- Recommended permissions:

  ```bash
  chmod 600 /tmp/sudo_audit_*.txt
  ```

- Store or transmit reports securely.

---

## Compliance Use Cases

This script supports evidence collection for:

- ISO 27001
- SOC 2
- CIS Benchmarks
- Internal security audits
- Customer or third-party reviews

---

## Limitations

- Log retention depends on system configuration.
- Older sudo activity may not appear if logs are rotated.
- The script does not modify system configuration (read-only audit).

---

## Customization

You can extend the script to:

- Output CSV or JSON
- Email the report automatically
- Schedule periodic audits using cron
- Compare results against a baseline

---

## License

Internal use / Open use
Modify and distribute as needed.

---

## Author

Prepared for system administration and security audit purposes.
