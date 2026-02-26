# datamat

Dotfiles and bootstrap scripts for a fresh macOS setup. Clone, run one script, get your full dev environment.

## Quick Start

```bash
git clone https://github.com/JacobSchroder/datamat.git ~/datamat
cd ~/datamat
./install.sh
```

## What Gets Installed

| Category | Tools |
|----------|-------|
| **Languages** | Go, Python 3.11 (pyenv), Node.js (nvm), Bun, Deno |
| **Package managers** | Homebrew, pnpm, pipx |
| **CLI tools** | awscli, gh, ripgrep, htop, tree, direnv, entr, neovim, sqlc, protobuf, pre-commit, git-lfs, terraform, opentofu, cdk, conftest |
| **Databases** | PostgreSQL 17, pgAdmin 4, DataGrip |
| **Go binaries** | air, templ, templui, gopls, staticcheck, swag, task, protoc-gen-go, protoc-gen-go-grpc, goa, go-blueprint |
| **Editors** | Cursor (+ 43 extensions), Zed |
| **Terminals** | Ghostty, Warp |
| **Shell** | Oh My Zsh, zsh-autosuggestions, zsh-syntax-highlighting |
| **Dev tools** | OrbStack, Postman, GitHub Desktop, Android Studio, SF Symbols |
| **Browsers** | Brave, Firefox, Chrome |
| **Productivity** | Claude, Raycast, Notion, Obsidian, Linear, Morgen, Slack, Discord, Telegram, Zoom, Perplexity |
| **Media** | Spotify, Steam |
| **macOS defaults** | Fast key repeat, Dock autohide, Finder tweaks, tap-to-click, screenshots to ~/Screenshots |

### Not automated (require separate installers/licenses)

Ableton Live, Native Instruments, Arturia, Soundtoys, rekordbox

## Repo Structure

```
datamat/
├── install.sh                  # Main entrypoint
├── Brewfile                    # Homebrew formulae + casks
├── cursor-extensions.txt       # Cursor extension IDs
├── scripts/
│   ├── xcode.sh                # Xcode CLI tools
│   ├── brew.sh                 # Homebrew + Brewfile
│   ├── shell.sh                # Oh My Zsh
│   ├── node.sh                 # nvm + bun
│   ├── python.sh               # pyenv + Python 3.11.11
│   ├── go.sh                   # Go tool binaries
│   ├── cursor.sh               # Cursor extensions
│   ├── symlinks.sh             # Symlink dotfiles into $HOME
│   └── macos.sh                # macOS system preferences
├── home/                       # Dotfiles symlinked to $HOME
│   ├── .zshrc
│   ├── .zprofile
│   ├── .vimrc
│   ├── .gitconfig
│   └── .config/
│       ├── git/ignore
│       ├── zed/
│       │   ├── settings.json
│       │   └── keymap.json
│       └── gh/config.yml
└── home-macos/                 # macOS-only paths
    └── Library/Application Support/
        ├── com.mitchellh.ghostty/config
        └── Cursor/User/settings.json
```

## Running Individual Modules

```bash
./install.sh brew           # Just Homebrew + Brewfile
./install.sh symlinks       # Just symlink dotfiles
./install.sh symlinks macos # Symlinks + macOS defaults
./install.sh node python    # Just Node.js and Python setup
```

Module order when running all: `xcode` → `brew` → `shell` → `node` → `python` → `go` → `cursor` → `symlinks` → `macos`

Each module is idempotent — safe to re-run at any time.

## Manual Steps After Install

1. **GitHub CLI**: Run `gh auth login` to authenticate
2. **SSH keys**: Generate or copy your SSH keys to `~/.ssh/`
3. **Zed Sanity token**: Replace `<SANITY_TOKEN>` in `~/.config/zed/settings.json` with your actual token

## Updating

### Re-dump Brewfile after installing new packages

```bash
brew bundle dump --file=~/datamat/Brewfile --force
```

### Re-dump Cursor extensions

```bash
cursor --list-extensions > ~/datamat/cursor-extensions.txt
```

### After editing dotfiles

Changes to files in `home/` or `home-macos/` are live immediately (they're symlinked). Just commit and push.

## Linux Notes

- `home-macos/` paths are only symlinked on Darwin — safe to clone on Linux
- `scripts/macos.sh` exits early on non-Darwin systems
- `scripts/brew.sh` installs Linuxbrew if not on macOS
- Cask-only apps (GUI) will be skipped on Linux by `brew bundle`
- You may need to adjust `.zshrc` paths for Linux Homebrew (`/home/linuxbrew/.linuxbrew/`)
