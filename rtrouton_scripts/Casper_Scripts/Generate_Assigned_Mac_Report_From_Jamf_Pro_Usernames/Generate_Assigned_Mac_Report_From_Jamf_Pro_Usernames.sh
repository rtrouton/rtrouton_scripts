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
# 1. Uses the Jamf Pro API to download all information about the matching computer inventory record in XML format.
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

report_file="$(mktemp).tsv"

# If you're on Jamf Pro 10.34.2 or earlier, which doesn't support using Bearer Tokens
# for Classic API authentication, set the NoBearerToken variable to the following value
# as shown below:
#
# yes
#
# NoBearerToken="yes"
#
# If you're on Jamf Pro 10.35.0 or later, which does support using Bearer Tokens
# for Classic API authentication, set the NoBearerToken variable to the following value
# as shown below:
#
# NoBearerToken=""

NoBearerToken=""

GetJamfProAPIToken() {

# This function uses Basic Authentication to get a new bearer token for API authentication.

# Use user account's username and password credentials with Basic Authorization to request a bearer token.

if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   api_token=$(/usr/bin/curl -X POST --silent -u "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/api/v1/auth/token" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
else
   api_token=$(/usr/bin/curl -X POST --silent -u "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/api/v1/auth/token" | plutil -extract token raw -)
fi

}

APITokenValidCheck() {

# Verify that API authentication is using a valid token by running an API command
# which displays the authorization details associated with the current API user. 
# The API call will only return the HTTP status code.

api_authentication_check=$(/usr/bin/curl --write-out %{http_code} --silent --output /dev/null "${jamfpro_url}/api/v1/auth" --request GET --header "Authorization: Bearer ${api_token}")

}

CheckAndRenewAPIToken() {

# Verify that API authentication is using a valid token by running an API command
# which displays the authorization details associated with the current API user. 
# The API call will only return the HTTP status code.

APITokenValidCheck

# If the api_authentication_check has a value of 200, that means that the current
# bearer token is valid and can be used to authenticate an API call.


if [[ ${api_authentication_check} == 200 ]]; then

# If the current bearer token is valid, it is used to connect to the keep-alive endpoint. This will
# trigger the issuing of a new bearer token and the invalidation of the previous one.

      if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
         api_token=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/keep-alive" --silent --request POST --header "Authorization: Bearer ${api_token}" | python -c 'import sys, json; print json.load(sys.stdin)["token"]')
      else
         api_token=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/keep-alive" --silent --request POST --header "Authorization: Bearer ${api_token}" | plutil -extract token raw -)
      fi

else

# If the current bearer token is not valid, this will trigger the issuing of a new bearer token
# using Basic Authentication.

   GetJamfProAPIToken
fi
}

InvalidateToken() {

# Verify that API authentication is using a valid token by running an API command
# which displays the authorization details associated with the current API user. 
# The API call will only return the HTTP status code.

APITokenValidCheck

# If the api_authentication_check has a value of 200, that means that the current
# bearer token is valid and can be used to authenticate an API call.

if [[ ${api_authentication_check} == 200 ]]; then

# If the current bearer token is valid, an API call is sent to invalidate the token.

      authToken=$(/usr/bin/curl "${jamfpro_url}/api/v1/auth/invalidate-token" --silent  --header "Authorization: Bearer ${api_token}" -X POST)
      
# Explicitly set value for the api_token variable to null.

      api_token=""

fi
}

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
# defaults write com.githubjamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the account username in the plist file:
# defaults write com.githubjamfpro-info jamfpro_user account_username_goes_here
#
# To store the account password in the plist file:
# defaults write com.githubjamfpro-info jamfpro_password account_password_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will read in the
# relevant information from the plist file.
jamf_plist="$HOME/Library/Preferences/com.github.jamfpro-info.plist"

if [[ -r "$jamf_plist" ]]; then

     if [[ -z "$jamfpro_url" ]]; then
          jamfpro_url=$(defaults read "${jamf_plist%.*}" jamfpro_url)
     fi

     if [[ -z "$jamfpro_user" ]]; then
          jamfpro_user=$(defaults read "${jamf_plist%.*}" jamfpro_user)
     fi

     if [[ -z "$jamfpro_password" ]]; then
          jamfpro_password=$(defaults read "${jamf_plist%.*}" jamfpro_password)
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

if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

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

xmltempfile=$(mktemp)

/usr/bin/touch "$xmltempfile"

# Get all computers that are associated with username

while read -r UserToMatch || [ -n "$UserToMatch" ]; do

# Get all computers associated with usernames

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
    /usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/match/${UserToMatch}" -H "Accept: application/xml" | xmllint --format - >> "$xmltempfile"
else
    /usr/bin/curl -sfu "$jamfpro_user:$jamfpro_password" "${jamfpro_url}/JSSResource/computers/match/${UserToMatch}" -H "Accept: application/xml" | xmllint --format - >> "$xmltempfile"
fi

done < "$filename"

# Extract the Jamf Pro computer IDs

/bin/cat "$xmltempfile" | sed -n 's:.*<id>\(.*\)</id>.*:\1:p' > "$idtempfile"

while read -r ID; do
			
	if [[ "$ID" =~ ^[0-9]+$ ]]; then
		if [[ -z "$NoBearerToken" ]]; then
			CheckAndRenewAPIToken
		    ComputerRecord=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/id/$ID" -H "Accept: application/xml" 2>/dev/null)
		else
		    ComputerRecord=$(/usr/bin/curl -sfu "$jamfpro_user:$jamfpro_password" "${jamfpro_url}/JSSResource/computers/id/$ID" -H "Accept: application/xml" 2>/dev/null)
		fi
			if [[ ! -f "$report_file" ]]; then
				/usr/bin/touch "$report_file"
				printf "Jamf Pro ID Number\tAssigned User\tAssigned User Email\tMake\tModel\tSerial Number\tUDID\tJamf Pro URL\n" > "$report_file"
			fi

			Make=$(echo "$ComputerRecord" | xmllint --xpath '//computer/hardware/make/text()' - 2>/dev/null)
			AssignedUser=$(echo "$ComputerRecord" | xmllint --xpath '//computer/location/username/text()' - 2>/dev/null)
			AssignedUserEmail=$(echo "$ComputerRecord" | xmllint --xpath '//computer/location/email_address/text()' - 2>/dev/null)
			MachineModel=$(echo "$ComputerRecord" | xmllint --xpath '//computer/hardware/model/text()' - 2>/dev/null)
			SerialNumber=$(echo "$ComputerRecord" | xmllint --xpath '//computer/general/serial_number/text()' - 2>/dev/null)
			JamfProID=$(echo "$ComputerRecord" | xmllint --xpath '//computer/general/id/text()' - 2>/dev/null)
			UDIDIdentifier=$(echo "$ComputerRecord" | xmllint --xpath '//computer/general/udid/text()' - 2>/dev/null)						
			JamfProURL=$(echo "$jamfpro_url"/computers.html?id="$JamfProID")
			
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

if [[ -f "$xmltempfile" ]]; then
   rm -rf "$xmltempfile"
fi

if [[ -f "$idtempfile" ]]; then
   rm -rf "$idtempfile"
fi

kill -9 "$SPIN_PID" 2>/dev/null


if [[ -f "$report_file" ]]; then
     echo "Report on Macs available here: $report_file"
fi

exit "$error"