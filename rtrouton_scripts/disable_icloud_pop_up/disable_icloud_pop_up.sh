#!/bin/sh

# Disables iCloud pop-up on first login for Macs running 10.7.2
# or higher for new users by setting com.apple.SetupAssistant in
# /System/Library/User\ Template/Non_localized/Library/Preferences/ 
# to include the key "DidSeeCloudSetup" with a Boolean value of TRUE

defaults write /System/Library/User\ Template/Non_localized/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE