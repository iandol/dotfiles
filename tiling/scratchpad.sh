#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------
# Scratchpad FIFO Manager for Aerospace
#
# Features:
# 1. Send any focused window to a scratchpad workspace (FIFO queue)
# 2. Show windows from scratchpad one by one (next window appears, previous hides)
# 3. Ensures windows are floating and raised above others
# 4. Prevents duplicate entries in scratchpad
# 5. Automatically removes closed windows from the queue
# 6. Repeated 'send' on the same window removes it from the queue
# ------------------------------------------------------------

COMMAND="${1:-}"
SCRATCHPAD="S"
FIRST_WS="1"
CURRENT_WS=$(aerospace list-workspaces --focused)
QUEUE_DIR="$HOME/.config/aerospace/aerospace-scratchpad"
QUEUE_FILE="$QUEUE_DIR/queue"

mkdir -p "$QUEUE_DIR"
touch "$QUEUE_FILE"

# ------------------------------------------------------------
# Queue helpers
# ------------------------------------------------------------

# Adds a window ID to the end of the queue
queue_add() {
    echo "$1" >> "$QUEUE_FILE"
}

# Removes a window ID from the queue
queue_remove() {
    grep -vx "$1" "$QUEUE_FILE" > "$QUEUE_FILE.tmp" || true
    mv "$QUEUE_FILE.tmp" "$QUEUE_FILE"
}

# Returns all window IDs in the queue
queue_all() {
    cat "$QUEUE_FILE"
}

# Returns the first window ID in the queue
queue_first() {
    head -n1 "$QUEUE_FILE"
}

# Returns the next window ID in the queue after the given window ID
queue_next_after() {
    local current="$1"
    local list=($(queue_all))
    for i in "${!list[@]}"; do
        if [[ "${list[$i]}" == "$current" ]]; then
            if (( i + 1 < ${#list[@]} )); then
                echo "${list[$((i+1))]}"
                return
            fi
        fi
    done

    # Return empty string if current is last
    echo ""
}

# ------------------------------------------------------------
# Window helpers
# ------------------------------------------------------------

# Returns true if the window exists in Aerospace
window_exists() {
    aerospace list-windows --all --format "%{window-id}" | grep -q "$1"
}

# Returns true if the window exists on the current workspace
window_in_current_ws() {
    aerospace list-windows --workspace "$CURRENT_WS" --format "%{window-id}" | grep -q "$1"
}

# Ensures the window is floating and ignores errors if it already is
ensure_floating() {
    local id="${1:-}"

    # Do nothing if empty
    [ -z "$id" ] && return 0

    # Do nothing if window does not exist
    if ! aerospace list-windows --all --format "%{window-id}" | grep -qx "$id"; then
        return 0
    fi

    # Make floating, ignore errors
    aerospace layout floating --window-id "$id" >/dev/null 2>&1 || true

    return 0
}

# Returns the currently focused window ID
get_focused_window_id() {
    aerospace list-windows --focused --format "%{window-id}"
}

# ------------------------------------------------------------
# Scratchpad operations
# ------------------------------------------------------------

# Removes a window from the queue and returns it to the current workspace if it was hidden
unsend_window() {
    local id="$1"
    queue_remove "$id"

    # If window is currently on scratchpad workspace, move it back to first workspace
    if aerospace list-windows --workspace "$SCRATCHPAD" --format "%{window-id}" | grep -qx "$id"; then
        aerospace move-node-to-workspace "$FIRST_WS" --window-id "$id"
        ensure_floating "$id"
        aerospace focus --window-id "$id"
    fi
}

# Sends the currently focused window to the scratchpad queue
# If the window is already in the queue, remove it instead (toggle behavior)
send_focused_to_scratchpad() {
    local id
    id=$(get_focused_window_id)
    [ -z "$id" ] && return 0

    # Toggle: if window already in queue, remove it
    if queue_all | grep -qx "$id"; then
        unsend_window "$id"
        return 0
    fi

    # Otherwise, add to queue and move to scratchpad
    queue_add "$id"
    ensure_floating "$id"
    aerospace move-node-to-workspace "$SCRATCHPAD" --window-id "$id"
}

# Hides a window to the scratchpad workspace
hide_window() {
    local id="$1"
    ensure_floating "$id"
    aerospace move-node-to-workspace "$SCRATCHPAD" --window-id "$id"
}

# Shows a window from the scratchpad on the current workspace
show_window() {
    local id="$1"
    aerospace move-node-to-workspace "$CURRENT_WS" --window-id "$id"
    ensure_floating "$id"
    aerospace focus --window-id "$id"
}

# Returns the currently visible scratchpad window on the current workspace
get_current_visible_window() {
    for id in $(queue_all); do
        if window_in_current_ws "$id"; then
            echo "$id"
            return
        fi
    done
    echo ""
}

# Removes windows from the queue if they are closed
cleanup_queue() {
    local list=($(queue_all))
    > "$QUEUE_FILE"
    for id in "${list[@]}"; do
        if window_exists "$id"; then
            echo "$id" >> "$QUEUE_FILE"
        fi
    done
}

# Shows the next window in the FIFO queue and hides the current one
show_next_window() {
    cleanup_queue
    local current
    current=$(get_current_visible_window)
    local next=""
    
    if [ -z "$current" ]; then
        next=$(queue_first)
    else
        next=$(queue_next_after "$current")
    fi

    [ -n "$current" ] && hide_window "$current"
    [ -n "$next" ] && show_window "$next"
}

# ------------------------------------------------------------
# Entrypoint
# ------------------------------------------------------------

main() {
    case "$COMMAND" in
        send)
            send_focused_to_scratchpad
            ;;
        show)
            show_next_window
            ;;
        *)
            echo "Usage: $0 {send|show}"
            exit 1
            ;;
    esac
}

main
