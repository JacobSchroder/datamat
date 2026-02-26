#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Node.js toolchain..."

# nvm
if [ -d "$HOME/.nvm" ]; then
  echo "    nvm already installed."
else
  echo "    Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

echo "    Installing latest LTS Node.js..."
nvm install --lts
nvm use --lts

# bun
if command -v bun &>/dev/null; then
  echo "    bun already installed."
else
  echo "    Installing bun..."
  curl -fsSL https://bun.sh/install | bash
fi

echo "    Node.js toolchain setup complete."
