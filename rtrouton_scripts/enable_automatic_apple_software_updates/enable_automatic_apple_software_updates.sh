#!/bin/bash

set -x

# Check for macOS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Enable automatic download and install of system updates
# for OS X Yosemite and later.
 
plist_file="/Library/Preferences/com.apple.SoftwareUpdate.plist"

# Enable the following:
#
# Automatic background check for macOS software updates
# Automatic download of macOS software updates
# Automatic download and installation of XProtect, MRT and Gatekeeper updates
# Automatic download and installation of automatic security updates

/usr/bin/defaults write "$plist_file" AutomaticCheckEnabled -bool true
/usr/bin/defaults write "$plist_file" AutomaticDownload -bool true
/usr/bin/defaults write "$plist_file" ConfigDataInstall -bool true
/usr/bin/defaults write "$plist_file" CriticalUpdateInstall -bool true

# For macOS Mojave and later, enable the automatic installation of macOS updates.

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 14 ) || ( ${osvers_major} -eq 11 ) ]]; then
	/usr/bin/defaults write "$plist_file" AutomaticallyInstallMacOSUpdates -bool true
fi

# For OS X Yosemite through macOS High Sierra, enable the automatic installation
# of OS X and macOS updates.

plist_file="/Library/Preferences/com.apple.commerce.plist"

if [[ ( ${osvers_major} -eq 10 && ( ${osvers_minor} -ge 10 && ${osvers_minor} -lt 14 ) ) ]]; then
	/usr/bin/defaults write "$plist_file" AutoUpdateRestartRequired -bool true
fi
