#!/bin/bash

# This script is designed to be run on a Mac via a Jamf Pro policy to clear failed MDM commands on a regular basis. This
# allows failed MDM commands or profiles to be re-pushed automatically.
#
# API rights required by account specified in jamfpro_user variable:
#
# Jamf Pro Server Objects:
#
# Computers: Read
#
# Jamf Pro Server Actions:
#
# Flush MDM Commands
#
# Original script from https://aporlebeke.wordpress.com/2019/01/04/auto-clearing-failed-mdm-commands-for-macos-in-jamf-pro/
# GitHub gist: https://gist.github.com/apizz/48da271e15e8f0a9fc6eafd97625eacd#file-ea_clear_failed_mdm_commands-sh

error=0

jamfpro_url=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url)
jamfpro_user="username_goes_here"
jamfpro_password="password_goes_here"
machineUUID=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/awk '/IOPlatformUUID/ { gsub(/"/,"",$3); print $3; }')

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

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

if [[ -z "$NoBearerToken" ]]; then
   GetJamfProAPIToken
fi

# These functions use the Jamf Pro Classic API to perform various tasks.
#
# ClearFailedMDMCommands - Clears all failed MDM commands associated with a Jamf Pro computer ID.
# GetJamfProComputerID - Uses the Mac's hardware UUID to identify the Mac's computer ID in Jamf Pro.
# GetFailedMDMCommands - Uses the Mac's hardware UUID to download the list of failed MDM commands.

ClearFailedMDMCommands () {
if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/commandflush/computers/id/${computerID}/status/Failed" -X DELETE
else
	/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/JSSResource/commandflush/computers/id/${computerID}/status/Failed" -X DELETE
fi
}

GetJamfProComputerID () {
if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
    local computerID=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/udid/${machineUUID}" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer/general/id/text()" - 2>/dev/null)
else
	local computerID=$(/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/JSSResource/computers/udid/${machineUUID}" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer/general/id/text()" - 2>/dev/null)
fi
    echo "$computerID"
}

GetFailedMDMCommands () {
if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
    local xmlResult=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computerhistory/udid/${machineUUID}/subset/Commands" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer_history/commands/failed[node()]" - 2>/dev/null)
else
	local xmlResult=$(/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/JSSResource/computerhistory/udid/${machineUUID}/subset/Commands" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer_history/commands/failed[node()]" - 2>/dev/null)
fi
	echo "$xmlResult"
}


# Build a list of failed MDM commands associated with a particular Mac.

xmlResult=$(GetFailedMDMCommands)

# Clear failed MDM commands if they exist

if [[ -n "$xmlResult" ]]; then

	computerID=$(GetJamfProComputerID)

	if [[ "$computerID" =~ ^[0-9]+$ ]]; then
	
	    echo "Removing failed MDM commands....."
	    ClearFailedMDMCommands

	  	if [[ $? -eq 0 ]]; then
	    	echo "Removed failed MDM commands."
	  	else
	   		echo "ERROR! Problem occurred when removing failed MDM commands!"
	   		error=1
	  	fi
	  
	else
	   echo "ERROR! Problem occurred when identifying Jamf Pro computer ID!"
	   error=1
	fi

else
	echo "No failed MDM commands found."
fi

exit $error