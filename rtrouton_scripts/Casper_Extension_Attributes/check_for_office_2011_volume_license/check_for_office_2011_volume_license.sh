#!/bin/sh

# Location of the Microsoft Office 2011 Volume License file

office_2011_volume_license="/Library/Preferences/com.microsoft.office.licensing.plist"

# Check to see if the Office 2011 volume license file is present.
# If the file is present, report the following result:
#
# Yes
# 
# If the file is not present, report the following result:
# 
# No

if [[ -f "$office_2011_volume_license" ]]; then
   echo "<result>Yes</result>"
else
   echo "<result>No</result>"
fi