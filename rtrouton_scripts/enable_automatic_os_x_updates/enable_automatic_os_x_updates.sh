#!/bin/bash

# Run the command below with root privileges to enable OS X updates
# to be installed automatically on 10.10.x and later.

/usr/bin/defaults write /Library/Preferences/com.apple.commerce AutoUpdateRestartRequired -bool TRUE

exit 0