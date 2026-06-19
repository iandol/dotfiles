#!/usr/bin/env bash
# One-way mirror: Ubuntu folderB -> macOS destination
# Run first with: DRY_RUN=1 ./sync-folderB-ubuntu-to-mac.sh

set -Eeuo pipefail

# ---------- EDIT THESE ----------
REMOTE_HOST="${REMOTE_HOST:-senecaz}"
SSH_PORT="${SSH_PORT:-2222}"
SRC="${SRC:-$HOME/wiki/}"                    # trailing slash = copy contents of folderB
DEST="${DEST:-/Users/ian/wiki/}"             # trailing slash recommended
REMOTE_BACKUP_ROOT="${REMOTE_BACKUP_ROOT:-/Users/ian/.rsync-backups/wiki}"
# -------------------------------

SYNC_NAME="wiki"
LOG_DIR="${LOG_DIR:-$HOME/.local/state/folder-sync}"
LOCK_ROOT="${LOCK_ROOT:-$HOME/.cache/folder-sync}"
DRY_RUN="${DRY_RUN:-0}"
DELETE="${DELETE:-1}"                           # 1 = mirror source deletions to destination
BACKUP_DELETED="${BACKUP_DELETED:-1}"           # 1 = save replaced/deleted destination files
MAX_BACKUP_DAYS="${MAX_BACKUP_DAYS:-30}"

PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
RSYNC="${RSYNC:-$(command -v rsync)}"
REMOTE="${REMOTE_USER}@${REMOTE_HOST}"
RUN_ID="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$LOG_DIR" "$LOCK_ROOT"
LOG_FILE="$LOG_DIR/${SYNC_NAME}.log"
LOCK_DIR="$LOCK_ROOT/${SYNC_NAME}.lock"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  echo "[$(date '+%F %T')] ${SYNC_NAME}: already running; exiting" >> "$LOG_FILE"
  exit 0
fi
trap 'rm -rf "$LOCK_DIR"' EXIT

log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"; }
q() { printf '%q' "$1"; }

if [[ ! -d "$SRC" ]]; then
  log "ERROR: source directory does not exist: $SRC"
  exit 1
fi

# Ensure destination and remote backup directories exist before rsync starts.
ssh -p "$SSH_PORT" "$REMOTE" "mkdir -p $(q "$DEST") $(q "$REMOTE_BACKUP_ROOT")"

RSYNC_ARGS=(
  -rltp
  --links
  --human-readable
  --itemize-changes
  --partial
  --safe-links
  --exclude='.DS_Store'
  --exclude='._*'
  --exclude='.Trash-*'
  --exclude='.rsync-backups/'
)

if [[ "$DELETE" == "1" ]]; then
  RSYNC_ARGS+=(--delete)
fi

if [[ "$BACKUP_DELETED" == "1" ]]; then
  REMOTE_BACKUP_DIR="$REMOTE_BACKUP_ROOT/$RUN_ID"
  ssh -p "$SSH_PORT" "$REMOTE" "mkdir -p $(q "$REMOTE_BACKUP_DIR")"
  RSYNC_ARGS+=(--backup --backup-dir="$REMOTE_BACKUP_DIR")
fi

if "$RSYNC" --help 2>/dev/null | grep -q -- '--protect-args'; then
  RSYNC_ARGS+=(--protect-args)
fi

if [[ "$DRY_RUN" == "1" ]]; then
  RSYNC_ARGS+=(--dry-run)
  log "DRY RUN: no files will be changed"
fi

log "Starting sync: $SRC -> $REMOTE:$DEST"
"$RSYNC" "${RSYNC_ARGS[@]}" -e "ssh -p $SSH_PORT" "$SRC" "$REMOTE:$DEST" 2>&1 | tee -a "$LOG_FILE"
status=${PIPESTATUS[0]}

# Clean old backup folders on the destination host. This is best-effort only.
if [[ "$BACKUP_DELETED" == "1" && "$DRY_RUN" != "1" ]]; then
  ssh -p "$SSH_PORT" "$REMOTE" "find $(q "$REMOTE_BACKUP_ROOT") -mindepth 1 -maxdepth 1 -type d -mtime +$MAX_BACKUP_DAYS -exec rm -rf {} +" || true
fi

if [[ "$status" -eq 0 ]]; then
  log "Finished successfully"
else
  log "ERROR: rsync exited with status $status"
fi
exit "$status"
