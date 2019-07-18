#!/bin/bash

# This script is designed to uninstall the Zoom videoconferencing client
# and its associated components.
#
# The script runs the following actions:
# 
# 1. Checks to see if anyone is logged in. If someone is logged in, the
#    Zoom app and ZoomOpener processes are stopped for the logged-in user.
# 2. If running, unload the Zoom audio kernel extension.
# 3. If present, delete the Zoom audio kernel extension.
# 4. Remove the Zoom application and other components from both the system
#    level and also from the individual home folders.
# 5. Forget the existing installer package receipts.
#

ERROR=0

# Checks to see if any user accounts are currently logged into the console (AKA logged into the GUI via the OS loginwindow)

users_logged_in_at_loginwindow=$(who | grep console)

# If a user is logged in, stop the existing Zoom and ZoomOpener processes for the logged-in user.

if [[ -n "$users_logged_in_at_loginwindow" ]]; then

    # Identify the logged-in user
    logged_in_user=$(scutil <<< "show State:/Users/ConsoleUser" | awk '/Name :/ && ! /loginwindow/ { print $3 }')
    
    # Identify the UID of the logged-in user
    logged_in_user_uid=$(id -u "$logged_in_user")
    
    launchctl asuser "$logged_in_user_uid" /usr/bin/pkill "zoom.us"
    launchctl asuser "$logged_in_user_uid" /usr/bin/pkill "ZoomOpener"
else
    echo "No user accounts are logged in at the login window."
fi 

# If running, unload Zoom audio kext

zoom_bundle_id="zoom.us.ZoomAudioDevice"

zoom_kext_loaded=$(kextstat | grep "$zoom_bundle_id")

if [[ -n "$zoom_kext_loaded" ]]; then
   kextunload -b "$zoom_bundle_id"
   
   if [[ $? -eq 0 ]]; then
      echo "Zoom audio kext unloaded successfully"
    else
       echo "Error: Zoom audio kext failed to unload"
       ERROR=1
    fi
fi

# Remove Zoom audio kext

zoom_kext_name="ZoomAudioDevice.kext"
rm -rf "/System/Library/Extensions/$zoom_kext_name"
rm -rf "/Library/Extensions/$zoom_kext_name"

# Removing Zoom components at system level

rm -rf "/Applications/zoom.us.app"
rm -rf "/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin"
rm -rf "/Library/Audio/Plug-Ins/HAL/ZoomAudioDevice.driver"
rm -rf "/Library/Audio/Plug-Ins/HAL/Contents/MacOS/ZoomAudioDevice"
rm -rf "/Library/Audio/Plug-Ins/HAL/Contents/Resources/ZoomAudioIcon.icns"
rm -rf "/Library/Logs/zoomusinstall.log"


allLocalUsers=$(/usr/bin/dscl . -list /Users UniqueID | awk '$2>500 {print $1}')

for userName in ${allLocalUsers}; do

	  # get path to user's home directory
	  userHome=$(/usr/bin/dscl . -read "/Users/$userName" NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g')
 
      rm -rf "${userHome}/Applications/zoom.us.app"
      rm -rf "${userHome}/Library/Internet Plug-Ins/ZoomUsPlugIn.plugin"
      rm -rf "${userHome}/Library/Logs/zoom.us"
      rm -rf "${userHome}/Library/Preferences/ZoomChat.plist"
      rm -rf "${userHome}/Library/Preferences/us.zoom.xos.plist"
      rm -rf "${userHome}/Library/Saved Application State/us.zoom.xos.savedState"
      rm -rf "${userHome}/Library/Application Support/zoom.us"
      rm -rf "${userHome}/.zoomus"
done

# Removing package receipts

for zoom_receipt in $(pkgutil --pkgs=".*us.zoom.*"); do
   pkgutil --forget $zoom_receipt
done

exit $ERROR