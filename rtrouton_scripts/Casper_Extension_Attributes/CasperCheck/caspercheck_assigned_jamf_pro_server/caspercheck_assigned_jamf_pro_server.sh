#!/bin/bash

# This Extension Attribute checks if the CasperCheck LaunchDaemon is installed, then uses the information in the LaunchDaemon and CasperCheck script to display the address of the Jamf Pro server set in this Mac's CasperCheck self-repair script.
#
# If the defined LaunchDaemon is not installed, script returns the following:
#
# CasperCheck Not Installed
#
# If the defined LaunchDaemon is installed but the script is unable to determine the address of the Jamf Pro server, script returns the following:
#
# CasperCheck not configured with Jamf Pro server address
#
# If the defined LaunchDaemon is installed and the script is able to determine the address of the Jamf Pro server, the script returns the address of the Jamf Pro server

# Identify location of CasperCheck LaunchDaemon

caspercheck_launchdaemon=/Library/LaunchDaemons/com.company.caspercheck.plist

if [[ -f "$caspercheck_launchdaemon" ]]; then 
  
  # Read location of the CasperCheck script from the the CasperCheck LaunchDaemon

  caspercheck_script_location=`/usr/bin/defaults read "$caspercheck_launchdaemon" ProgramArguments | sed -e 's/[;,()"'\'']/ /g;s/  */ /g' -e 's/^ *//; s/ *$//; /^$/d' | tail -n +2`

  # Read associated Jamf Pro server URL from the installed CasperCheck script

  assigned_jamfpro_server=`/bin/cat "$caspercheck_script_location" | awk '/jss_server_address=/ {print $1}' | sed -e 's/.*=//' -e 's/"//g'`

  if [[ -z "$assigned_jamfpro_server" ]]; then
      result="CasperCheck not configured with Jamf Pro server address"
  else
      result="$assigned_jamfpro_server"
  fi
else
  result="CasperCheck not installed"
fi

echo "<result>$result</result>"