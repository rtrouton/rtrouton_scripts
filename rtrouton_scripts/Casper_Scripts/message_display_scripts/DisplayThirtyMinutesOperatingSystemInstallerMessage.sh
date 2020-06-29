#!/bin/bash

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

dialog="The operating system may take up to 30 minutes to download and prepare for installation. Please be patient."
description=`echo "$dialog"`
button1="OK"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ) ]]; then

    "$jamfHelper" -windowType utility -description "$description" -button1 "$button1" -icon "$icon" -timeout 10

else

    jamf displayMessage -message "$dialog"

fi

exit 0