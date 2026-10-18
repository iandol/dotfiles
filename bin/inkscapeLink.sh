#!/usr/bin/env bash
# Install the remove_text_length Inkscape extension into the user extensions dir.
# Source files stay in ~/.dotfiles/bin (managed by git); this script links them in.
#
#   snap Inkscape (Linux): hard links are REQUIRED -- the snap cannot read
#     symlinks whose target is inside hidden ~/.dotfiles.
#   macOS (Inkscape >= 1.2): symlinks are fine.
#   other Linux (deb/flatpak): symlinks are fine.
#
# Run again after editing the extension files or after syncing the dotfiles.
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
SRC="$DOTFILES/bin"
FILES=(remove_text_length.py remove_text_length.inx)

case "$(uname -s)" in
  Darwin)
    DST="$HOME/Library/Application Support/org.inkscape.Inkscape/config/inkscape/extensions"
    mkdir -p "$DST"
    for f in "${FILES[@]}"; do
      ln -sfn "$SRC/$f" "$DST/$f"
    done
    ;;
  *)
    if [ -d "$HOME/snap/inkscape" ]; then
      DST="$HOME/snap/inkscape/common/extensions"
      mkdir -p "$DST"
      for f in "${FILES[@]}"; do
        ln -f "$SRC/$f" "$DST/$f"
      done
    else
      DST="$HOME/.config/inkscape/extensions"
      mkdir -p "$DST"
      for f in "${FILES[@]}"; do
        ln -sfn "$SRC/$f" "$DST/$f"
      done
    fi
    ;;
esac

echo "Inkscape extension files linked into: $DST"
