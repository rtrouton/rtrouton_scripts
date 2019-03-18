#!/bin/bash

# If you choose to specify a directory to save the downloaded profiles into,
# please enter the complete directory path into the ProfileDownloadDirectory
# variable below.

ProfileDownloadDirectory=""

# If the ProfileDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$ProfileDownloadDirectory" ]]; then
   ProfileDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded profiles has not been specified."
   echo "Downloaded profiles will be stored in $ProfileDownloadDirectory."
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

# Read the appropriate values from ~/Library/Preferences/corp.sap.jamfcloud-info.plist
# if the file is available. To create the file, run the following commands:
#
# defaults write $HOME/Library/Preferences/corp.sap.jamfcloud-info jamfpro_url https://jamf.pro.server.here
# defaults write $HOME/Library/Preferences/corp.sap.jamfcloud-info jamfpro_user API_account_username_goes_here
# defaults write $HOME/Library/Preferences/corp.sap.jamfcloud-info jamfpro_password API_account_password_goes_here
#

if [[ -f "$HOME/Library/Preferences/corp.sap.jamfcloud-info.plist" ]]; then
     jamfpro_user=$(defaults read $HOME/Library/Preferences/corp.sap.jamfcloud-info jamfpro_user)
     jamfpro_password=$(defaults read $HOME/Library/Preferences/corp.sap.jamfcloud-info jamfpro_password)
     jamfpro_url=$(defaults read $HOME/Library/Preferences/corp.sap.jamfcloud-info jamfpro_url)
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

# Remove the trailing slash from the ProfileDownloadDirectory variable if needed.
ProfileDownloadDirectory=${ProfileDownloadDirectory%%/}

DownloadProfile(){

	# Download the profile as encoded XML, then decode and format it
	echo "Downloading Configuration Profile..."
	FormattedProfile=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledeviceconfigurationprofiles/id/${ID}" -X GET | xpath '/configuration_profile/general/payloads/text()' 2>/dev/null | perl -MHTML::Entities -pe 'decode_entities($_);' | xmllint --format -)

	# Identify and display the profile's name
	DisplayName=$(echo "$FormattedProfile" | awk -F'>|<' '/PayloadDisplayName/{getline; print $3; exit}')
	echo "Downloaded profile is named: $DisplayName"

	## Save the downloaded profile to 
	echo "Saving ${DisplayName}.mobileconfig file to $ProfileDownloadDirectory."
	echo "$FormattedProfile" > "$ProfileDownloadDirectory/${DisplayName}.mobileconfig"

}

profiles_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledeviceconfigurationprofiles" | xpath //configuration_profile/id 2>/dev/null)

profiles_id=$(echo "$profiles_id_list" | grep -Eo "[0-9]+")

for ID in ${profiles_id}; do

   DownloadProfile

done
