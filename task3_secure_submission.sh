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
