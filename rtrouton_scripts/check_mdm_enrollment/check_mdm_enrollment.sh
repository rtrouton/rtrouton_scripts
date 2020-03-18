#!/bin/bash

# Check MDM server enrollment

# This script checks to see if this Mac has an MDM enrollment profile. 
# If one is present, the MDM server's DNS address is displayed.

exitCode=1

# This script must run with root privileges

if [[ "$(/usr/bin/id -u)" -eq 0 ]]; then

  # Check to see if Mac is enrolled in an MDM server.

  if [[ -n "$(profiles list -output stdout-xml | awk '/com.apple.mdm/ {print $1}' | tail -1)" ]]; then

	 # If enrolled in an MDM server, get the MDM profile's xml representation

	profileXML=$(/usr/bin/profiles list -output stdout-xml | /usr/bin/xmllint --xpath '//dict[key = "_computerlevel"]/array/dict[key = "ProfileItems"]/array/dict[key = "PayloadType" and string = "com.apple.mdm"]' - 2>/dev/null)
	
	if [[ -n "$profileXML" ]]; then
	
		mdmURL=$(echo "$profileXML" | /usr/bin/xmllint --xpath '//dict[key = "PayloadContent"]/dict/key[text() = "ServerURL"]/following-sibling::string[1]/text()' - 2>/dev/null)

		if [[ -n "$mdmURL" ]]; then
			displayMDM=$(echo "$mdmURL" | awk -F '/' '{print $3}' )
			echo "MDM server address: $displayMDM"
			exitCode=0
	
		else
			echo "Failed to get MDM URL!"
		fi
		
	else
		echo "Failed read MDM profile!"
	fi
  
    else 
        echo "Not enrolled in an MDM server."
        exitCode=0
   fi
else
	echo "You must be root in order to run this script!"
fi

exit $exitCode