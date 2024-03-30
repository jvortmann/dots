#!/usr/bin/env bash
# based on https://github.com/mathiasbynens/dotfiles/blob/master/.osx

if [ $# -ne 1 ]
then
  echo 'Usage: ./configure-osx "computer_name"'
  exit 1
fi

computer_name="$1"

# Set machine name
echo; echo ">> Setting computer name to '$computer_name'"
sudo scutil --set ComputerName "$computer_name"
sudo scutil --set HostName "$computer_name"
sudo scutil --set LocalHostName "$computer_name"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computer_name"

# Keyboard layoyt (com.apple.HIToolbox) - might not work to set the layout, need to go to settings
defaults write com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID "com.apple.keylayout.US";
defaults write com.apple.HIToolbox AppleDictationAutoEnable -int 0
defaults write com.apple.HIToolbox AppleEnabledInputSources '({ "Bundle ID" = "com.apple.CharacterPaletteIM"; InputSourceKind = "Non Keyboard Input Method"; }, { InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; })'
defaults write com.apple.HIToolbox AppleInputSourceHistory '({ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; })'
defaults write com.apple.HIToolbox AppleSavedCurrentInputSource '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; }'
defaults write com.apple.HIToolbox AppleSelectedInputSources '({ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 0; "KeyboardLayout Name" = "U.S."; })'

# Spotlight (com.apple.Spotlight)
defaults write com.apple.Spotlight MenuItemHidden -int 1

# assign apps to spaces
spaces=($(defaults read com.apple.spaces | grep SpaceID -A3 | grep uuid | tail -n 9 | cut -f2 -d= | tr -d ' ;'))
defaults delete com.apple.spaces "app-bindings"
defaults write com.apple.spaces "app-bindings" -dict-add "com.dteoh.devdocs-macos" AllSpaces
defaults write com.apple.spaces "app-bindings" -dict-add "org.alacritty" "${spaces[0]}"
defaults write com.apple.spaces "app-bindings" -dict-add "org.mozilla.firefoxdeveloperedition" "${spaces[1]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.apple.safari" "${spaces[1]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.linear" "${spaces[2]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.todoist.mac.todoist" "${spaces[2]}"
defaults write com.apple.spaces "app-bindings" -dict-add "ru.keepcoder.telegram" "${spaces[3]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.apple.mobilesms" "${spaces[3]}"
defaults write com.apple.spaces "app-bindings" -dict-add "net.whatsapp.whatsapp" "${spaces[3]}"
defaults write com.apple.spaces "app-bindings" -dict-add "ch.protonmail.desktop" "${spaces[4]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.mimestream.mimestream" "${spaces[4]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.apple.music" "${spaces[5]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.arobas-music.guitarpro8" "${spaces[6]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.neuraldsp.archetypepetrucci" "${spaces[7]}"
defaults write com.apple.spaces "app-bindings" -dict-add "md.obsidian" "${spaces[7]}"
defaults write com.apple.spaces "app-bindings" -dict-add "notion.id" "${spaces[7]}"
defaults write com.apple.spaces "app-bindings" -dict-add "com.tinyspeck.slackmacgap" "${spaces[8]}"

# Trackpad/Mouse settings
# Trackpad settings (com.apple.AppleMultitouchTrackpad)
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents 1
defaults write com.apple.AppleMultitouchTrackpad Clicking 1
defaults write com.apple.AppleMultitouchTrackpad DragLock 0
defaults write com.apple.AppleMultitouchTrackpad Dragging 0
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold 1
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed 0
defaults write com.apple.AppleMultitouchTrackpad HIDScrollZoomModifierMask 262144
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadHandResting 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadHorizScroll 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadMomentumScroll 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadScroll 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture 1
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture 3
defaults write com.apple.AppleMultitouchTrackpad USBMouseStopsTrackpad 0

# Mouse settings (com.apple.AppleMultitouchMouse)
defaults write com.apple.AppleMultitouchMouse MouseButtonDivision 55
defaults write com.apple.AppleMultitouchMouse MouseButtonMode OneButton
defaults write com.apple.AppleMultitouchMouse MouseHorizontalScroll 1
defaults write com.apple.AppleMultitouchMouse MouseMomentumScroll 1
defaults write com.apple.AppleMultitouchMouse MouseOneFingerDoubleTapGesture 0
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerDoubleTapGesture 3
defaults write com.apple.AppleMultitouchMouse MouseTwoFingerHorizSwipeGesture 2
defaults write com.apple.AppleMultitouchMouse MouseVerticalScroll 1

# Bluetooth Trackpad settings (com.apple.AppleMultitouchMouse)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad DragLock 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad HIDScrollZoomModifierMask 262144
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHandResting 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadHorizScroll 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadMomentumScroll 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadScroll 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture 3
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad USBMouseStopsTrackpad 0

# Keyboard settings
# Enable full keyboard access for all controls
# (e.g. enable Tab in modal dialogs)
echo; echo ">> Configuring keyboard"
defaults write -g AppleKeyboardUIMode -int 3

# set fn properly
defaults write -g com.apple.keyboard.fnState -bool true

# define delays, keyrepeat and press and hold
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -float 1.2
defaults write -g ApplePressAndHoldEnabled -bool false

# Universal access (com.apple.universalaccess)
defaults write com.apple.universalaccess HIDScrollZoomModifierMask  262144
defaults write com.apple.universalaccess closeViewDesiredZoomFactor "1.833938598632812"
defaults write com.apple.universalaccess closeViewHotkeysEnabled 1
# set control to zoom
defaults write com.apple.universalaccess closeViewScrollWheelToggle 1
defaults write com.apple.universalaccess closeViewSplitScreenRatio "0.2"
defaults write com.apple.universalaccess closeViewTrackpadGestureZoomEnabled 1
defaults write com.apple.universalaccess closeViewZoomDisplayID 0
defaults write com.apple.universalaccess closeViewZoomFactor 1
defaults write com.apple.universalaccess closeViewZoomFactorBeforeTermination 1
defaults write com.apple.universalaccess closeViewZoomedIn 0
defaults write com.apple.universalaccess customFonts 1
defaults write com.apple.universalaccess grayscale 0
defaults write com.apple.universalaccess headMouseSensitivity "0.5"
defaults write com.apple.universalaccess headMouseTolerance 0
defaults write com.apple.universalaccess hoverTextEnabled 0
defaults write com.apple.universalaccess hudNotifiedConstrast 0
defaults write com.apple.universalaccess keyboardAccessFocusRingTimeout 15
defaults write com.apple.universalaccess liveSpeechEnabled 0
defaults write com.apple.universalaccess login 0
defaults write com.apple.universalaccess mouseDriverCursorSize 1
defaults write com.apple.universalaccess slowKey 0
defaults write com.apple.universalaccess slowKeyDelay 250
defaults write com.apple.universalaccess stickyKey 0
defaults write com.apple.universalaccess switchAutoScanElementInterval "0.5"
defaults write com.apple.universalaccess switchAutoScanPanelInterval "0.5"
defaults write com.apple.universalaccess switchCoalescePressesDuration 0
defaults write com.apple.universalaccess switchFirstElementDelay 0
defaults write com.apple.universalaccess switchHideUITimeout 15
defaults write com.apple.universalaccess switchHoldBeforeRepeatDuration 3
defaults write com.apple.universalaccess switchMinimumPressDuration 0
defaults write com.apple.universalaccess switchSweepingCursorSpeed 5
defaults write com.apple.universalaccess useStickyKeysShortcutKeys 0
defaults write com.apple.universalaccess "com.apple.custommenu.apps" '( NSGlobalDomain )'
defaults write com.apple.universalaccess "UserAssignableHotKeys" '( { enabled = 1; key = 120; modifier = 8650752; sybmolichotkey = 7; }, { enabled = 1; key = 99; modifier = 8650752; sybmolichotkey = 8; }, { enabled = 1; key = 118; modifier = 8650752; sybmolichotkey = 9; }, { enabled = 1; key = 96; modifier = 8650752; sybmolichotkey = 10; }, { enabled = 1; key = 97; modifier = 8650752; sybmolichotkey = 11; })'

# set background lighting properly
defaults write com.apple.BezelServices kDim -bool true
defaults write com.apple.BezelServices kDimTime -int 300

# Use proper units
echo; echo ">> Configuring measurement units"
defaults write -g AppleMeasurementUnits -string "Centimeters"
defaults write -g AppleMetricUnits -bool true

# Mission Control
echo; echo ">> Configuring Mission Control"
defaults write com.apple.dock expose-animation-duration -float 0.12
# Save screenshot as a png
defaults write com.apple.screencapture type -string 'png'

# screen corners
# Top Left - Application Windows
defaults write com.apple.dock wvous-tl-corner -int 3
defaults write com.apple.dock wvous-tl-modifier -int 0
# Bottom Left - Dashboard
defaults write com.apple.dock wvous-bl-corner -int 7
defaults write com.apple.dock wvous-bl-modifier -int 0
# Top Right - Mission Control
defaults write com.apple.dock wvous-tr-corner -int 2
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom Righ - Desktop
defaults write com.apple.dock wvous-br-corner -int 4
defaults write com.apple.dock wvous-br-modifier -int 0

## Spaces / Dock
# Enable Dashboard
defaults write com.apple.dashboard enabled-state -int 2
# Don’t automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# Disable Magnification
defaults write com.apple.dock magnification -bool false
# Enable app expose
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Enable highlight hover effect for the grid view of a stack
defaults write com.apple.dock mouse-over-hilte-stack -bool true
# Set the icon size of Dock items
defaults write com.apple.dock tilesize -int 43
# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# require password after screen lock
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Finder
# Style - Dark Mode
echo; echo ">> Configuring Finder Control"
defaults write -g AppleInterfaceStyle -string 'Dark'

# increase window resize speed for Cocoa applications
defaults write -g NSWindowResizeTime -float 0.001
# decrease delay on spring loaded folder to the second level
defaults write -g com.apple.springing.enabled -bool true
defaults write -g com.apple.springing.delay -float 0.5

# Show connected servers on desktop
# External Hard Drive
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
# Hard Drive
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
# Mounted Servers
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
# Removable Media
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Remove warning when changing extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false
defaults write com.apple.finder EmptyTrashSecurely -bool true
# Finder windows
defaults write com.apple.finder ShowStatusBar -bool false
defaults write com.apple.finder ShowPathbar -bool true
# Enable AirDrop over Ethernet and on unsupported Macs running Lion
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

## Apps

echo; echo ">> Configuring Apps"
## Safari
echo; echo ">> Configuring Safari"
#Prevent from opening ‘safe’ files automatically after downloading
defaults write -app Safari AutoOpenSafeDownloads -bool false
#Enable debug mode
defaults write -app Safari IncludeInternalDebugMenu -bool true
#Make Safari’s search banners default to Contains instead of Starts With
defaults write -app Safari FindOnPageMatchesWordStartsOnly -bool false
#Press Tab to highlight each item on a web page
defaults write -app Safari WebKitTabToLinksPreferenceKey -bool true
defaults write -app Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
#Show the full URL in the address bar (note: this still hides the scheme)
defaults write -app Safari ShowFullURLInSmartSearchField -bool true
#Enable the Develop menu and the Web Inspector in Safari
defaults write -app Safari IncludeDevelopMenu -bool true
defaults write -app Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write -app Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
#Add a context menu item for showing the Web Inspector in web views
defaults write -g WebKitDeveloperExtras -bool true

echo; echo ">> Killing affected apps"
for app in "Dock" "Finder" "SystemUIServer" "Safari"; do
  killall "${app}" > /dev/null 2>&1
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
