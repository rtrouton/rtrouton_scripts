#!/bin/bash

# This script is designed to clear failed MDM commands from a Jamf Pro smart or static mobile device group. 
# Clearing the failed commands allows failed MDM commands or profiles to be re-pushed automatically.
#
# This script is designed to use API client authentication, where the associated API role has the 
# following permission assigned:
#
# Flush MDM Commands
# Read Smart Mobile Device Groups
# Read Static Mobile Device Groups

# Set exit error status

error=0

# If you choose to hardcode the Jamf Pro ID of the smart or static mobile device group whose members you want to clear
# failed MDM commands from, please set it using the groupID variable below.
#
# For example, if the Jamf Pro ID of the mobile device group in question is 1, you would set the groupID variable as
# shown below:
#
# groupID="1"
#
# If you do not set the groupID variable below, the script will prompt you for the Jamf Pro ID of the group.

groupID=""

# If you choose to hardcode API information into the script, set one or more of the following values:
#
# The Jamf Pro URL
# An API client ID on the Jamf Pro server with sufficient API privileges
# The API client secret for the API client ID

# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""	    

# Set the Jamf Pro API Client ID here if you want it hardcoded.
jamfpro_api_client_id=""

# Set the Jamf Pro API Client Secret here if you want it hardcoded.
jamfpro_api_client_secret=""	

# If you do not want to hardcode API information into the script, you can also store
# these values in a ~/Library/Preferences/com.github.jamfpro-info.plist file.
#
# To create the file and set the values, run the following commands and substitute
# your own values where appropriate:
#
# To store the Jamf Pro URL in the plist file:
# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the Jamf Pro API Client ID in the plist file:
# defaults write com.github.jamfpro-info jamfpro_api_client_id api_client_id_information_goes_here
#
# To store the Jamf Pro API Client Secret in the plist file:
# defaults write com.github.jamfpro-info jamfpro_api_client_secret api_client_secret_information_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will read in the
# relevant information from the plist file.

if [[ -f "$HOME/Library/Preferences/com.github.jamfpro-info.plist" ]]; then

  if [[ -z "$jamfpro_url" ]]; then
     jamfpro_url=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
  fi     

  if [[ -z "$jamfpro_api_client_id" ]]; then
     jamfpro_api_client_id=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_api_client_id)
  fi
  
  if [[ -z "$jamfpro_api_client_secret" ]]; then
     jamfpro_api_client_secret=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_api_client_secret)
  fi

fi

# If the Jamf Pro URL, the API Client ID or the API Client Secret aren't available
# otherwise, you will be prompted to enter the requested URL or API client credentials.

if [[ -z "$jamfpro_url" ]]; then
     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_api_client_id" ]]; then
     read -p "Please enter your Jamf Pro API client ID : " jamfpro_api_client_id
fi

if [[ -z "$jamfpro_api_client_secret" ]]; then
     read -p "Please enter the API client secret for the $jamfpro_api_client_id API ID client: " -s jamfpro_api_client_secret
fi

# If the Jamf Pro ID of the smart or static mobile device group whose members you want to clear failed 
# MDM commands from has not been provided, you will be prompted to enter the Jamf Pro ID of the smart
# or static mobile device group.

if [[ -z "$groupID" ]]; then
     echo ""
     echo ""
     echo "The smart or static mobile device group you want to clear failed MDM commands from has not been specified."
     echo ""
     read -p "Please enter the Jamf Pro ID of the smart or static mobile device group : " groupID
fi

echo ""

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

GetJamfProAPIToken() {

# This function uses the API client ID and client ID secret to get a new bearer token for API authentication.

if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | python -c 'import sys, json; print json.load(sys.stdin)["access_token"]')
else
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | plutil -extract access_token raw -)
fi

}

# This function uses the Jamf Pro Classic API to get the display name of a specified Jamf Pro smart or static mobile device group.

GetGroupDisplayName () {

groupName=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledevicegroups/id/${groupID}" | xmllint --xpath '//mobile_device_group/name/text()' - 2>/dev/null)

}

# This function uses the Jamf Pro Classic API to clear all failed MDM commands associated with the
# members of a specified Jamf Pro smart or static mobile device group.

ClearFailedMDMCommandsFromGroup () {

/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/commandflush/mobiledevicegroups/id/${groupID}/status/Failed" -X DELETE

}



# Get a Jamf Pro API token, then use the token to authenticate clearing all failed MDM commands
# associated with the members of the smart or static mobile device group specified by the "groupID"
# variable of this script.

if [[ "$groupID" =~ ^[0-9]+$ ]]; then
    GetJamfProAPIToken
    GetGroupDisplayName

    # Verify that the group name lookup has succeeded. If it doesn't, then the group ID entered
    # is not used by a current smart or static mobile device group.
    
    if [[ -n ${groupName} ]]; then

         # If the group name lookup has succeeded, clear failed MDM commands from the
         # specified Jamf Pro smart or static mobile device group.
          
         echo "Clearing failed MDM commmands from members of the following group: ${groupName}"
         ClearFailedMDMCommandsFromGroup
           if [[ 0 -eq $? ]]; then
             echo ""
             echo "Failed MDM commands successfully cleared from members of the following group: ${groupName}"
           else
             echo "ERROR: MDM commands failed to be cleared from members of the following group: ${groupName}"
             error=1
           fi
    else
         echo "ERROR: Jamf Pro ID $groupID is not used by a current smart or static mobile device group."
         error=1
    fi
else
   echo "ERROR: $groupID is not a valid Jamf Pro ID number."
   echo "Please verify value entered for the Jamf Pro ID of the smart or static mobile device group."
   error=1
fi

exit "$error"