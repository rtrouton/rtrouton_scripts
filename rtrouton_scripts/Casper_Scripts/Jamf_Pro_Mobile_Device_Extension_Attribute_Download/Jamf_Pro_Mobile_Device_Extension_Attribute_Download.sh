#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the mobile device extension attributes stored on a Jamf Pro server then do the following:
#
# 1. Download the extension attribute as XML
# 2. Identify the extension attribute name
# 4. Categorize the downloaded extension attribute
# 4. Save the extension attribute to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Mobile Device Extension Attributes: Read

# If you choose to specify a directory to save the downloaded extension attributes into,
# please enter the complete directory path into the ExtensionAttributeDownloadDirectory
# variable below.

ExtensionAttributeDownloadDirectory=""

# If the ExtensionAttributeDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$ExtensionAttributeDownloadDirectory" ]]; then
   ExtensionAttributeDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded groups has not been specified."
   echo "Downloaded groups will be stored in $ExtensionAttributeDownloadDirectory."
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

# Remove the trailing slash from the ExtensionAttributeDownloadDirectory variable if needed.
ExtensionAttributeDownloadDirectory=${ExtensionAttributeDownloadDirectory%%/}

xpath() {
    # xpath in Big Sur changes syntax
    # For details, please see https://scriptingosx.com/2020/10/dealing-with-xpath-changes-in-big-sur/
    if [[ $(sw_vers -buildVersion) > "20A" ]]; then
        /usr/bin/xpath -e "$@"
    else
        /usr/bin/xpath "$@"
    fi
}

DownloadMobileDeviceExtensionAttribute(){

	# Download the extension attribute information as raw XML,
	# then format it to be readable.
	echo "Downloading extension attributes from $jamfpro_url..."
	FormattedMobileDeviceExtensionAttribute=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledeviceextensionattributes/id/${ID}" -X GET | tr $'\n' $'\t' | sed -E 's|<mobile_device_extension_attributes>.*</mobile_device_extension_attributes>||' |  tr $'\t' $'\n' | xmllint --format - )

	# Identify and display the extension attribute's name.
	DisplayName=$(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/name/text()" 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded extension attribute is named: $DisplayName"
	
	# Identify the EA type.
	if [[ $(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/data_type/text()" 2>/dev/null) == "Date" ]]; then
	   EAType="Date"
	elif [[ $(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/data_type/text()" 2>/dev/null) == "Integer" ]]; then
	   EAType="Integer"
	elif [[ $(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/data_type/text()" 2>/dev/null) == "String" ]]; then
	   EAType="String"
	fi

	# Save the downloaded extension attribute.
	echo "$DisplayName is a $EAType extension attribute."
	echo "Saving ${DisplayName}.xml file to $ExtensionAttributeDownloadDirectory/$EAType."

	if [[ "$EAType" = "Date" ]]; then
        
       EAInputType=$(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/input_type/type/text()" 2>/dev/null)

           if [[ -d "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType" ]]; then
             echo "$FormattedMobileDeviceExtensionAttribute" > "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType/${DisplayName}.xml" 
           else
             mkdir -p "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType"
             echo "$FormattedMobileDeviceExtensionAttribute" > "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType/${DisplayName}.xml"
           fi
    fi
    
    if [[ "$EAType" = "Integer" ]]; then
        
       EAInputType=$(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/input_type/type/text()" 2>/dev/null)

           if [[ -d "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType" ]]; then
             echo "$FormattedMobileDeviceExtensionAttribute" > "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType/${DisplayName}.xml" 
           else
             mkdir -p "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType"
             echo "$FormattedMobileDeviceExtensionAttribute" > "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType/${DisplayName}.xml"
           fi
    fi
    
    if [[ "$EAType" = "String" ]]; then
        
       EAInputType=$(echo "$FormattedMobileDeviceExtensionAttribute" | xpath "/mobile_device_extension_attribute/input_type/type/text()" 2>/dev/null)

           if [[ -d "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType" ]]; then
             echo "$FormattedMobileDeviceExtensionAttribute" > "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType/${DisplayName}.xml" 
           else
             mkdir -p "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType"
             echo "$FormattedMobileDeviceExtensionAttribute" > "$ExtensionAttributeDownloadDirectory/$EAType/$EAInputType/${DisplayName}.xml"
           fi
    fi

}

MobileDeviceExtensionAttribute_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledeviceextensionattributes" | xpath "//id" 2>/dev/null)

MobileDeviceExtensionAttribute_id=$(echo "$MobileDeviceExtensionAttribute_id_list" | grep -Eo "[0-9]+")

for ID in ${MobileDeviceExtensionAttribute_id}; do

   DownloadMobileDeviceExtensionAttribute

done