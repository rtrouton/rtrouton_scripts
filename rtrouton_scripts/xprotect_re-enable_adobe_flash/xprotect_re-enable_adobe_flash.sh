#!/bin/sh

# This script is a modified version of rtrouton's re-enable_java_6_and_7 script.
# This script will check the current Adobe Flash browser plug-in
# version and compare it against the minimum version allowed by
# Apple's XProtect malware protection. If the minimum Flash version 
# allowed by XProtect does not allow the current version of the Flash
# browser plug-in on the Mac, the script will alter the Mac's 
# /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist 
# file to set the minimum version allowed to match the current version
# of the Mac's Flash browser plug-in. This allows the Mac's current Flash
# browser plug-in to run in Safari without being blocked.
#
# Original script is from here:
# https://gist.github.com/scifiman/5109047
#

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# javaVendor=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

CURRENT_FLASH_BUILD=`/usr/libexec/PlistBuddy -c "print :CFBundleShortVersionString" /Library/Internet\ Plug-Ins/Flash\ Player.plugin/Contents/Info.plist`
XPROTECT_FLASH_BUILD=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.macromedia.Flash\ Player.plugin:MinimumPlugInBundleVersion" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist`


#
# Check to see if Xprotect is blocking Adobe's Flash browser plug-in and re-enable the plug-in if needed.
# Changes in this section are from Pepijn Bruienne's re-enable_java_6 script: https://github.com/bruienne
#

if [[ -e /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist ]]; then
  
	if [[ ${CURRENT_FLASH_BUILD} != ${XPROTECT_FLASH_BUILD} ]]; then

	 	  /usr/bin/logger "Current Flash build (${CURRENT_FLASH_BUILD}) does not match the minimum build required by Xprotect (${XPROTECT_FLASH_BUILD}). Setting current version as the minimum build."
	 	  /usr/libexec/PlistBuddy -c "Set :PlugInBlacklist:10:com.macromedia.Flash\ Player.plugin:MinimumPlugInBundleVersion $CURRENT_FLASH_BUILD" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /usr/bin/plutil -convert xml1 /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /bin/chmod a+r /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	else
	 	  /usr/bin/logger "Current Flash build is ${CURRENT_FLASH_BUILD} and Xprotect minimum build is ${XPROTECT_FLASH_BUILD}, nothing to do here."
	fi
fi

exit 0
