#!/bin/bash

# Determine OS version
OSVERS=$(sw_vers -productVersion | awk -F. '{print $2}')

# Check /Library/Printers/Xerox/PDEs/XeroxFeatures.plugin for the CFBundleShortVersionString
# key value. It should match the version of the installed drivers.

installed_driver=$(defaults read "/Library/Printers/Xerox/PDEs/XeroxFeatures.plugin/Contents/Info" CFBundleShortVersionString)
installed_version=$(echo "$installed_driver" | sed 's/[\._-]//g')
button1="OK"
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
icon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns"

if [[ ${OSVERS} -eq 5 ]]; then

# If the Mac is running 10.5.x, specify the current driver version
# by setting parameter 5 in the script on the JSS

  jss_driver="$5"
  driver_version=$(echo "$jss_driver" | sed 's/[\._-]//g')
  dialog="The needed Xerox printer drivers have not been detected. Installing Xerox $jss_driver Print Drivers before adding the requested printer."
  description=`echo "$dialog"`

 if [[ ${installed_version} -ge ${driver_version} ]]; then
  echo "Xerox $installed_driver Print Drivers installed"
 fi

 if [[ ${installed_version} -lt ${driver_version} ]]; then
  echo "Xerox $jss_driver Print Drivers not installed. Installing Xerox $jss_driver Print Drivers"
  "$jamfHelper" -windowType utility -description "$description" -button1 "$button1" -icon "$icon" -timeout 20
  jamf policy -trigger companyxeroxdrivers
 fi
fi

if [[ ${OSVERS} -eq 6 ]]; then

# If the Mac is running 10.6.x, specify the current driver version
# by setting parameter 6 in the script on the JSS

 jss_driver="$6"
 driver_version=$(echo "$jss_driver" | sed 's/[\._-]//g')
 dialog="The needed Xerox printer drivers have not been detected. Installing Xerox $jss_driver Print Drivers before adding the requested printer."
 description=`echo "$dialog"`

 if [[ ${installed_version} -ge ${driver_version} ]]; then
  echo "Xerox $installed_driver Print Drivers installed"
 fi

 if [[ ${installed_version} -lt ${driver_version} ]]; then
  echo "Xerox $jss_driver Print Drivers not installed. Installing Xerox $jss_driver Print Drivers"
  "$jamfHelper" -windowType utility -description "$description" -button1 "$button1" -icon "$icon" -timeout 20
  jamf policy -trigger companyxeroxdrivers
 fi
fi

if [[ ${OSVERS} -ge 7 ]]; then

# If the Mac is running 10.7.x or higher, specify the current driver version
# by setting parameter 7 in the script on the JSS
  
 jss_driver="$7"
 driver_version=$(echo $jss_driver | sed 's/[\._-]//g')
 dialog="The needed Xerox printer drivers have not been detected. Installing Xerox $jss_driver Print Drivers before adding the requested printer."
 description=`echo "$dialog"`

 if [[ ${installed_version} -ge ${driver_version} ]]; then
  echo "Xerox $installed_driver Print Drivers installed"
 fi

 if [[ ${installed_version} -lt ${driver_version} ]]; then
  echo "Xerox $jss_driver Print Drivers not installed. Installing Xerox $jss_driver Print Drivers"
  jamf displayMessage -message "$dialog"
  jamf policy -trigger companyxeroxdrivers
 fi
fi

exit 0