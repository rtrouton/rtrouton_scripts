#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the mobile device groups stored on a Jamf Pro server then do the following:
#
# 1. Download the group information as XML
# 2. Remove the group membership from the downloaded XML
# 3. Identify the group name
# 4. Categorize the downloaded group as either a smart or static mobile device group
# 4. Save the XML to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Smart Mobile Device Groups: Read
# Static Mobile Device Groups: Read

# If you choose to specify a directory to save the downloaded groups into,
# please enter the complete directory path into the MobileDeviceGroupDownloadDirectory
# variable below.

MobileDeviceGroupDownloadDirectory=""

# If the MobileDeviceGroupDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$MobileDeviceGroupDownloadDirectory" ]]; then
   MobileDeviceGroupDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded groups has not been specified."
   echo "Downloaded groups will be stored in $MobileDeviceGroupDownloadDirectory."
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

# Remove the trailing slash from the MobileDeviceGroupDownloadDirectory variable if needed.
MobileDeviceGroupDownloadDirectory=${MobileDeviceGroupDownloadDirectory%%/}

DownloadMobileDeviceGroup(){

	# Download the profile as encoded XML, then decode and format it
	echo "Downloading mobile device group from $jamfpro_url..."
	FormattedMobileDeviceGroup=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledevicegroups/id/${ID}" -X GET | tr $'\n' $'\t' | sed -E 's|<mobile_devices>.*</mobile_devices>||' |  tr $'\t' $'\n' | xmllint --format - )

	# Identify and display the profile's name
	DisplayName=$(echo "$FormattedMobileDeviceGroup" | xpath "/mobile_device_group/name/text()" 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded mobile device group is named: $DisplayName"
	
	if [[ $(echo "$FormattedMobileDeviceGroup" | xpath "/mobile_device_group/is_smart/text()" 2>/dev/null) == "true" ]]; then
	   GroupType="Smart"
	else
	   GroupType="Static"
	fi

	## Save the downloaded mobile device group
	echo "$DisplayName is a $GroupType group."
	echo "Saving ${DisplayName}.xml file to $MobileDeviceGroupDownloadDirectory/$GroupType Groups."
	if [[ "$GroupType" = "Smart" ]]; then
	   if [[ -d "$MobileDeviceGroupDownloadDirectory/$GroupType Groups" ]]; then
          echo "$FormattedMobileDeviceGroup" > "$MobileDeviceGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml" 
        else
           mkdir -p "$MobileDeviceGroupDownloadDirectory/$GroupType Groups"
           echo "$FormattedMobileDeviceGroup" > "$MobileDeviceGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml"
        fi
    elif [[ "$GroupType" = "Static" ]]; then
        if [[ -d "$MobileDeviceGroupDownloadDirectory/$GroupType Groups" ]]; then
          echo "$FormattedMobileDeviceGroup" > "$MobileDeviceGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml" 
        else
          mkdir -p "$MobileDeviceGroupDownloadDirectory/$GroupType Groups"
          echo "$FormattedMobileDeviceGroup" > "$MobileDeviceGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml"
        fi
    fi

}

MobileDeviceGroup_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledevicegroups" | xpath "//id" 2>/dev/null)

MobileDeviceGroup_id=$(echo "$MobileDeviceGroup_id_list" | grep -Eo "[0-9]+")

for ID in ${MobileDeviceGroup_id}; do

   DownloadMobileDeviceGroup

done