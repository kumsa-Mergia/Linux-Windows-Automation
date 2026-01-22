# Bulk User Creation Script

This script automates the creation of multiple Linux users from a CSV file. It also handles user groups, shell validation, password setting, and home directory permissions.

---

## Features

- Create multiple users from a CSV file.
- Automatically create missing groups and assign users to them.
- Validate shell paths and default to `/bin/bash` if missing.
- Set user passwords safely using SHA512 encryption.
- Fix home directory permissions to avoid PAM errors.
- Optional summary of created and existing users/groups.

---

## Prerequisites

- Linux system with `bash`.
- Root or sudo privileges.
- CSV file with user details.

---

## 1️⃣ Create CSV File

Create a CSV file named `users.csv` with the following format:

```csv
username,password,shell,groups
alice,Pass@123,/bin/bash,sudo
bob,Pass@123,/bin/bash,
kumsa,Pass@123,/bin/bash,devops,docker
test,Pass@123,/bin/zsh,
nova,Pass@123,/bin/bash,sudo
```

> Notes:
>
> - `username` → Linux username
> - `password` → initial password
> - `shell` → login shell (`/bin/bash`, `/bin/zsh`, etc.)
> - `groups` → comma-separated list of groups (optional). Leave empty if none.

To create it quickly from the terminal:

```bash
cat > users.csv <<EOF
username,password,shell,groups
alice,Pass@123,/bin/bash,sudo
bob,Pass@123,/bin/bash,
kumsa,Pass@123,/bin/bash,devops,docker
test,Pass@123,/bin/zsh,
nova,Pass@123,/bin/bash,sudo
EOF
```

---

## 2️⃣ Make the Script Executable

```bash
chmod +x bulk_user_create.sh
```

---

## 3️⃣ Run the Script

Run the script as root or using `sudo`:

```bash
sudo ./bulk_user_create.sh
```

The script will:

- Create users and groups if missing.
- Set passwords and fix home directory permissions.
- Display a summary of created users and groups.

---

## 4️⃣ Example Output

```
User alice created successfully
User bob created successfully
Group devops created
Group docker created
User kumsa created successfully
Shell /bin/zsh not found, using /bin/bash
User test created successfully
User nova created successfully

===== Summary =====
Users created: alice bob kumsa test nova
Existing users skipped: None
Groups created: devops docker
Existing groups skipped: sudo sudo
===================
```

---

## Notes

- By default, the script **does not force password change on first login** to avoid SSH lockout issues.
- Home directories are set to `700` permissions to ensure proper authentication.
- Passwords are encrypted using SHA512 for security.

---

## License

This script is open for personal and internal use. Modify as needed.
