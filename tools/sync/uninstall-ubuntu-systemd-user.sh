#!/usr/bin/env bash
set -Eeuo pipefail
systemctl --user disable --now sync-folderB-to-mac.timer 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/sync-folderB-to-mac.service" "$HOME/.config/systemd/user/sync-folderB-to-mac.timer"
systemctl --user daemon-reload
echo "Removed systemd user timer/service. Script left in $HOME/bin for safety."
