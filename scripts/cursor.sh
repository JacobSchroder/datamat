#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXTENSIONS_FILE="$DOTFILES_DIR/cursor-extensions.txt"

echo "==> Installing Cursor extensions..."

if ! command -v cursor &>/dev/null; then
  echo "    WARNING: cursor CLI not found. Skipping extensions."
  echo "    Open Cursor and run 'Shell Command: Install cursor command' from the palette."
  exit 0
fi

if [ ! -f "$EXTENSIONS_FILE" ]; then
  echo "    ERROR: $EXTENSIONS_FILE not found."
  exit 1
fi

while IFS= read -r ext || [ -n "$ext" ]; do
  # Skip empty lines and comments
  [[ -z "$ext" || "$ext" == \#* ]] && continue
  echo "    Installing $ext..."
  cursor --install-extension "$ext" --force 2>/dev/null || echo "    WARNING: Failed to install $ext"
done < "$EXTENSIONS_FILE"

echo "    Cursor extensions installed."
