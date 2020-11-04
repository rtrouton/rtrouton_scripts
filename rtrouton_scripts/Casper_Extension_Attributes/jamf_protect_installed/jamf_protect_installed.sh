#!/bin/bash

# Jamf Pro Extension Attribute which checks to see if Jamf Protect is installed and executable. 
#
# If Jamf Protect is installed:
#
# /Library/Application Support/JamfProtect/JamfProtect.app will be present.
#
# If Jamf Protect is not installed:
#
# /Library/Application Support/JamfProtect/JamfProtect.app will not be found
#
#
# If Jamf Protect is installed, the following message is displayed:
#
# 1
#
# Otherwise, the following result is returned:
#
# 0

JAMF_PROTECT="/Library/Application Support/JamfProtect/JamfProtect.app"

if [[ -x "$JAMF_PROTECT" ]]; then
	echo "<result>1</result>"
else
	echo "<result>0</result>"
fi

exit 0