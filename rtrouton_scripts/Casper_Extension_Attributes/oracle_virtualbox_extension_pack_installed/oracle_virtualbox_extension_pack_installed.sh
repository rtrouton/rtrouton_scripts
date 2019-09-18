#!/bin/bash

# Extension attribute checks to see if Oracle VirtualBox's Extension Pack is installed. 
#
# If Extension Pack is installed:
#
# /Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks will be present and not an empty directory.
#
# If Extension Pack is not installed:
#
# /Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks will not be found
#
# Or
#
# /Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks will be an empty directory.
#
# If Oracle Virtualbox's Extension Pack is installed, the following message is displayed:
#
# 1
#
# Otherwise, the following result is returned:
#
# 0

VBOX_EXT_PACK_DIR="/Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks"

# Check if /Applications/VirtualBox.app/Contents/MacOS/ExtensionPacks
# is there and not empty
if [[ -n $(/bin/ls -A "$VBOX_EXT_PACK_DIR") ]]; then
	echo "<result>1</result>"
else
	echo "<result>0</result>"
fi

exit 0
