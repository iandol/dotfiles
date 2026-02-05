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
CURRENT_WS=$(aerospace list-workspaces --focused) # (kept, but no longer relied upon)
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
    local current="${1:-}"

    # Read queue safely (one ID per line) in Bash 3.2-compatible way
    local list=()
    local line=""
    while IFS= read -r line; do
        [[ -n "$line" ]] && list+=("$line")
    done < "$QUEUE_FILE"

    # Empty queue
    (( ${#list[@]} == 0 )) && { echo ""; return; }

    # If current is empty, start from the beginning
    if [[ -z "$current" ]]; then
        echo "${list[0]}"
        return
    fi

    for i in "${!list[@]}"; do
        if [[ "${list[$i]}" == "$current" ]]; then
            # Wrap around when current is the last element
            if (( i + 1 < ${#list[@]} )); then
                echo "${list[$((i+1))]}"
            else
                echo "${list[0]}"
            fi
            return
        fi
    done

    # Current wasn't in the queue -> start from first
    echo "${list[0]}"
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
    local ws
    ws="$(get_current_workspace)"
    aerospace list-windows --workspace "$ws" --format "%{window-id}" | grep -qx "$1"
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

# Returns the current workspace
get_current_workspace() {
    # In case Aerospace prints multiple lines, take the first focused workspace
    aerospace list-workspaces --focused | head -n1
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
    local ws
    ws="$(get_current_workspace)"
    aerospace move-node-to-workspace "$ws" --window-id "$id"
    ensure_floating "$id"
    aerospace focus --window-id "$id"
}

# Returns the currently visible scratchpad window on the current workspace
get_current_visible_window() {
    # Read queue line-by-line (avoid word-splitting)
    local id=""
    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        if window_in_current_ws "$id"; then
            echo "$id"
            return
        fi
    done < "$QUEUE_FILE"
    echo ""
}

# Removes windows from the queue if they are closed
cleanup_queue() {
    local tmp="$QUEUE_FILE.tmp"
    : > "$tmp"

    local id=""
    while IFS= read -r id; do
        [[ -z "$id" ]] && continue
        if window_exists "$id"; then
            echo "$id" >> "$tmp"
        fi
    done < "$QUEUE_FILE"

    mv "$tmp" "$QUEUE_FILE"
}

# Shows the next window in the FIFO queue and hides the current one
show_next_window() {
    cleanup_queue
    local current
    current=$(get_current_visible_window)

    local next=""
    next=$(queue_next_after "$current")

    # Nothing to show
    [[ -z "$next" ]] && return 0

    # If only one window (or next == current), toggle:
    # - if it's focused, hide it back to scratchpad
    # - otherwise, focus it
    if [[ -n "$current" && "$next" == "$current" ]]; then
        local focused=""
        focused=$(get_focused_window_id || true)

        if [[ -n "$focused" && "$focused" == "$current" ]]; then
            hide_window "$current"
        else
            show_window "$current"
        fi
        return 0
    fi

    [[ -n "$current" ]] && hide_window "$current"
    show_window "$next"
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
