#!/bin/bash

# Updates asset tag information in Jamf Pro.

# This script reads a .csv file formatted as follows:
#
# "Serial number, Asset number" as the first line
# 
# Subsequent lines:
# Column 1: A Mac's serial number
# Column 2: An inventory asset code
# 
# Example:
#
# Serial number, Asset number
# W8810X481AX,1652
# W89020U8289,1978
# CK1243R4DB6,2011
#
# This script is designed to run as shown below:
#
# /path/to/Jamf_Pro_Inventory_Asset_Tag_Update.sh filename_goes_here.csv
#
# Once executed, the script will then do the following:
#
# Skip the first line of the .csv file (this is the "Serial number, Asset number" line.)
# Read each subsequent line of the .csv one at a time and assign the values of column 1
# and column 2 to separate variables.
#
# Use the variables in an API PUT call to identify a Jamf Pro 
# computer inventory record using the serial number listed in 
# the .csv file and populate the asset tag information using
# the inventory asset code listed in the .csv file.
#
# Display HTTP return code and API output
# 
# Successful asset update should produce output similar to that shown below:
#
# Successfully updated computer record with serial number W8810X481AX with asset number 1652
# Successfully updated computer record with serial number W89020U8289 with asset number 1978
# Successfully updated computer record with serial number CK1243R4DB6 with asset number 2011
#
# If setting up an API client with limited rights, here are the required API role privileges
# for the API client on the Jamf Pro server:
#
# Read Computers, Update Computers

GetJamfProAPIToken() {

# This function uses the API client ID and client ID secret to get a new bearer token for API authentication.

if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/v1/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | python -c 'import sys, json; print json.load(sys.stdin)["access_token"]')
else
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/v1/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | plutil -extract access_token raw -)
fi

}

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

jamfpro_plist="$HOME/Library/Preferences/com.github.jamfpro-info.plist"
filename="$1"
exitCode=0

if [[ -r "$jamfpro_plist" ]]; then

     if [[ -z "$jamfpro_url" ]]; then
          jamfpro_url=$(defaults read "${jamfpro_plist%.*}" jamfpro_url)
     fi

     if [[ -z "$jamfpro_api_client_id" ]]; then
          jamfpro_api_client_id=$(defaults read "${jamfpro_plist%.*}" jamfpro_api_client_id)
     fi

     if [[ -z "$jamfpro_api_client_secret" ]]; then
          jamfpro_api_client_secret=$(defaults read "${jamfpro_plist%.*}" jamfpro_api_client_secret)
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

echo ""

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

if [[ -n $filename && -r $filename ]]; then

	while IFS=, read serial_number asset_number || [ -n "$serial_number" ]; do
	
		GetJamfProAPIToken

		# Set the expected HTTP response code for a successful API call to update the asset tag information.
		APISuccess="204"

		# Set the correct URL for looking up the computer inventory record associated with the specified serial number.   
		jamfproSerialURL="${jamfpro_url}/api/v3/computers-inventory?filter=hardware.serialNumber=="
		
		# Set the correct URL for looking up the computer associated with the specified Jamf Pro device ID.
		jamfproIDURL="${jamfpro_url}/api/v3/computers-inventory-detail"

		# Look up the computer inventory record associated with the specified serial number and get the Jamf Pro device ID.
		jamfproID=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfproSerialURL}${serial_number}" -H "Accept: application/json" | /usr/bin/plutil -extract results.0.id raw - 2>/dev/null)

		# Format a block of JSON and use %s to specify where printf should print a specified variable.
		JSONBlockFormat='{"general":{"assetTag":"%s"}}'

		# Use printf to create the needed JSON block and write the asset_number variable in the correct place in the JSON block.
		JSONBlock=$(printf "$JSONBlockFormat" "$asset_number")
		
		# Send an API command to update the computer inventory record with the specified asset tag information and read back the HTTP response code.
		apiResponse=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" "${jamfproIDURL}/$jamfproID" -w "<http_status>%{http_code}</http_status>" -H "Content-Type: application/json" -X PATCH -d "$JSONBlock")
		 
		responseCode=$(echo "$apiResponse" | /usr/bin/sed -n 's/.*<http_status>\([^<]*\).*/\1/p')

		# If the API call returns an HTTP response which matches the APISuccess variable, the API call succeeded and the asset tag information
		# should be updated in the computer inventory record. Script reports a successful update.
		# 
		# If the HTTP response code does not match the APISuccess variable, script report a failed asset tag update.
        
		if [[ "$responseCode" != "$APISuccess" ]]; then
			echo "Update of computer record with serial number $serial_number failed with http error $responseCode"
		else
			echo "Successfully updated computer record with serial number $serial_number with asset number $asset_number"
		fi

	done < <(tail -n +2 "$filename")
  
else
	echo "Input file does not exist or is not readable"
	exitCode=1
fi

exit "$exitCode"