#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Setting up Homebrew..."

if command -v brew &>/dev/null; then
  echo "    Homebrew already installed."
else
  echo "    Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Running brew bundle..."
brew bundle --file="$DOTFILES_DIR/Brewfile" --no-lock

echo "    Homebrew setup complete."
