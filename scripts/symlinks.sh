#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
BACKED_UP=false

link_file() {
  local src="$1"
  local dest="$2"

  # If the symlink already points to the correct target, skip
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "    OK $dest (already linked)"
    return
  fi

  # If something exists at the destination, back it up
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ "$BACKED_UP" = false ]; then
      mkdir -p "$BACKUP_DIR"
      BACKED_UP=true
    fi
    local backup_path="$BACKUP_DIR/${dest#$HOME/}"
    mkdir -p "$(dirname "$backup_path")"
    mv "$dest" "$backup_path"
    echo "    Backed up $dest → $backup_path"
  fi

  # Create parent directory if needed
  mkdir -p "$(dirname "$dest")"

  ln -s "$src" "$dest"
  echo "    Linked $dest → $src"
}

link_tree() {
  local source_dir="$1"
  local target_base="$2"

  if [ ! -d "$source_dir" ]; then
    return
  fi

  # Walk the source tree and link individual files
  while IFS= read -r -d '' file; do
    local rel="${file#$source_dir/}"
    local dest="$target_base/$rel"
    link_file "$file" "$dest"
  done < <(find "$source_dir" -type f -print0)
}

echo "==> Creating symlinks..."

# Link home/ → $HOME
link_tree "$DOTFILES_DIR/home" "$HOME"

# Link home-macos/ → $HOME (macOS only)
if [ "$(uname)" = "Darwin" ]; then
  link_tree "$DOTFILES_DIR/home-macos" "$HOME"
fi

if [ "$BACKED_UP" = true ]; then
  echo "    Backups saved to $BACKUP_DIR"
fi

echo "    Symlinks complete."
