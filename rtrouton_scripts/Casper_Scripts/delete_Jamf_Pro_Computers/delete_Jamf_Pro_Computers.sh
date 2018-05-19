#!/bin/bash

##########################################################################################
# 	Computer Delete Script for Jamf Pro
#
#	Original script by Randy Saeks:
#	https://github.com/rsaeks/scripts/blob/master/delMobileDevice.sh
#
#	Please create a backup of the Jamf Pro database prior to deleting computers
#
#	Usage: Call script with the following four parameters
#			- a text file containing the Jamf Pro IDs of the computer(s) you wish to delete.
#			- The URL of the appropriate Jamf Pro server
#			- username for an account on the Jamf Pro server with sufficient privileges
#			  to delete computers from the Jamf Pro server.
#			- password for the account on the Jamf Pro server
#
#	Example:	./delete_Jamf_Pro_Computers.sh jamf_pro_id_numbers.txt
#
##########################################################################################

filename="$1"
ERROR=0

if [[ -n $filename && -r $filename ]]; then

	# If you choose to hardcode API information into the script, uncomment the lines below
	# and set one or more of the following values:
	#
	# The username for an account on the Jamf Pro server with sufficient API privileges
	# The password for the account
	# The Jamf Pro URL

	#jamfproURL=""	## Set the Jamf Pro URL here if you want it hardcoded.
	#apiUser=""		## Set the username here if you want it hardcoded.
	#apiPass=""		## Set the password here if you want it hardcoded.


	# If you do not want to hardcode API information into the script, you can also store
	# these values in a ~/Library/Preferences/com.github.jamfpro-info.plist file.
	#
	# To create the file and set the values, run the following commands and substitute
	# your own values where appropriate:
	#
	# To store the Jamf Pro URL in the plist file:
	# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
	#
	# To store the account username in the plist file:
	# defaults write com.github.jamfpro-info jamfpro_user account_username_goes_here
	#
	# To store the account password in the plist file:
	# defaults write com.github.jamfpro-info jamfpro_password account_password_goes_here
	#
	# If the com.github.jamfpro-info.plist file is available, the script will read in the
	# relevant information from the plist file.

	if [[ -f "$HOME/Library/Preferences/com.github.jamfpro-info.plist" ]]; then

	     if [[ -z "$jamfproURL" ]]; then
	          jamfproURL=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
	     fi

	     if [[ -z "$apiUser" ]]; then
	          apiUser=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user)
	     fi

	     if [[ -z "$apiPass" ]]; then
	          apiPass=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password)
	     fi

	fi

	# If the Jamf Pro URL, the account username or the account password aren't available
	# otherwise, you will be prompted to enter the requested URL or account credentials.

	if [[ -z "$jamfproURL" ]]; then
	     read -p "Please enter your Jamf Pro server URL : " jamfproURL
	fi

	if [[ -z "$apiUser" ]]; then
	     read -p "Please enter your Jamf Pro user account : " apiUser
	fi

	if [[ -z "$apiPass" ]]; then
	     read -p "Please enter the password for the $apiUser account: " -s apiPass
	fi
	
	echo ""

	# Remove the trailing slash from the Jamf Pro URL if needed.

	jamfproURL=${jamfproURL%%/}

	# Set up the Jamf Pro Computer ID URL
	jamfproIDURL="${jamfproURL}/JSSResource/computers/id"

	while read -r ID
	do

		# Verify that the input is a number. All Jamf Pro
		# IDs are positive numbers, so any other input will
		# not be a valid Jamf Pro ID.

		if [[ "$ID" =~ ^[0-9]+$ ]]; then

		  # The line below previews the results of the 
		  # deletion command. Comment out the line below
		  # if this preview is not desired.

		  echo "curl -X DELETE ${jamfproIDURL}/$ID"

		  # The line below runs the deletion command.
		  # Comment out the line below if you want to
		  # only simulate running the deletion command.

		  curl -X DELETE "${jamfproIDURL}/$ID" -u $apiUser:${apiPass}

		else
		   echo "All Jamf Pro IDs are expressed as numbers. The following input is not a number: $ID"
		fi
	done < "$filename"

else
	echo "Input file does not exist or is not readable"
	ERROR=1
fi

exit "$ERROR"