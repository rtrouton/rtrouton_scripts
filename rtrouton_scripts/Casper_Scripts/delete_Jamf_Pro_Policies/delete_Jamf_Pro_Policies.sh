#!/bin/bash

##########################################################################################
# 	Policy Delete Script for Jamf Pro
#
#	Usage: Call script with the following four parameters
#			- a text file of the Jamf Pro policy IDs you wish to delete
#			- The URL of the appropriate Jamf Pro server
#			- username for an account on the Jamf Pro server with sufficient API privileges
#			- password for the account on the Jamf Pro server
#
#	Example:	./delete_Jamf_Pro_Policies.sh jamf_pro_id_numbers.txt
#
##########################################################################################

filename="$1"
ERROR=0

if [[ -n $filename && -r $filename ]]; then

	read -p "Please enter your Jamf Pro server URL : " jamfproURL
	read -p "Please enter your Jamf Pro user account : " username
	read -p "Please enter the password for the $username account:  " -s password
	echo ""

	# Remove the trailing slash from the Jamf Pro URL if needed.
	jamfproURL=${jamfproURL%%/}

	# Set up the Jamf Pro Policy ID URL
	jamfproIDURL="${jamfproURL}/JSSResource/policies/id"

	while read -r ID
	do

		# Verify that the input is a number. All Jamf Pro
		# IDs are positive numbers, so any other input will
		# not be a valid Jamf Pro ID.

		if [[ "$ID" =~ ^[0-9]+$ ]]; then

		  # Remove comment from line below to preview
		  # the results of the deletion command.

		  echo -e "\ncurl -X DELETE ${jamfproIDURL}/$ID"

		  # Remove comment from line below to actually run
		  # the deletion command.

		  /usr/bin/curl -X DELETE "${jamfproIDURL}/$ID" -u $username:${password}
		  
		  if [[ $? -eq 0 ]]; then
	         echo -e "\nDeleted policy ID $ID."
		  else
	         echo -e "\nERROR! Failed to delete policy ID $ID."
		  fi

		else
		   echo "All Jamf Pro IDs are expressed as numbers. The following input is not a number: $ID"
		fi
	done < "$filename"

else
	echo "Input file does not exist or is not readable"
	ERROR=1
fi

exit "$ERROR"