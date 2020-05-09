#!/usr/bin/env bash

# Script to tweak macos preferences.

DOTFILE_DIR="${DOTFILE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
source "$DOTFILE_DIR/scripts/setup"

@defaults Configure locale
  - NSGlobalDomain AppleLanguages        array  "en" "ja"
  - NSGlobalDomain AppleLocale           string "en_JP"
  - NSGlobalDomain AppleMeasurementUnits string "Centimeters"
  - NSGlobalDomain AppleMetricUnits      bool   true

@defaults Configure the battery indicator
  - com.apple.menuextra.battery ShowPercent string "YES"

@defaults Configure the dock
  - com.apple.dock tilesize          int  32
  - com.apple.dock size-immutable    bool true
  - com.apple.dock expose-group-apps bool true

@defaults Configure Safari
  - com.apple.Safari AutoOpenSafeDownloads  bool false
  - com.apple.Safari AutoFillPasswords      bool false
  - com.apple.Safari AutoFillCreditCardData bool false
  - com.apple.Safari IncludeDevelopMenu     bool true
  - com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey bool true
  - com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled bool true

@defaults Tame .DS_Store
  - com.apple.desktopservices DSDontWriteNetworkStores bool true
  - com.apple.desktopservices DSDontWriteUSBStores     bool true

@defaults Tame auto-correction
  - NSGlobalDomain NSAutomaticCapitalizationEnabled     bool false
  - NSGlobalDomain NSAutomaticDashSubstitutionEnabled   bool false
  - NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled bool false
  - NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled  bool false
  - NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false

@install Install keybindings
  # symlinking doesn't work, due to an Apple bug
  - shell: mkdir -p ~/Library/KeyBindings
  - shell: ln "$DOTFILE_DIR/home/Library/KeyBindings/DefaultKeyBinding.dict" ~/Library/KeyBindings
