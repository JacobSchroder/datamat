#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Oh My Zsh..."

if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "    Oh My Zsh already installed."
else
  echo "    Installing Oh My Zsh..."
  RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  echo "    Oh My Zsh installed."
fi
