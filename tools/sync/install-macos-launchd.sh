#!/usr/bin/env bash
set -Eeuo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir -p "$HOME/bin" "$HOME/Library/LaunchAgents" "$HOME/Library/Logs/folder-sync"
ln -sfv "$SCRIPT_DIR/sync-folderA-mac-to-ubuntu.sh" "$HOME/bin/"
chmod +x "$HOME/bin/sync-folderA-mac-to-ubuntu.sh"

plist_src="$SCRIPT_DIR/com.ian.sync.folderA-to-ubuntu.plist"
plist_dst="$HOME/Library/LaunchAgents/com.ian.sync.folderA-to-ubuntu.plist"
ln -sfv "$plist_src" "$plist_dst"

# Replace /Users/ian with the current home directory if needed.
perl -0pi -e "s#/Users/ian#$ENV{HOME}#g" "$plist_dst"

launchctl bootout "gui/$(id -u)" "$plist_dst" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$plist_dst"
launchctl enable "gui/$(id -u)/com.ian.sync.folderA-to-ubuntu"
launchctl kickstart -k "gui/$(id -u)/com.ian.sync.folderA-to-ubuntu"

echo "Installed macOS LaunchAgent: $plist_dst"
echo "Edit $HOME/bin/sync-folderA-mac-to-ubuntu.sh to set REMOTE_HOST, REMOTE_USER, SRC, DEST."
echo "View logs: tail -f $HOME/Library/Logs/folder-sync/folderA-launchd.out.log"
