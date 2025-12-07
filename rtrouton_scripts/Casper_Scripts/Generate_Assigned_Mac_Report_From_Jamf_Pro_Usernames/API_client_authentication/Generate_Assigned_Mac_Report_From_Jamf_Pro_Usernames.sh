#!/bin/bash

# This script imports a list of usernames from a plaintext file 
# and uses that information to generate a report about the computers
# assigned to that username.
#
# ./Generate_Assigned_Mac_Report_From_Jamf_Pro_Usernames.sh usernames.txt
#
# The script can also accept one username as input, if a plaintext file containing usernames
# is not available.
#
# Usage: ./Generate_Assigned_Mac_Report_From_Jamf_Pro_Usernames.sh
#
# Plaintext file format should look like this:
#
# first_username_goes_here
# second_username_goes_here
# third_username_goes_here
# fourth_username_goes_here
#
# Once the username(s) are read from in from the plaintext file or from manual input, the script takes the following actions:
#
# 1. Uses the Jamf Pro API to download all information about the matching computer inventory record in JSON format.
# 2. Pulls the following information out of the inventory entry:
#
#    Jamf Pro ID
#    Assigned user's username
#    Assigned user's email
#    Manufacturer
#    Model
#    Serial Number
#    Hardware UDID
#
# 3. Create a report in tab-separated value (.tsv) format which contains the following information
#    about the deleted Macs
#
#    Jamf Pro ID
#    Assigned user's username
#    Assigned user's email
#    Manufacturer
#    Model
#    Serial Number
#    Hardware UDID
#    Jamf Pro URL for the computer inventory record
#
# If setting up an API client with limited rights, here are the required API role privileges
# for the API client on the Jamf Pro server:
#
# Read Computers

# Check for the jq command line tool to be installed. It must be installed for this script to work.
# The jq command line tool is installed by default on macOS Sequoia and later. 

which jq &>/dev/null

if [[ $? -ne 0 ]]; then
   echo "ERROR: jq command line tool is not installed. Please install the jq command line tool."
   echo "Downloads available from https://jqlang.org/download/ ."
   exit 1
fi

# Get installed jq

jqTool=$(which jq)

report_file="$(mktemp).tsv"

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

# Set initial status for exit
error=0 

filename="$1"

# If a text file with usernames has not been provided, the script
# will prompt for a single username.

if [[ -z "$filename" ]]; then
     read -p "Please enter the relevant username : " assigned_user
     assigned_user_filename=$(mktemp)
     /usr/bin/touch "$assigned_user_filename"
     echo "$assigned_user" > "$assigned_user_filename"
fi

if [[ -z "$filename" ]] && [[ -r "$assigned_user_filename" ]]; then
    filename="$assigned_user_filename"
fi

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

progress_indicator() {
  spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
  while :
  do
    for i in $(seq 0 7)
    do
      echo -n "${spinner:$i:1}"
      echo -en "\010"
      /bin/sleep 0.10
    done
  done
}

echo "Report being generated. File location will appear below once ready."

progress_indicator &

SPIN_PID=$!

trap "kill -9 $SPIN_PID" $(seq 0 15)

# Create temp files for data

idtempfile=$(mktemp)

jsontempfile=$(mktemp)

/usr/bin/touch "$jsontempfile"

# Get all computers that are associated with username

while read -r UserToMatch || [ -n "$UserToMatch" ]; do

# Get all computers associated with usernames

GetJamfProAPIToken

# Set the correct URL for looking up the computer inventory record associated with the specified username.   
jamfproUsernameURL="${jamfpro_url}/api/v3/computers-inventory??section=USER_AND_LOCATION&filter=userAndLocation.username=="

# Look up the computer inventory records associated with the specified username and get the Jamf Pro device IDs.
/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfproUsernameURL}${UserToMatch}" -H "Accept: application/json" | "$jqTool" '.' >> $jsontempfile

done < "$filename"

# Extract the Jamf Pro computer IDs

/bin/cat "$jsontempfile" | "$jqTool" -r '.results[].id' > "$idtempfile"

while read -r ID; do
			
	if [[ "$ID" =~ ^[0-9]+$ ]]; then

			GetJamfProAPIToken
		    # Set the correct URL for looking up the computer associated with the specified Jamf Pro device ID.
		    jamfproIDURL="${jamfpro_url}/api/v3/computers-inventory-detail"
		    ComputerRecord=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfproIDURL}/${ID}" -H "Accept: application/json" 2>/dev/null)

			if [[ ! -f "$report_file" ]]; then
				/usr/bin/touch "$report_file"
				printf "Jamf Pro ID Number\tAssigned User\tAssigned User Email\tMake\tModel\tSerial Number\tUDID\tJamf Pro URL\n" > "$report_file"
			fi

			Make=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract hardware.make raw - 2>/dev/null)
			AssignedUser=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract userAndLocation.username raw - 2>/dev/null)
			AssignedUserEmail=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract userAndLocation.email raw - 2>/dev/null)
			MachineModel=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract hardware.model raw - 2>/dev/null)
			SerialNumber=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract hardware.serialNumber raw - 2>/dev/null)
			JamfProID=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract id raw - 2>/dev/null)
			UDIDIdentifier=$(printf '%s' "$ComputerRecord" | /usr/bin/plutil -extract udid raw - 2>/dev/null)						
			JamfProURL=$(printf "$jamfpro_url/computers.html?id=$ID")
			
			if [[ $? -eq 0 ]]; then
				printf "$JamfProID\t$AssignedUser\t$AssignedUserEmail\t$Make\t$MachineModel\t$SerialNumber\t$UDIDIdentifier\t${JamfProURL}\n" >> "$report_file"
			else
				echo "ERROR! Failed to read computer record with id $JamfProID"
				error=1
			fi
	fi
				
done < "$idtempfile"

# Clean up temp files

if [[ -f "$assigned_user_filename" ]]; then
    rm -rf "$assigned_user_filename"
fi

if [[ -f "$jsontempfile" ]]; then
   rm -rf "$jsontempfile"
fi

if [[ -f "$idtempfile" ]]; then
   rm -rf "$idtempfile"
fi

kill -9 "$SPIN_PID" 2>/dev/null


if [[ -f "$report_file" ]]; then
     echo "Report on Macs available here: $report_file"
fi

exit "$error"