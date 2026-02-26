# Dotfiles Repo — ~/datamat

This machine's dev environment is bootstrapped from `~/datamat`. Keep it in sync.

## Repo structure

```
~/datamat/
  install.sh              # Entrypoint — ./install.sh [module ...]
  Brewfile                # Homebrew formulae + casks
  cursor-extensions.txt   # Cursor extension IDs
  zed-extensions.txt      # Zed extension names
  scripts/                # Per-module install scripts
  home/                   # Symlinked to ~/ (cross-platform)
  home-macos/             # Symlinked to ~/ (macOS only)
```

Config files in `home/` and `home-macos/` are symlinked into `$HOME` — live edits are already in the repo, just commit.

## Sync commands

When the user installs/uninstalls tools, run the relevant sync:

| What changed | Sync command |
|---|---|
| Homebrew packages | `brew bundle dump --file=~/datamat/Brewfile --force` |
| Cursor extensions | `cursor --list-extensions > ~/datamat/cursor-extensions.txt` |
| Zed extensions | `ls "$HOME/Library/Application Support/Zed/extensions/installed/" > ~/datamat/zed-extensions.txt` |
| Go tool binaries | Edit the `GO_PACKAGES` array in `~/datamat/scripts/go.sh` |
| Config files | Already tracked via symlinks — just commit |

After syncing, remind the user to review and commit the changes.

## Drift detection

When asked to check for drift, or when the user mentions installing/uninstalling something:

1. **Homebrew formulae**: compare `brew leaves` against `brew` entries in `~/datamat/Brewfile`
2. **Homebrew casks**: compare `brew list --cask` against `cask` entries in `~/datamat/Brewfile`
3. **Apps not in Brewfile**: compare `ls /Applications` against cask entries — some apps are excluded (see below)
4. **Cursor extensions**: compare `cursor --list-extensions` against `~/datamat/cursor-extensions.txt`
5. **Zed extensions**: compare `ls "$HOME/Library/Application Support/Zed/extensions/installed/"` against `~/datamat/zed-extensions.txt`

### New IDE/editor detection

Check for config directories that might be worth tracking:
- `~/.config/<app>/` — new CLI tools or editors
- `~/Library/Application Support/<app>/` — new macOS apps with config

If found, suggest adding them to `home/` or `home-macos/`.

## Sanitization

Before committing, check these files for secrets:

| File | Secret | Placeholder |
|---|---|---|
| `home/.config/zed/settings.json` | Sanity bearer token in `context_servers.Sanity.headers.Authorization` | `Bearer <SANITY_TOKEN>` |

## Not tracked

Music production apps are installed manually and excluded from drift detection: Ableton Live, Native Instruments, Arturia, Soundtoys, rekordbox.
