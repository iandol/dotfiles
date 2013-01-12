# ~/.osx — http://mths.be/osx

# Ask for the administrator password upfront
sudo -v
# Keep-alive: update existing `sudo` time stamp until `.osx` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo 'Starting defaults edit...'
# Set computer name (as done via System Preferences → Sharing)
#sudo scutil --set ComputerName "MathBook Pro"
#sudo scutil --set HostName "MathBook Pro"
#sudo scutil --set LocalHostName "MathBook-Pro"
#sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "MathBook-Pro"

# Set F8 as delete
defaults write com.apple.finder NSUserKeyEquivalents -dict-add "Move to Trash" "\\Uf70b"

# Set Help Viewer windows to non-floating mode
defaults write com.apple.helpviewer DevMode -bool true

# Menu bar: enable/disable transparency
#defaults write NSGlobalDomain AppleEnableMenuBarTransparency -bool true

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults write com.apple.dock "expose-group-by-app" -bool false

# Don’t show Dashboard as a Space
defaults write com.apple.dock "dashboard-in-overlay" -bool true

# Menu bar: hide the useless Time Machine and Volume icons
#defaults write com.apple.systemuiserver menuExtras -array "/System/Library/CoreServices/Menu Extras/TextInput.menu" "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" "/System/Library/CoreServices/Menu Extras/AirPort.menu" "/System/Library/CoreServices/Menu Extras/Battery.menu" "/System/Library/CoreServices/Menu Extras/Clock.menu"

#Enable debug menus:
#----------------------------
defaults write com.apple.Safari IncludeInternalDebugMenu 1
defaults write com.apple.DiskUtility DUDebugMenuEnabled 1

#Verbose boot:
#------------------
sudo nvram boot-args="-v"

#Enable text selection in quick look:
#---------------------------------------------
defaults write com.apple.finder QLEnableTextSelection -bool true

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

#Speed up mission control anim:
#------------------------------------------
defaults write com.apple.dock expose-animation-duration -float 0.1
#Remove this:
#defaults delete com.apple.dock expose-animation-duration; 

#airport scanning until, use airport -s:
#-------------------------------------------------
sudo ln -sv /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/sbin/airport
#Wi-fi diagnostics:
#------------------------
sudo ln -sv /System/Library/CoreServices/Wi-Fi\ Diagnostics.app /Applications/Wi-Fi\ Diagnostics.app
#Screen sharing:
#---------------
sudo ln -sv /System/Library/CoreServices/Screen\ Sharing.app /Applications/Screen\ Sharing.app

#Fix Annoying iWork stuff:
#------------------------------
sudo defaults write /Library/Preferences/com.apple.iWork09.Installer InstallMode -string 'Retail'
sudo defaults write /Library/Preferences/com.apple.iWork09 ShouldNotSendRegistration -bool yes
 
#While reverse engineering the Dock for HyperDock, I stumbled over this useful hidden setting that #removes the display delay when the Dock is hidden. 
#---------------------------------------------------------------------
defaults write com.apple.Dock autohide-delay -float 0.1 && killall Dock
defaults write com.apple.dock autohide-time-modifier -float 0.4; killall Dock
# To restore the default behavior, enter:
#defaults delete com.apple.Dock autohide-delay && killall Dock  
#defaults delete com.apple.dock autohide-time-modifier;killall Dock

#Other tweaks:
#-------------------
# Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true

# Enable iTunes track notifications in the Dock
#defaults write com.apple.dock itunes-notifications -bool true

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true

#metric
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

# Expand print panel by default
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# Disable the “Are you sure you want to open this application?” dialog
#defaults write com.apple.LaunchServices LSQuarantine -bool false

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilte-stack -bool true

# Enable spring loading for all Dock items
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 0

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Increase window resize speed for Cocoa applications
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Make the iTunes arrow links go to your library instead of the iTunes Store
defaults write com.apple.iTunes invertStoreLinks -bool true

# Disable the iTunes arrow links completely
defaults write com.apple.iTunes show-store-arrow-links -bool false

# Disable the Ping sidebar in iTunes
#defaults write com.apple.iTunes disablePingSidebar -bool true

# Disable all the other Ping stuff in iTunes
#defaults write com.apple.iTunes disablePing -bool true

# Show the ~/Library folder
chflags nohidden ~/Library

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

echo 'Will restart apps...'
for app in Finder Dock Mail Safari iTunes iCal Address\ Book SystemUIServer; do
	echo "Trying to kill $app..."
	sudo killall "$app" > /dev/null 2>&1
done
echo "Done. Note that some of these changes require a logout/restart to take effect."
