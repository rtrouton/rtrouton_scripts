#!/bin/bash

# Accept EULA so there is no prompt

if [[ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
  /Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild -license accept
fi

# Install Mobile Device Package so there is no prompt

if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg" ]]; then
  /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg" -target /
fi

if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg" ]]; then
  /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg" -target /
fi

exit 0