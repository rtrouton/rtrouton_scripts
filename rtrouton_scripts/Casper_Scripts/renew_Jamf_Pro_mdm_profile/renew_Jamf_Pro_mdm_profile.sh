#!/bin/bash

# This script is designed to be run on a Mac via a Jamf Pro policy to renew MDM profiles before their expiration date.
#
# API rights required by account specified in jamfpro_user variable:
#
# Jamf Pro Server Objects:
#
# Computers: Read
#
# Jamf Pro Server Actions:
#
# Send Command to Renew MDM Profile

# Setting exit status

error=0

jamfpro_url=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url)
jamfpro_user=""
jamfpro_password=""
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

# These functions use the Jamf Pro Classic API and Jamf Pro API to perform various tasks.
#
# Jamf Pro Classic API:
#
# GetJamfProComputerUDID - Uses the Mac's hardware UUID to identify the Mac's computer UDID listed in its Jamf Pro computer inventory record.
#
# Jamf Pro API:
#
# RenewMDMProfile - Uses the Mac's computer UDID to trigger a renewal of the Mac's MDM profile.

GetJamfProUDID () {
if [[ -z "$NoBearerToken" ]]; then
    CheckAndRenewAPIToken
    local computerUDID=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/udid/${machineUUID}" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer/general/udid/text()" - 2>/dev/null)
else
    local computerUDID=$(/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/JSSResource/computers/udid/${machineUUID}" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer/general/udid/text()" - 2>/dev/null)
fi
    echo "$computerUDID"
}

RenewMDMProfile () {
	CheckAndRenewAPIToken
	/usr/bin/curl -X POST ${jamfpro_url}/api/v1/mdm/renew-profile -H "accept: application/json" -H "Authorization: Bearer ${api_token}" -H "Content-Type: application/json" -d "{\"udids\":[\"$computerUDID\"]}"
}

# Get the Mac's computer UDID listed in its Jamf Pro computer inventory record.

computerUDID=$(GetJamfProUDID)

# Verify that the returned UDID is a valid UUID value.

if [[ "$computerUDID" =~ ^\{?[A-F0-9a-f]{8}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{4}-[A-F0-9a-f]{12}\}?$ ]]; then

	    # If the returned UDID is a valid UUID value, use it with the RenewMDMProfile function
	    # to renew the Mac's MDM profile.

	    echo "Renewing MDM profile....."
	    RenewMDMProfile
	    
	    # Verify that the MDM profile renewal command exited without errors.
	    # If there was a problem, log an error message and set the script exit
	    # status to 1.

	    if [[ $? -eq 0 ]]; then
	    	 echo ""
	    	 echo "Renewed MDM profile successfully."
	    else
	    	 echo ""
	    	 echo "ERROR! Problem occurred when renewing MDM profile!"
	    	 error=1
	    fi
 else

	  # If the returned UDID is not a valid UUID value, log an error message
	  # and set the script exit status to 1.	

	  echo "ERROR! Problem occurred when identifying Jamf Pro computer UDID!"
	  error=1
fi

exit "$error"