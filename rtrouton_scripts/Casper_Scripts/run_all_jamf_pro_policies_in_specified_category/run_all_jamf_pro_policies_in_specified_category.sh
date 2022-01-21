#!/bin/bash

# Set username of the API user. 
# Script uses Parameter 4 to get the appropriate username from Jamf Pro

jamfpro_user="$4"

# Set password of the API user.
# Script uses Parameter 5 to get the  appropriate password from Jamf Pro.

jamfpro_password="$5"

# Set the policy category which contains the Jamf Pro
# policies that need to be run. Script uses Parameter 6
# to get the appropriate category from Jamf Pro.

PolicyCategory="$6"


CheckBinary (){

# Identify location of jamf binary.

jamf_binary=$(/usr/bin/which jamf)

 if [[ "$jamf_binary" == "" ]] && [[ ! -x "/usr/local/bin/jamf" ]] && [[ -x "/usr/local/jamf/bin/jamf" ]]; then
    jamf_binary="/usr/local/jamf/bin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ -x "/usr/local/bin/jamf" ]] && [[ -x "/usr/local/jamf/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 fi
}

# Run the CheckBinary function to identify the location
# of the jamf binary

CheckBinary

# If the jamf binary isn't found, stop the script
# and exit with an error status.

if [[ "$jamf_binary" == "" ]]; then
   /bin/echo "`date +%Y-%m-%d\ %H:%M:%S`  Jamf Pro agent not found. Exiting."
   exit 1
fi

# Identify the URL of the Jamf Pro server using the
# 'jamf checkJSSConnection' command

jamfpro_urlCheck=$("$jamf_binary" checkJSSConnection | awk '/Checking/ {print $4}')
jamfpro_url=$(echo ${jamfpro_urlCheck///...})
JamfProPolicyURL="${jamfpro_url}/JSSResource/policies/category/${PolicyCategory}"

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

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

# Save current IFS state

OLDIFS=$IFS

# Change IFS to
# create newline

IFS=$'\n'
  
if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	jamfpro_policy_ids=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${JamfProPolicyURL}" | xmllint --xpath "policies/policy/id" - | sed 's/\<id>//g' | tr '</id>' '\n' | sed '/^s*$/d')
else
	jamfpro_policy_ids=$(/usr/bin/curl -sf -u "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${JamfProPolicyURL}" | xmllint --xpath "policies/policy/id" - | sed 's/\<id>//g' | tr '</id>' '\n' | sed '/^s*$/d')
fi   
  
# Read all policy IDs into an array

policies=($(/bin/echo "$jamfpro_policy_ids"))
 
# Restore IFS to previous state

IFS=$OLDIFS
  
# Get length of the array

tLen=${#policies[@]}
  
# Run all matching Jamf Pro policies in the order received from the Jamf Pro server
  
for (( i=0; i<${tLen}; i++ ));
do
  /bin/echo "`date +%Y-%m-%d\ %H:%M:%S`  Installing policy "${policies[$i]}" on this Mac."
  "$jamf_binary" policy -id "${policies[$i]}"
done
