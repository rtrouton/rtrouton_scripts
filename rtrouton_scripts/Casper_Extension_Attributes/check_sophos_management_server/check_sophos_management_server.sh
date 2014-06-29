#!/bin/bash

# Usual location of the com.sophos.sau.plist file used
# by Sophos to pre-configure the AutoUpdate settings to
# point to a Sophos enterprise management or update server.

sophos_sau="/Library/Preferences/com.sophos.sau.plist"

# Alternate location for com.sophos.sau.plist

sophos_alternate_sau="/Library/Sophos Anti-Virus/com.sophos.sau.plist"

# Determine if Sophos Anti-Virus is installed

if [[ -e "/Applications/Sophos Anti-Virus.app" ]]; then

# If Sophos Anti-Virus is installed, check to see if there is a com.sophos.sau.plist
# file in either the usual or alternate locations. If a file is located, the PrimaryServerURL
# key is read from the plist to determine the Sophos enterprise management or update server's 
# address. In this case, the script will return a result displaying the update server's address.
#
# If reading the PrimaryServerURL key returns a blank result, the Sophos Anti-Virus
# client is not configured to receive updates from a Sophos enterprise management or 
# update server. In this case, the script will return a result of "Sophos Anti-Virus Not Managed"

  if [[ -f "$sophos_alternate_sau" ]] && [[ ! -f "$sophos_sau" ]]; then
     result=`defaults read "/Library/Sophos Anti-Virus/com.sophos.sau" PrimaryServerURL | cut -d '/' -f3`
       if [[ $result = "" ]]; then
          result="Sophos Anti-Virus Not Managed"
       fi
  fi

  if [[ -f "$sophos_sau" ]]; then
     result=`defaults read "/Library/Preferences/com.sophos.sau" PrimaryServerURL 2>&1 | cut -d '/' -f3`
     if [[ $result = "" ]]; then
        result="Sophos Anti-Virus Not Managed"
     fi
  fi

  if [[ ! -f "$sophos_alternate_sau" ]] && [[ ! -f "$sophos_sau" ]]; then
      result="Sophos Anti-Virus Not Managed"
  fi
else

  # If Sophos Anti-Virus is not installed, the script will return
  # a result of "Sophos Anti-Virus Not Installed"

  result="Sophos Anti-Virus Not Installed"
fi

echo "<result>$result</result>"