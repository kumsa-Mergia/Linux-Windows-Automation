#!/bin/bash

CSV_FILE="users.csv"
CREATED_USERS=()
CREATED_GROUPS=()
EXISTING_USERS=()
EXISTING_GROUPS=()

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

# Read CSV (skip header)
while IFS=',' read -r username password shell groups; do
    # Trim whitespace
    username=$(echo "$username" | xargs)
    password=$(echo "$password" | xargs)
    shell=$(echo "$shell" | xargs)
    groups=$(echo "$groups" | xargs)

    [[ -z "$username" ]] && continue

    # Skip existing users
    if id "$username" &>/dev/null; then
        echo "User $username already exists, skipping..."
        EXISTING_USERS+=("$username")
        continue
    fi

    # Validate shell
    if [[ ! -x "$shell" ]]; then
        echo "Shell $shell not found, using /bin/bash"
        shell="/bin/bash"
    fi

    # Create user
    useradd -m -s "$shell" "$username"

    # Handle groups
    if [[ -n "$groups" ]]; then
        IFS=',' read -ra GROUP_LIST <<< "$groups"
        for grp in "${GROUP_LIST[@]}"; do
            grp=$(echo "$grp" | xargs)
            [[ -z "$grp" ]] && continue

            if ! getent group "$grp" >/dev/null; then
                groupadd "$grp"
                CREATED_GROUPS+=("$grp")
                echo "Group $grp created"
            else
                EXISTING_GROUPS+=("$grp")
            fi

            usermod -aG "$grp" "$username"
        done
    fi

    # Set password safely
    echo "$username:$password" | chpasswd --crypt-method SHA512

    # Fix home directory permissions to avoid PAM errors
    chmod 700 "/home/$username"

    # Allow immediate password change
    chage -m 0 "$username"          # min days = 0
    chage -M 90 "$username"      # max days = expire after 90 days
    
    # Optional: force change at first login if desired
    # chage -d 0 "$username"

    CREATED_USERS+=("$username")
    echo "User $username created successfully"

done < <(tail -n +2 "$CSV_FILE")

# Print summary
echo
echo "===== Summary ====="
echo "Users created: ${CREATED_USERS[*]:-None}"
echo "Existing users skipped: ${EXISTING_USERS[*]:-None}"
echo "Groups created: ${CREATED_GROUPS[*]:-None}"
echo "Existing groups skipped: ${EXISTING_GROUPS[*]:-None}"
echo "==================="
