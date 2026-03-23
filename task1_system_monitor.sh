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


# Function to return directory size in bytes with fallback
get_dir_size_bytes() {
    local dir="$1"

    if du -sb "$dir" >/dev/null 2>&1; then
        du -sb "$dir" 2>/dev/null | awk '{print $1}'
    else
        du -sk "$dir" 2>/dev/null | awk '{print $1 * 1024}'
    fi
}


# Function to check process existence with Linux and Windows fallbacks
process_exists() {
    local pid="$1"

    if ps -p "$pid" >/dev/null 2>&1; then
        return 0
    elif command_exists powershell; then
        powershell -NoProfile -Command "if (Get-Process -Id $pid -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }" >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}


# Function to terminate a process with Linux and Windows fallbacks
terminate_pid() {
    local pid="$1"

    if kill "$pid" >/dev/null 2>&1; then
        return 0
    elif command_exists powershell; then
        powershell -NoProfile -Command "try { Stop-Process -Id $pid -Force -ErrorAction Stop; exit 0 } catch { exit 1 }" >/dev/null 2>&1
        return $?
    else
        return 1
    fi
}

# Function to display current CPU and memory usage
show_system_usage() {
    echo "===== Current CPU Usage ====="
    show_cpu_usage

    echo
    echo "===== Current Memory Usage ====="
    show_memory_usage

    log_action "Displayed CPU and memory usage"
}


# Function to display the top 10 memory consuming processes
show_top_processes() {
    echo "===== Top 10 Memory Consuming Processes ====="

    # Prefer GNU/Linux ps output when available.
    if ps -eo pid,user,%cpu,%mem,comm --sort=-%mem >/dev/null 2>&1; then
        ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 11
    # Fallback for Windows/Git Bash environments where ps options differ.
    elif command_exists powershell; then
        powershell -NoProfile -Command 'Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 @{Name="PID";Expression={$_.Id}}, @{Name="Name";Expression={$_.ProcessName}}, @{Name="MemoryMB";Expression={[math]::Round($_.WorkingSet64/1MB,2)}} | Format-Table -AutoSize'
    else
        echo "Cannot list top memory processes in this environment."
    fi

    log_action "Displayed top 10 memory consuming processes"
}
