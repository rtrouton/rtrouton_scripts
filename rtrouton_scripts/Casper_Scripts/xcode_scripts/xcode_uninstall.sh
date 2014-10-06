#!/bin/sh

# Uninstalls versions of XCode prior to XCode 4.3

/Developer/Library/uninstall-devtools --mode=all

# Remove existing copy of Xcode.app from /Applications

if [[ -e "/Applications/Xcode.app" ]]; then
   rm -rf "/Applications/Xcode.app"
fi

exit 0