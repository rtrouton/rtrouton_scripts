#!/bin/bash

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