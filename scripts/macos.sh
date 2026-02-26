#!/usr/bin/env bash
set -euo pipefail

if [ "$(uname)" != "Darwin" ]; then
  echo "==> Skipping macOS defaults (not on macOS)."
  exit 0
fi

echo "==> Applying macOS defaults..."

# --- Keyboard ---
# Fast key repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# Disable press-and-hold for accented characters (enables key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# --- Dock ---
# Autohide the Dock
defaults write com.apple.dock autohide -bool true
# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
# Minimize windows using scale effect
defaults write com.apple.dock mineffect -string "scale"
# Set Dock icon size to 48 pixels
defaults write com.apple.dock tilesize -int 48

# --- Finder ---
# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show path bar
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true
# Use list view by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# --- Trackpad ---
# Enable tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# --- Screenshots ---
# Save screenshots to ~/Screenshots
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# --- TextEdit ---
# Use plain text mode by default
defaults write com.apple.TextEdit RichText -int 0

# --- Security ---
# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# --- Apply changes ---
echo "    Restarting affected applications..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "    macOS defaults applied."
