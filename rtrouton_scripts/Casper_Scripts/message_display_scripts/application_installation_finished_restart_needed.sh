#!/bin/bash

# This script displays a message that lets the user know that 
# an application installation policy has finished. It is set 
# to the lowest priority to ensure that it runs last after all 
# other scripts and policy actions.

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

application_name="$4"
dialog="$application_name has now been installed on your Mac. Please restart your Mac before using $application_name."
description=`echo "$dialog"`
button1="OK"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

if [[ ${osvers} -lt 7 ]]; then

  "$jamfHelper" -windowType utility -description "$description" -button1 "$button1" -icon "$icon"

fi

if [[ ${osvers} -ge 7 ]]; then

  jamf displayMessage -message "$dialog"

fi

exit 0