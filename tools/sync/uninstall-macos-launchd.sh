#!/usr/bin/env bash
set -Eeuo pipefail
plist="$HOME/Library/LaunchAgents/com.ian.sync.folderA-to-ubuntu.plist"
launchctl bootout "gui/$(id -u)" "$plist" 2>/dev/null || true
rm -f "$plist"
echo "Removed macOS LaunchAgent. Script left in $HOME/bin for safety."
