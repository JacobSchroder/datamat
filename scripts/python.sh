#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up Python with pyenv..."

if ! command -v pyenv &>/dev/null; then
  echo "    ERROR: pyenv not found. Run brew.sh first."
  exit 1
fi

PYTHON_VERSION="3.11.11"

if pyenv versions --bare | grep -q "^${PYTHON_VERSION}$"; then
  echo "    Python $PYTHON_VERSION already installed."
else
  echo "    Installing Python $PYTHON_VERSION..."
  pyenv install "$PYTHON_VERSION"
fi

echo "    Setting Python $PYTHON_VERSION as global default..."
pyenv global "$PYTHON_VERSION"

echo "    Python setup complete."
