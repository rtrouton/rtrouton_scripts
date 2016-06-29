#!/bin/sh

# Check the "Require password to unlock each System Preferences pane" checkbox in System Preferences: Security

/usr/libexec/PlistBuddy -c 'set rights:system.preferences:shared bool false' '/etc/authorization'

# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/org.janelia.lock_preferences.plist

# Make script self-destruct

rm -rf $0
