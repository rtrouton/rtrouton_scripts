#!/bin/bash

##########################################################################################
# 	Packages Delete Script for Jamf Pro
#
#
#	Usage: Call script with the following four parameters
#			- a text file of the Jamf Pro package IDs you wish to delete
#
#	You will be prompted for:
#			- The URL of the appropriate Jamf Pro server
#			- Username for an account on the Jamf Pro server with sufficient API privileges
#			- Password for the account on the Jamf Pro server
#
#	The script will:
#			- Delete the specified packages using their Jamf Pro package IDs
#			- Generate a report of all successfully deleted packages in TSV format
#
#	Example:	./delete_Jamf_Pro_Packages.sh jamf_pro_id_numbers.txt
#
##########################################################################################

filename="$1"
ERROR=0
report_file="$(mktemp).tsv"

if [[ -n $filename && -r $filename ]]; then

	# If you choose to hardcode API information into the script, uncomment the lines below
	# and set one or more of the following values:
	#
	# The username for an account on the Jamf Pro server with sufficient API privileges
	# The password for the account
	# The Jamf Pro URL

	#jamfpro_url=""	## Set the Jamf Pro URL here if you want it hardcoded.
	#jamfpro_user=""		## Set the username here if you want it hardcoded.
	#jamfpro_password=""		## Set the password here if you want it hardcoded.


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

	     if [[ -z "$jamfpro_url" ]]; then
	          jamfpro_url=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
	     fi

	     if [[ -z "$jamfpro_user" ]]; then
	          jamfpro_user=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user)
	     fi

	     if [[ -z "$jamfpro_password" ]]; then
	          jamfpro_password=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password)
	     fi

	fi

	# If the Jamf Pro URL, the account username or the account password aren't available
	# otherwise, you will be prompted to enter the requested URL or account credentials.

	if [[ -z "$jamfpro_url" ]]; then
	     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
	fi

	if [[ -z "$jamfpro_user" ]]; then
	     read -p "Please enter your Jamf Pro user account : " jamfpro_user
	fi

	if [[ -z "$jamfpro_password" ]]; then
	     read -p "Please enter the password for the $jamfpro_user account: " -s jamfpro_password
	fi

	echo ""

	# Remove the trailing slash from the Jamf Pro URL if needed.
	jamfpro_url=${jamfpro_url%%/}

	# Set up the Jamf Pro Computer ID URL
	jamfproIDURL="${jamfpro_url}/JSSResource/packages/id"

	while read -r PackagesID
	do

		# Verify that the input is a number. All Jamf Pro
		# IDs are positive numbers, so any other input will
		# not be a valid Jamf Pro ID.

		if [[ "$PackagesID" =~ ^[0-9]+$ ]]; then
		
		  if [[ ! -f "$report_file" ]]; then
			/usr/bin/touch "$report_file"
			printf "Deleted Package ID Number\tDeleted Package Name\n" > "$report_file"
		  fi

		  # Get package display name
		  
		  PackagesName=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/packages/id/$PackagesID" | xmllint --xpath '//package/name/text()' - 2>/dev/null)
		  
		  # Remove comment from line below to preview
		  # the results of the deletion command.

		  echo -e "Deleting $PackagesName - package ID $PackagesID."

		  # Remove comment from line below to actually run
		  # the deletion command.

		  #/usr/bin/curl -su ${jamfpro_user}:${jamfpro_password} "${jamfproIDURL}/$PackagesID" -X DELETE
		  
		  if [[ $? -eq 0 ]]; then
	         printf "$PackagesID\t %s\n" "$PackagesName" >> "$report_file"
	         echo -e "\nDeleted $PackagesName - package ID $PackagesID.\n"
		  else
	         echo -e "\nERROR! Failed to delete $PackagesName - package ID $PackagesID.\n"
		  fi

		else
		   echo "All Jamf Pro IDs are expressed as numbers. The following input is not a number: $PackagesID"
		fi
	done < "$filename"

else
	echo "Input file does not exist or is not readable"
	ERROR=1
fi

if [[ -f "$report_file" ]]; then
     echo "Report on deleted installer packages available here: $report_file"
fi

exit "$ERROR"