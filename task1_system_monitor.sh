# Resolve the script directory so output paths are stable regardless of launch location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# File used to store all system administration logs
LOG_FILE="$SCRIPT_DIR/system_monitor_log.txt"

# Directory where archived log files will be stored
ARCHIVE_DIR="$SCRIPT_DIR/ArchiveLogs"

# Critical PIDs that should not be killed
# PID 1 is init/systemd, $$ is the current shell script process
CRITICAL_PIDS="1 $$"

# Function to write actions into the log file with a timestamp
log_action() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}
