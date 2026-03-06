#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DIA_PREFS="$HOME/Library/Application Support/Dia/User Data/Default/Preferences"
EXPORTED_PREFS="$REPO_DIR/dia-preferences.json"
EXTENSIONS_FILE="$REPO_DIR/dia-extensions.txt"

# Machine-specific keys to strip on export
STRIP_KEYS='[
  "account_tracker_service_last_update",
  "google",
  "gcm",
  "signin",
  "updateclientdata",
  "domain_diversity",
  "segmentation_platform",
  "optimization_guide"
]'

# Also strip nested machine-specific keys
STRIP_NESTED='{
  "profile": ["info_cache"]
}'

strip_keys() {
  python3 -c "
import json, sys

strip_keys = json.loads(sys.argv[1])
strip_nested = json.loads(sys.argv[2])

d = json.load(sys.stdin)

for k in strip_keys:
    d.pop(k, None)

for parent, children in strip_nested.items():
    if parent in d and isinstance(d[parent], dict):
        for child in children:
            d[parent].pop(child, None)

json.dump(d, sys.stdout, indent=2, ensure_ascii=False)
print()
" "$STRIP_KEYS" "$STRIP_NESTED"
}

extract_extensions() {
  python3 -c "
import json, sys, os

prefs_path = sys.argv[1]
ext_dir = os.path.expanduser('~/Library/Application Support/Dia/User Data/Default/Extensions')

ids = set()

# From filesystem
if os.path.isdir(ext_dir):
    for name in os.listdir(ext_dir):
        if len(name) == 32 and name.isalpha():
            ids.add(name)

# From Preferences pinned_extensions
d = json.load(open(prefs_path))
for ext_id in d.get('extensions', {}).get('pinned_extensions', []):
    if len(ext_id) == 32:
        ids.add(ext_id)

for ext_id in sorted(ids):
    print(ext_id)
" "$1"
}

dump() {
  if [ ! -f "$DIA_PREFS" ]; then
    echo "Error: Dia Preferences not found at $DIA_PREFS"
    exit 1
  fi

  echo "Exporting Dia Preferences (gitignored)..."
  strip_keys < "$DIA_PREFS" > "$EXPORTED_PREFS"
  echo "  -> Sanitized Preferences written to dia-preferences.json"

  echo "Extracting extension IDs..."
  extract_extensions "$DIA_PREFS" > "$EXTENSIONS_FILE"
  echo "  -> $(wc -l < "$EXTENSIONS_FILE" | tr -d ' ') extensions written to dia-extensions.txt"

  echo "Done. Review and commit the changes."
  echo "Note: dia-preferences.json is gitignored — copy it manually to transfer settings."
}

restore() {
  if pgrep -x "Dia" > /dev/null 2>&1; then
    echo "Warning: Dia is running. Please close it before restoring settings."
    exit 1
  fi

  local source_prefs="${1:-$EXPORTED_PREFS}"
  if [ ! -f "$source_prefs" ]; then
    echo "Error: No Preferences file found at $source_prefs"
    echo ""
    echo "Usage: $0 restore [path-to-Preferences-file]"
    echo "  Defaults to dia-preferences.json (created by 'dump')."
    exit 1
  fi

  if [ ! -f "$DIA_PREFS" ]; then
    echo "No existing Dia Preferences found. Copying provided Preferences directly."
    mkdir -p "$(dirname "$DIA_PREFS")"
    cp "$source_prefs" "$DIA_PREFS"
    echo "Done."
    return
  fi

  echo "Merging provided Preferences into existing Dia Preferences..."
  python3 -c "
import json, sys

strip_keys = json.loads(sys.argv[1])
strip_nested = json.loads(sys.argv[2])
existing_path = sys.argv[3]
saved_path = sys.argv[4]

existing = json.load(open(existing_path))
saved = json.load(open(saved_path))

# Preserve machine-specific keys from existing
preserved = {}
for k in strip_keys:
    if k in existing:
        preserved[k] = existing[k]

preserved_nested = {}
for parent, children in strip_nested.items():
    if parent in existing and isinstance(existing[parent], dict):
        for child in children:
            if child in existing[parent]:
                preserved_nested.setdefault(parent, {})[child] = existing[parent][child]

# Start from saved, overlay preserved values
merged = dict(saved)
merged.update(preserved)

for parent, children in preserved_nested.items():
    if parent not in merged:
        merged[parent] = {}
    merged[parent].update(children)

json.dump(merged, open(existing_path, 'w'), indent=2, ensure_ascii=False)
print()
" "$STRIP_KEYS" "$STRIP_NESTED" "$DIA_PREFS" "$source_prefs"

  echo "Done. Restart Dia to apply settings."
}

case "${1:-}" in
  dump)    dump ;;
  restore) restore "${2:-}" ;;
  *)
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  dump                              — Export Preferences + extension IDs"
    echo "  restore [path-to-Preferences]     — Merge Preferences into Dia (defaults to dia-preferences.json)"
    exit 1
    ;;
esac
