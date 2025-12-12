#!/bin/bash

# This script imports a list of Jamf Pro ID numbers from a plaintext file 
# and uses that information to set the computers' management status to Managed.
#
# Usage: /path/to/Set_Jamf_Pro_Computers_To_Managed_Status.sh jamf_pro_id_numbers.txt
#
# Once the Jamf Pro ID numbers are read from in from the plaintext file, the script takes the following actions:
#
# 1. Uses the Jamf Pro API to download all information about the matching computer inventory record in XML format.
# Once the Jamf Pro ID numbers are read from in from the plaintext file, the script takes the following actions:
#
# 1. Uses the Jamf Pro API to download information about the matching computer inventory record in XML format.
# 2. Pulls the following information out of the inventory entry:
#
#    Manufacturer
#    Model
#    Serial Number
#    Hardware UDID
#    Management status
#
# 3. If the management status is set to "Unmanaged", runs a separate API call to set the management status in the computer inventory record to "Managed".
#
# 4. Create a report in tab-separated value (.tsv) format which contains the following information
#    about the relevant Macs
#
#    Jamf Pro ID
#    Manufacturer
#    Model
#    Serial Number
#    Hardware UDID
#    Computer Management Status
#    Jamf Pro URL for the computer inventory record
#
#
# If setting up an API client with limited rights, here are the required API role privileges
# for the API client on the Jamf Pro server:
#
# Read Computers
# Update Computers
# Update User

exitCode=0
filename="$1"

if [[ -n $filename && -r $filename ]]; then

report_file="$(mktemp).tsv"

GetJamfProAPIToken() {

# This function uses the API client ID and client ID secret to get a new bearer token for API authentication.

if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/v1/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | python -c 'import sys, json; print json.load(sys.stdin)["access_token"]')
else
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/v1/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | plutil -extract access_token raw -)
fi

}

ComputerInventoryRecordManagementUpdateToManaged() {

# Set computer inventory record to managed.

managementStatus="true"

# Format a block of JSON and use %s to specify where printf should print a specified variable.
JSONBlockFormat='{"general":{"managed":"%s"}}'

# Use printf to create the needed JSON block and write the managementStatus variable in the correct place in the JSON block.
JSONBlock=$(printf "$JSONBlockFormat" "$managementStatus")
		
# Get a bearer token and send an API command to update the computer inventory record with the specified management setting and read back the HTTP response code.

GetJamfProAPIToken

apiResponse=$(/usr/bin/curl -s -o /dev/null --header "Authorization: Bearer ${api_token}" "${jamfproIDURL}/$ID" -w "%{http_code}" -H "Content-Type: application/json" -X PATCH -d "$JSONBlock")

responseCode=$(echo "$apiResponse")
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

# Set up the Jamf Pro Computer ID URL
jamfproIDURL="${jamfpro_url}/api/v3/computers-inventory-detail"

progress_indicator() {
  spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  while :
  do
    for i in $(seq 0 7)
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      sleep 0.10
    done
  done
}

echo "Report being generated. File location will appear below once ready."

progress_indicator &

SPIN_PID=$!

trap "kill -9 $SPIN_PID" $(seq 0 15)

while read -r ID; do
			
	if [[ "$ID" =~ ^[0-9]+$ ]]; then
            GetJamfProAPIToken
            
            # Set the expected HTTP response code for a successful API call to update the management setting information.
            APISuccess="204"

            ComputerRecord=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfproIDURL}/$ID" -H "Accept: application/json" 2>/dev/null)

            if [[ ! -f "$report_file" ]]; then
                touch "$report_file"
                printf "Jamf Pro ID Number\tMake\tModel\tSerial Number\tUDID\tComputer Management Status\tJamf Pro URL\n" > "$report_file"
            fi

            management_status_check=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract general.remoteManagement.managed raw - 2>/dev/null)
            
            if [[ ${management_status_check} = "true" ]]; then
                   echo ""
                   echo "Management status in the computer inventory record for $jamfpro_url/computers.html?id=$ID is currently set to managed."
                   echo ""
                   management_status_output="Managed"
            elif [[ ${management_status_check} = "false" ]]; then

                ComputerInventoryRecordManagementUpdateToManaged

                # If the API call returns an HTTP response which matches the APISuccess variable, the API call succeeded and the management setting information
                # should be updated in the computer inventory record. Script reports a successful update.
                # 
                # If the HTTP response code does not match the APISuccess variable, script report a failed update to the management setting information.

                if [[ "$responseCode" == "$APISuccess" ]]; then
                   echo ""
                   echo "Updated management status in the computer inventory record for $jamfpro_url/computers.html?id=$ID from unmanaged to managed."
                   echo ""
                   management_status_output="Managed"
                else
                   echo ""
                   echo "ERROR! Management status in the computer inventory record for $jamfpro_url/computers.html?id=$ID is unmanaged."
                   echo ""
                   management_status_output="Unmanaged"
                fi
            fi
           
            Make=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract hardware.make raw - 2>/dev/null)
            MachineModel=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract hardware.model raw - 2>/dev/null)
            SerialNumber=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract hardware.serialNumber raw - 2>/dev/null)
            UDIDIdentifier=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract udid raw - 2>/dev/null)						
            JamfProURL=$(printf "$jamfpro_url/computers.html?id=$ID")
			
            if [[ $? -eq 0 ]]; then
                printf "$ID\t$Make\t$MachineModel\t$SerialNumber\t$UDIDIdentifier\t${management_status_output}\t${JamfProURL}\n" >> "$report_file"
            else
                echo "ERROR! Failed to read computer record with id $ID"
            fi
	fi
				
done < "$filename"

kill -9 "$SPIN_PID"
			
if [[ -f "$report_file" ]]; then
     echo "Report on Macs available here: $report_file"
fi

else
	echo "Input file does not exist or is not readable"
	exitCode=1
fi

exit "$exitCode"
