#!/bin/bash

# Resolve script directory so paths are stable regardless of launch location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directory where accepted assignment files will be stored
SUBMISSION_DIR="$SCRIPT_DIR/submissions"

# Common log file for both file submissions and login monitoring
LOG_FILE="$SCRIPT_DIR/submission_log.txt"

# Ensure required directory and log file exist
mkdir -p "$SUBMISSION_DIR"
touch "$LOG_FILE"

# Function to log actions with timestamps
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}


# Function to check whether a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Normalize Windows-style paths (e.g., D:\folder\file.pdf) for Bash checks
normalize_input_path() {
    local input_path="$1"

    if command_exists cygpath; then
        cygpath -u "$input_path" 2>/dev/null || printf '%s' "$input_path"
    elif [[ "$input_path" =~ ^[A-Za-z]:\\ ]]; then
        local drive_letter="${input_path:0:1}"
        local remaining_path="${input_path:2}"
        remaining_path="${remaining_path//\\//}"
        printf '/%s/%s' "$(echo "$drive_letter" | tr 'A-Z' 'a-z')" "$remaining_path"
    else
        printf '%s' "$input_path"
    fi
}
