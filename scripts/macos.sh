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
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock tilesize -int 34
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 46

# --- Dock apps & folders ---
DOCK_APPS=(
  "/Applications/Spotify.app"
  "/System/Applications/Messages.app"
  "/Applications/Slack.app"
  "/Applications/Telegram.app"
  "/System/Applications/Calendar.app"
  "/System/Applications/Reminders.app"
  "/Applications/Obsidian.app"
  "/Applications/Granola.app"
  "/Applications/Brave Browser.app"
  "/Applications/Dia.app"
  "/Applications/Linear.app"
  "/Applications/Ghostty.app"
  "/Applications/Zed.app"
  "/Applications/Claude.app"
  "/System/Applications/System Settings.app"
)

DOCK_FOLDERS=(
  "$HOME/Screenshots"
  "$HOME/Downloads"
)

add_dock_app() {
  defaults write com.apple.dock persistent-apps -array-add \
    "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$1</string><key>_CFURLStringType</key><integer>0</integer></dict></dict><key>tile-type</key><string>file-tile</string></dict>"
}

add_dock_folder() {
  defaults write com.apple.dock persistent-others -array-add \
    "<dict><key>tile-data</key><dict><key>arrangement</key><integer>1</integer><key>displayas</key><integer>0</integer><key>file-data</key><dict><key>_CFURLString</key><string>file://$1/</string><key>_CFURLStringType</key><integer>15</integer></dict><key>showas</key><integer>0</integer></dict><key>tile-type</key><string>directory-tile</string></dict>"
}

# Clear existing dock apps and folders
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array

# Add apps in order
for app in "${DOCK_APPS[@]}"; do
  add_dock_app "$app"
done

# Add folders
for folder in "${DOCK_FOLDERS[@]}"; do
  add_dock_folder "$folder"
done

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

# --- Night Shift ---
# Enable Night Shift on a custom schedule (20:00–06:00)
NS_UID=$(dscl . -read "/Users/$(whoami)" GeneratedUID | awk '{print $2}')
NS_PLIST="$HOME/Library/Preferences/com.apple.CoreBrightness.plist"
NS_BASE=":CBUser-${NS_UID}:CBBlueReductionStatus"

pb() { /usr/libexec/PlistBuddy -c "$1" "$NS_PLIST" 2>/dev/null; }

ns_set() {
  pb "Set ${1} ${3}" || pb "Add ${1} ${2} ${3}"
}

# Ensure parent dicts exist
pb "Add :CBUser-${NS_UID} dict" || true
pb "Add ${NS_BASE} dict" || true
pb "Add ${NS_BASE}:BlueLightReductionSchedule dict" || true

ns_set "${NS_BASE}:AutoBlueReductionEnabled" bool true
ns_set "${NS_BASE}:UserEnabled" bool true
ns_set "${NS_BASE}:BlueLightReductionSchedule:DayStartHour" integer 6
ns_set "${NS_BASE}:BlueLightReductionSchedule:DayStartMinute" integer 0
ns_set "${NS_BASE}:BlueLightReductionSchedule:NightStartHour" integer 20
ns_set "${NS_BASE}:BlueLightReductionSchedule:NightStartMinute" integer 0

# --- Apply changes ---
echo "    Restarting affected applications..."
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true
killall SystemUIServer 2>/dev/null || true

echo "    macOS defaults applied."
