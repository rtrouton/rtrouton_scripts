#!/bin/bash

# Check /Library/Printers/Canon/CUPSPS2/Utilities/Canon CUPS PS Printer Utility.app/Contents/Info.plist
# for the CFBundleVersion key value. It should match the version of the installed drivers.

installed_driver=$(defaults read "/Library/Printers/Canon/CUPSPS2/Utilities/Canon CUPS PS Printer Utility.app/Contents/Info" CFBundleVersion)

# Specify the current driver version
# by setting parameter 4 in the script
# on the JSS

driver_version="$4"

if [[ ${installed_driver} > ${driver_version} ]]; then
  echo "Canon PS $installed_driver Print Drivers installed"
fi

if [[ ${installed_driver} == ${driver_version} ]]; then
  echo "Canon PS $driver_version Print Drivers installed"
fi

if [[ ${installed_driver} < ${driver_version} ]]; then
  echo "Canon PS $driver_version Print Drivers not installed. Installing Canon PS $driver_version Print Drivers"
  jamf displayMessage -message "The needed Canon printer drivers have not been detected. Installing Canon PS $driver_version Print Drivers before adding the requested printer."
 jamf policy -trigger companycanondrivers
fi