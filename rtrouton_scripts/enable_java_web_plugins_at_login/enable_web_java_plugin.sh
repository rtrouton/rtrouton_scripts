#!/bin/sh

# DYNAMICALLY SET THE UUID FOR THE BYHOST FILE NAMING
if [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` == "00000000-0000-1000-8000-" ]]; then
	MAC_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c51-62 | awk {'print tolower()'}`
elif [[ `ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-50` != "00000000-0000-1000-8000-" ]]; then
	MAC_UUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
fi

# Enable Java browser plug-ins in Safari 6.0.3 and later
# for the current user by setting the com.apple.WebKit.JavaPlugInLastUsedTimestamp
# key in ~/Library/Preferences/.GlobalPreferences.plist

/usr/libexec/PlistBuddy -c "Delete :com.apple.WebKit.JavaPlugInLastUsedTimestamp" $HOME/Library/Preferences/.GlobalPreferences.plist
/usr/libexec/PlistBuddy -c "Add :com.apple.WebKit.JavaPlugInLastUsedTimestamp real $(( $(date "+%s") - 978307200 ))" $HOME/Library/Preferences/.GlobalPreferences.plist
/usr/bin/plutil -convert xml1 $HOME/Library/Preferences/.GlobalPreferences.plist

# Set the the "Enable applet plug-in and Web Start Applications" setting in
# the Java Preferences for the current user.

/usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsEnabled" $HOME/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsEnabled bool true" $HOME/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsLastUsed" $HOME/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsLastUsed real $(( $(date "+%s") - 978307200 ))" $HOME/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
/usr/bin/plutil -convert xml1 $HOME/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist

# Forces preferences to be re-read

/usr/bin/killall cfprefsd
