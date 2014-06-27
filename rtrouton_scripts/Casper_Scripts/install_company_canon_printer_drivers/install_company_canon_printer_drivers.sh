#!/bin/bash

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Check /Library/Printers/Canon/CUPSPS2/Utilities/Canon CUPS PS Printer Utility.app/Contents/Info.plist
# for the CFBundleVersion key value. It should match the version of the installed drivers.

installed_driver=$(defaults read "/Library/Printers/Canon/CUPSPS2/Utilities/Canon CUPS PS Printer Utility.app/Contents/Info" CFBundleVersion)

# Specify the current driver version
# by setting parameter 4 in the script
# on the JSS

driver_version="$4"
dialog="The needed Canon printer drivers have not been detected. Installing Canon PS $driver_version Print Drivers before adding the requested printer."
description=`echo "$dialog"`
button1="OK"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

if [[ ${installed_driver} > ${driver_version} ]]; then
  echo "Canon PS $installed_driver Print Drivers installed"
fi

if [[ ${installed_driver} == ${driver_version} ]]; then
  echo "Canon PS $driver_version Print Drivers installed"
fi

if [[ ${installed_driver} < ${driver_version} ]]; then
  echo "Canon PS $driver_version Print Drivers not installed. Installing Canon PS $driver_version Print Drivers"
  if [[ ${osvers} -lt 7 ]]; then

    "$jamfHelper" -windowType utility -description "$description" -button1 "$button1" -icon "$icon" -timeout 20

  fi

  if [[ ${osvers} -ge 7 ]]; then

    jamf displayMessage -message "$dialog"

  fi
 jamf policy -trigger companycanondrivers
fi

exit 0