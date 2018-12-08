#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the scripts stored on a Jamf Pro server then do the following:
#
# 1. Download the script as XML
# 2. Identify the script name
# 3. Extract the script contents from the downloaded XML
# 4. Save the script to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Scripts: Read

# If you choose to specify a directory to save the downloaded scripts into,
# please enter the complete directory path into the ScriptDownloadDirectory
# variable below.

ScriptDownloadDirectory=""

# If the ScriptDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$ScriptDownloadDirectory" ]]; then
   ScriptDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded scripts has not been specified."
   echo "Downloaded scripts will be stored in $ScriptDownloadDirectory."
fi

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

# Remove the trailing slash from the ScriptDownloadDirectory variable if needed.
ScriptDownloadDirectory=${ScriptDownloadDirectory%%/}

DownloadScript(){

	# Download the script information as raw XML,
	# then format it to be readable.
	echo "Downloading scripts from $jamfpro_url..."
	FormattedScript=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/scripts/id/${ID}" -X GET | xmllint --format - )

	# Identify and display the script's name.
	DisplayName=$(echo "$FormattedScript" | xpath "/script/name/text()" 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded script is named: $DisplayName"
	
	## Save the downloaded script 
	echo "Saving ${DisplayName} file to $ScriptDownloadDirectory."
	echo "$FormattedScript" | xpath '/script/script_contents/text()' 2>/dev/null | sed -e 's/&lt;/</g' -e 's/&gt;/>/g' -e 's/&quot;/"/g' -e 's/&amp;/\&/g' > "$ScriptDownloadDirectory/${DisplayName}"

}

Script_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/scripts" | xpath "//id" 2>/dev/null)

Script_id=$(echo "$Script_id_list" | grep -Eo "[0-9]+")

for ID in ${Script_id}; do

   DownloadScript

done