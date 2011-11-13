#!/bin/sh

# Disables AirDrop in Mac OS X 10.7.x for new users by setting
# the ~/Library/Preferences/com.apple.NetworkBrowser.plist to
# include the key "DisableAirDrop" with a value of YES

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.NetworkBrowser.plist DisableAirDrop -bool YES