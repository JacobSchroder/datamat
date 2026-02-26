#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

ALL_MODULES=(xcode brew shell node python go cursor symlinks macos)

run_module() {
  local module="$1"
  local script="$SCRIPTS_DIR/${module}.sh"

  if [ ! -f "$script" ]; then
    echo "ERROR: Unknown module '$module' (no script at $script)"
    exit 1
  fi

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Running: $module"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  bash "$script"
}

if [ $# -eq 0 ]; then
  echo "datamat — dotfiles bootstrap"
  echo "Running all modules: ${ALL_MODULES[*]}"
  for module in "${ALL_MODULES[@]}"; do
    run_module "$module"
  done
else
  for module in "$@"; do
    run_module "$module"
  done
fi

echo ""
echo "Done! You may need to restart your shell."
