#!/bin/sh

# This script is designed to reset your existing
# /Library/Preferences/com.apple.loginwindow.plist
# file by renaming the file. Following a reboot, a new 
# /Library/Preferences/com.apple.loginwindow.plist
# file will be generated from the system defaults. 

sudo mv /Library/Preferences/com.apple.loginwindow.plist /Library/Preferences/com.apple.loginwindow.plist.backup