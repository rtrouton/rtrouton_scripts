#!/bin/bash

LOGGER="/usr/bin/logger"

# Location of Microsoft Office 2011 Volume License file

office_2011_license="$3/Library/Preferences/com.microsoft.office.licensing.plist"

# Location of Microsoft Office 2016 Volume License file

office_2016_license="$3/Library/Preferences/com.microsoft.office.licensingV2.plist"

# Remove the Microsoft Office 2011 and 2016 volume license files
# from /Library/Preferences

if [[ -f "$office_2011_license" ]]; then
   /bin/rm -rf "$office_2011_license"
   ${LOGGER} "Removing Microsoft Office 2011 volume license"
elif [[ -f "$office_2016_license" ]]; then
   /bin/rm -rf "$office_2016_license"
   ${LOGGER} "Removing Microsoft Office 2016 volume license"
fi

exit 0