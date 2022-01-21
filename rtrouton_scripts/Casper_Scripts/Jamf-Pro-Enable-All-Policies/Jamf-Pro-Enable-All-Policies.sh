#!/bin/bash

# Parts of this script taken from a script by Richard Purves
# https://github.com/franton/JSS-API-Wipe

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the computer policies stored on a Jamf Pro server then do the following:
#
# Enable the policy
# Display HTTP return code and API output
# 
# Successful policy enabling should produce output similar to that shown below:
#
# 201	<?xml version="1.0" encoding="UTF-8"?><policy><id>1</id></policy>
#
# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Policies: Read, Update

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
echo "You are about to enable ALL policies on $jamfpro_url"
echo "Are you completely sure you want to do this?"
read -p "(Default is NO. Type YES to go ahead) : " arewesure

# Check for the skip
if [[ $arewesure != "YES" ]];
then
	echo "OK. Quitting now without any enabling any policies on $jamfpro_url."
	exit 0
fi

# HERE WE GO

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

EnableComputerPolicy(){

curloutput=$(mktemp)

echo "Enabling policy ID number $ID."

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	/usr/bin/curl --write-out '%{http_code}\t' --silent --output "$curloutput" --header "Authorization: Bearer ${api_token}" -H "Content-Type: application/xml" "${jamfpro_url}/JSSResource/policies/id/${ID}" -X PUT -d '<policy><general><enabled>true</enabled></general></policy>'
else
	/usr/bin/curl --write-out '%{http_code}\t' --silent --output "$curloutput" --user "${jamfpro_user}:${jamfpro_password}" -H "Content-Type: application/xml" "${jamfpro_url}/JSSResource/policies/id/${ID}" -X PUT -d '<policy><general><enabled>true</enabled></general></policy>'
fi

printf "$(cat "$curloutput")\n"
}

# Set exit code for script

exitcode=0

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	ComputerPolicy_id_list=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xmllint --xpath "//id" - 2>/dev/null)
else
	ComputerPolicy_id_list=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xmllint --xpath "//id" - 2>/dev/null)
fi

if [[ -n "$ComputerPolicy_id_list" ]]; then

	echo "Downloading computer policy list from $jamfpro_url..."
	ComputerPolicy_id=$(echo "$ComputerPolicy_id_list" | grep -Eo "[0-9]+")

	for ID in ${ComputerPolicy_id}; do
	   EnableComputerPolicy
	done
	
else
	echo "ERROR! Unable to get computer policy list"
	exitcode=1
fi


# All done!
echo ""
echo "Operation completed."
exit "$exitcode"