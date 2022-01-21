#!/bin/bash

# This script uses the Jamf Pro Classic API to detect which
# Self Service policies do not have icons and displays
# a list of the relevant policies.

# Set default exit code
exitCode=0

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

# Read the appropriate values from ~/Library/Preferences/com.github.jamfpro-info.plist
# if the file is available. To create the file, run the following commands:
#
# defaults write $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url https://jamf.pro.server.here
# defaults write $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_user API_account_username_goes_here
# defaults write $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_password API_account_password_goes_here
#

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

echo

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

# The following function downloads individual Jamf Pro policy as XML data
# then mines the policy data for the relevant information.

CheckSelfServicePolicyCheckIcons(){

	local PolicyId="$1"

	if [[ -n "$PolicyId" ]]; then
		
		if [[ -z "$NoBearerToken" ]]; then
		     CheckAndRenewAPIToken
		     local DownloadedXMLData=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/id/$PolicyId")
		else
		     local DownloadedXMLData=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/id/$PolicyId")
		fi

		local PolicyName=$( echo "$DownloadedXMLData" | xmllint --xpath '/policy/general/name/text()' - 2>/dev/null)
		local SelfServicePolicyCheck=$(echo "$DownloadedXMLData" | xmllint --xpath '/policy/self_service/use_for_self_service/text()' - 2>/dev/null)
		local SelfServiceIcon=$(echo "$DownloadedXMLData" | xmllint --xpath '/policy/self_service/self_service_icon/id/text()' - 2>/dev/null)

		# If a policy is detected as being a Self Service policy without
		# an icon, the policy name is saved to a temp file.

		if [[ "$SelfServicePolicyCheck" = "true" ]] && [[ -z "$SelfServiceIcon" ]]; then
			echo "The following Self Service policy does not have an icon: $PolicyName" >> "$PolicyCountFile"
		fi
	fi
}

# Download all Jamf Pro policy ID numbers

if [[ -z "$NoBearerToken" ]]; then
     CheckAndRenewAPIToken
     PolicyIDList=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xmllint --xpath "//id" - 2>/dev/null)
else
     PolicyIDList=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xmllint --xpath "//id" - 2>/dev/null)
fi

PolicyIDs=$(echo "$PolicyIDList" | grep -Eo "[0-9]+")
PoliciesCount=$(echo "$PolicyIDs" | grep -c ^)

echo "Checking $PoliciesCount policies for Self Service policies for missing icons ..."
echo

# Download latest version of all computer policies using their ID numbers. 
# For performance reasons, we parallelize the execution.
MaximumConcurrentJobs=10
ActiveJobs=0
ProcessedJobs=0

# Create temp file for background processes' output
PolicyCountFile=$(mktemp)
touch "$PolicyCountFile"

for anID in ${PolicyIDs}; do

   # Run API calls in parallel
   ((ActiveJobs=ActiveJobs%MaximumConcurrentJobs)); ((ActiveJobs++==0)) && wait
   CheckSelfServicePolicyCheckIcons $anID &
   
    ProcessedJobs=$(( $ProcessedJobs + 1 ))
    PercentComplete=$(echo "(100/${PoliciesCount})*${ProcessedJobs}" | bc -l | awk '{print int($1+0.5)}')
    ProgressDone=$(echo "$PercentComplete/2" | bc -l | awk '{print int($1+0.5)}')
    ProgressLeft=$(( 50 - $ProgressDone ))
    DonePattern=$(printf "%${ProgressDone}s")
    LeftPattern=$(printf "%${ProgressLeft}s")

    printf "\rProcessing: [${DonePattern// /#}${LeftPattern// /-}] ${PercentComplete}%%"
done

PolicyCountNumber=$(grep -c ^ "$PolicyCountFile")
echo
echo
echo "$PolicyCountNumber Self Service policies detected without icons"
cat "$PolicyCountFile"

echo
echo "Policy check completed."

# Remove temp file

rm "$PolicyCountFile"

exit $exitCode