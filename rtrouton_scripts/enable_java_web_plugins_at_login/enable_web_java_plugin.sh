#!/bin/sh

# DYNAMICALLY SET THE UUID FOR THE BYHOST FILE NAMING
if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` == "00000000-0000-1000-8000-" ]]; then
	MAC_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c51-62 | awk {'print tolower()'}`
elif [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
	MAC_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
fi

# Set the the "Enable applet plug-in and Web Start Applications" setting in
# the Java Preferences for the current user.

/usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsEnabled" /Users/$USER/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsEnabled bool true" /Users/$USER/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsLastUsed" /Users/$USER/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsLastUsed real $(( $(date "+%s") - 978307200 ))" /Users/$USER/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
