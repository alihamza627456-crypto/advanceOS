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


# Function to check whether a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}


# Function to display CPU usage with Linux and Windows fallbacks
show_cpu_usage() {
    if command_exists top; then
        top -bn1 2>/dev/null | grep "Cpu(s)"
    elif command_exists powershell; then
        powershell -NoProfile -Command '(Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average | ForEach-Object { "CPU Load: " + $_ + "%" }'
    else
        echo "CPU usage command not available in this environment."
    fi
}


# Function to display memory usage with Linux and Windows fallbacks
show_memory_usage() {
    if command_exists free; then
        free -h
    elif command_exists powershell; then
        powershell -NoProfile -Command '$os = Get-CimInstance Win32_OperatingSystem; $total = [math]::Round($os.TotalVisibleMemorySize/1024/1024,2); $free = [math]::Round($os.FreePhysicalMemory/1024/1024,2); $used = [math]::Round($total - $free,2); Write-Output ("Total: " + $total + " GB"); Write-Output ("Used : " + $used + " GB"); Write-Output ("Free : " + $free + " GB")'
    else
        echo "Memory usage command not available in this environment."
    fi
}
