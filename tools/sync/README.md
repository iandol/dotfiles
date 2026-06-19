# One-way folder sync templates: macOS <-> Ubuntu 24.04

This bundle implements two independent one-way mirrors:

1. `folderA`: macOS source -> Ubuntu destination, scheduled by macOS `launchd`.
2. `folderB`: Ubuntu source -> macOS destination, scheduled by Ubuntu `systemd --user`.

The scripts use `rsync` over SSH. They default to mirroring deletions (`--delete`) but also keep deleted/replaced destination files in timestamped backup folders for 30 days.

## 1. Install dependencies

Ubuntu:

```bash
sudo apt update
sudo apt install rsync openssh-client
```

macOS:

```bash
brew install rsync
```

The built-in macOS rsync may work, but it is old. Homebrew rsync is recommended.

## 2. Configure and dry-run macOS -> Ubuntu

On macOS:

```bash
./install-macos-launchd.sh
nano ~/bin/sync-folderA-mac-to-ubuntu.sh
DRY_RUN=1 ~/bin/sync-folderA-mac-to-ubuntu.sh
```

Edit these variables in the script:

```bash
REMOTE_USER="ian"
REMOTE_HOST="ubuntu-hostname-or-ip"
SRC="$HOME/folderA/"
DEST="/home/ian/folderA/"
```

After the dry-run looks correct:

```bash
~/bin/sync-folderA-mac-to-ubuntu.sh
```

Logs:

```bash
tail -f ~/Library/Logs/folder-sync/folderA-mac-to-ubuntu.log
```

## 3. Configure and dry-run Ubuntu -> macOS

On Ubuntu:

```bash
./install-ubuntu-systemd-user.sh
nano ~/bin/sync-folderB-ubuntu-to-mac.sh
DRY_RUN=1 ~/bin/sync-folderB-ubuntu-to-mac.sh
```

Edit these variables in the script:

```bash
REMOTE_USER="ian"
REMOTE_HOST="macos-hostname-or-ip"
SRC="$HOME/folderB/"
DEST="/Users/ian/folderB/"
```

After the dry-run looks correct:

```bash
~/bin/sync-folderB-ubuntu-to-mac.sh
```

Logs:

```bash
journalctl --user -u sync-folderB-to-mac.service -f
tail -f ~/.local/state/folder-sync/folderB-ubuntu-to-mac.log
```

## 4. Change sync interval

macOS: edit `StartInterval` in:

```bash
~/Library/LaunchAgents/com.ian.sync.folderA-to-ubuntu.plist
```

Then reload:

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.ian.sync.folderA-to-ubuntu.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.ian.sync.folderA-to-ubuntu.plist
```

Ubuntu: edit `OnUnitActiveSec` in:

```bash
~/.config/systemd/user/sync-folderB-to-mac.timer
```

Then reload:

```bash
systemctl --user daemon-reload
systemctl --user restart sync-folderB-to-mac.timer
```

## 5. Disable deletion mirroring

Set this in either script:

```bash
DELETE=0
```

Then destination files absent from the source will no longer be deleted.

## 6. Uninstall schedulers

macOS:

```bash
./uninstall-macos-launchd.sh
```

Ubuntu:

```bash
./uninstall-ubuntu-systemd-user.sh
```
