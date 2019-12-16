#!/bin/bash

# Parts of this script taken from a script by Richard Purves
# https://github.com/franton/JSS-API-Wipe

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the computer policies stored on a Jamf Pro server then do the following:
#
# Disable the policy
# Display HTTP return code and API output
# 
# Successful policy disabling should produce output similar to that shown below:
#
# 201	<?xml version="1.0" encoding="UTF-8"?><policy><id>1</id></policy>
#
# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Policies: Read, Update

# If you choose to hardcode API information into the script, set one or more of the following values:
#
# The username for an account on the Jamf Pro server with sufficient API privileges
# The password for the account
# The Jamf Pro URL

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""	    

# Set the username here if you want it hardcoded.
jamfpro_user=""

# Set the password here if you want it hardcoded.
jamfpro_password=""	

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
PLIST="$HOME/Library/Preferences/com.github.jamfpro-info.plist"

if [[ -r "$PLIST" ]]; then

     if [[ -z "$jamfpro_url" ]]; then
          jamfpro_url=$(defaults read "${PLIST%.*}" jamfpro_url)
     fi

     if [[ -z "$jamfpro_user" ]]; then
          jamfpro_user=$(defaults read "${PLIST%.*}" jamfpro_user)
     fi

     if [[ -z "$jamfpro_password" ]]; then
          jamfpro_password=$(defaults read "${PLIST%.*}" jamfpro_password)
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

# THIS IS YOUR LAST CHANCE TO PUSH THE CANCELLATION BUTTON

echo -e "\n"
echo "You are about to disable ALL policies on $jamfpro_url"
echo "Are you completely sure you want to do this?"
read -p "(Default is NO. Type YES to go ahead) : " arewesure

# Check for the skip
if [[ $arewesure != "YES" ]];
then
	echo "OK. Quitting now without any disabling any policies on $jamfpro_url."
	exit 0
fi

# OK DO IT

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

DisableComputerPolicy(){

curloutput=$(mktemp)

echo "Disabling policy ID number $ID."
curl --write-out '%{http_code}\t' --silent --output "$curloutput" -H "Content-Type: application/xml" -X PUT -d '<policy><general><enabled>false</enabled></general></policy>' "$jamfpro_url"/JSSResource/policies/id/"$ID" --user "$jamfpro_user:$jamfpro_password"
printf "$(cat "$curloutput")\n"
}

# Set exit code for script

exitcode=0

ComputerPolicy_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xpath "//id" 2>/dev/null)

if [[ -n "$ComputerPolicy_id_list" ]]; then

	echo "Downloading computer policy list from $jamfpro_url..."
	ComputerPolicy_id=$(echo "$ComputerPolicy_id_list" | grep -Eo "[0-9]+")

	for ID in ${ComputerPolicy_id}; do
	   DisableComputerPolicy
	done
	
else
	echo "ERROR! Unable to get computer policy list"
	exitcode=1
fi


# All done!
echo ""
echo "Operation completed."
exit "$exitcode"