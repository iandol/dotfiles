#!/usr/bin/env bash
set -Eeuo pipefail

mkdir -p "$HOME/bin" "$HOME/.config/systemd/user" "$HOME/.local/state/folder-sync"
ln -sfv "$(dirname "$0")/sync-folderB-ubuntu-to-mac.sh" "$HOME/bin/"
chmod +x "$HOME/bin/sync-folderB-ubuntu-to-mac.sh"
ln -sfv "$(dirname "$0")/sync-folderB-to-mac.service" "$HOME/.config/systemd/user/"
ln -sfv "$(dirname "$0")/sync-folderB-to-mac.timer" "$HOME/.config/systemd/user/"

systemctl --user daemon-reload
systemctl --user enable --now sync-folderB-to-mac.timer

echo "Installed systemd user timer: sync-folderB-to-mac.timer"
echo "Edit $HOME/bin/sync-folderB-ubuntu-to-mac.sh to set REMOTE_HOST, REMOTE_USER, SRC, DEST."
echo "View logs: journalctl --user -u sync-folderB-to-mac.service -f"
echo "Script log: tail -f $HOME/.local/state/folder-sync/folderB-ubuntu-to-mac.log"
