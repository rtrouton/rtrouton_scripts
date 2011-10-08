#!/bin/sh

# Get the system's UUID to set ByHost prefs
MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

# Creates the ByHost directory in the system's user template
# if it doesn't already exist.

mkdir /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/

# Activates the "Enable applet plug-in and Web Start Applications" setting in Java Preferences

/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsEnabled bool true" /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.java.JavaPreferences.$MAC_UUID.plist