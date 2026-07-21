#!/usr/bin/env bash

# Usage: fport [-k] <port>
#   -k : kill the process(es) using the port
#   <port> : port number to check

set -euo pipefail

kill_mode=false
port=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -k)
            kill_mode=true
            shift
            ;;
        *)
            if [[ -z "$port" ]]; then
                port="$1"
                shift
            else
                echo "Error: multiple port arguments provided." >&2
                echo "Usage: fport [-k] <port>" >&2
                exit 1
            fi
            ;;
    esac
done

# Validate port
if [[ -z "$port" ]]; then
    echo "Error: no port specified." >&2
    echo "Usage: fport [-k] <port>" >&2
    exit 1
fi

if ! [[ "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
    echo "Error: '$port' is not a valid port number (1-65535)." >&2
    exit 1
fi

# Detect OS
os=$(uname -s)
pids=""

case "$os" in
    Linux)
        # Use ss on Linux
        # Extract PIDs from the "users:(("process",pid=123,fd=...)" field
        pids=$(sudo ss -ltnp "sport = :$port" 2>/dev/null | \
               awk 'NR>1 {print $6}' | \
               sed -n 's/.*pid=\([0-9]*\).*/\1/p' | \
               sort -u)
        ;;
    Darwin)
        # Use lsof on macOS
        # -t gives only PIDs (one per line), -i :port filters
        pids=$(sudo lsof -t -i :"$port" 2>/dev/null)
        ;;
    *)
        echo "Error: unsupported operating system '$os'." >&2
        echo "This script works on Linux and macOS only." >&2
        exit 1
        ;;
esac

if [[ -z "$pids" ]]; then
    echo "No process found using port $port."
    exit 0
fi

# Display process info (works on both Linux and macOS)
echo "Process(es) using port $port:"
for pid in $pids; do
    # ps options: -p PID, -o pid,user,args gives full command line
    # tail -n +2 removes the header line (macOS doesn't have --no-headers)
    ps -p "$pid" -o pid,user,args 2>/dev/null | tail -n +2 || \
        echo "  $pid  (process may have exited)"
done

# If kill mode is enabled
if $kill_mode; then
    echo
    echo "Killing process(es)..."
    for pid in $pids; do
        if kill -0 "$pid" 2>/dev/null; then
            echo "  Sending SIGTERM to PID $pid..."
            sudo kill "$pid" 2>/dev/null || echo "  Failed to kill PID $pid (permission?)"
            sleep 0.5
            if kill -0 "$pid" 2>/dev/null; then
                echo "  PID $pid still running, sending SIGKILL..."
                sudo kill -9 "$pid" 2>/dev/null || echo "  Failed to force-kill PID $pid"
            fi
        else
            echo "  PID $pid already gone."
        fi
    done
    echo "Done."
fi
