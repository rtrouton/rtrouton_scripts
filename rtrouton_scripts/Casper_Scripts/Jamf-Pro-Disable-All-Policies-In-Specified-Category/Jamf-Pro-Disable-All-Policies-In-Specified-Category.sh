#!/bin/bash

clear

error=0

# This script disables all policies in a specified category.
# Script is adapted from purgeAllPoliciesInCategory.bash by Jeffrey Compton, https://twitter.com/igeekjsc
# https://github.com/igeekjsc/JSSAPIScripts/blob/master/purgeAllPoliciesInCategory.bash

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

echo -e "\nThis script disables all Jamf Pro policies in a specified category.\n"

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

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi


echo ""
echo -e "Please see below for the list of categories available on $jamfpro_url\n"

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	FormattedCategoryListXML=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/categories" | xmllint --format -)
else
	FormattedCategoryListXML=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/categories" | xmllint --format -)
fi

echo "$(echo "$FormattedCategoryListXML" | awk -F "[><]" '/name/{print $3}')"
echo ""
read -p "Please enter the name of the category: " jamfpro_category

echo ""



# Store the unmodified characters entered for the jamfpro_category variable.
display_jamfpro_category="$jamfpro_category"

# Replace spaces with %20 in the category input if needed.
jamfpro_category=${jamfpro_category// /%20}


DisableComputerPolicy(){

curloutput=$(mktemp)

echo "Disabling policy ID number $ID."

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	/usr/bin/curl --write-out '%{http_code}\t' --silent --output "$curloutput" --header "Authorization: Bearer ${api_token}" -H "Content-Type: application/xml" "${jamfpro_url}/JSSResource/policies/id/${policyID}" -X PUT -d '<policy><general><enabled>false</enabled></general></policy>'
else
	/usr/bin/curl --write-out '%{http_code}\t' --silent --output "$curloutput" --user "${jamfpro_user}:${jamfpro_password}" -H "Content-Type: application/xml" "${jamfpro_url}/JSSResource/policies/id/${policyID}" -X PUT -d '<policy><general><enabled>false</enabled></general></policy>'
fi

printf "$(cat "$curloutput")\n"
}

# Download category information in XML format

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	FormattedCategoryXML=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/category/{$jamfpro_category}" | xmllint --format -)
else
	FormattedCategoryXML=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/category/{$jamfpro_category}" | xmllint --format -)
fi

#See if there are any policies in the category

numberOfPoliciesInCategory=$(echo "$FormattedCategoryXML" | xmllint --xpath "/policies/size/text()" - 2>/dev/null)

if (( $numberOfPoliciesInCategory == 0 ))
	then
		echo "Did not find any policies at all in the $display_jamfpro_category category."
		echo "Exiting."
		error=1
elif (( $numberOfPoliciesInCategory > 0 ))
	then
		echo "Found $numberOfPoliciesInCategory policies in the ${display_jamfpro_category} category."
		echo "Proceeding..."
else
	echo "An unknown error occurred. Exiting."
	error=1
fi

# Check to see if we should exit at this point

if [[ "$error" > 0 ]]; then
   exit "$error"
fi

# List policies to disable before proceeding
echo -e "\nThe following policies in the $display_jamfpro_category category"
echo -e "on $jamfpro_url are going to be disabled:\n"
echo "$(echo "$FormattedCategoryXML" | awk -F "[><]" '/name/{print $3}')"

echo -e "\nAre you absolutely certain you want to disable "
echo -e "these $numberOfPoliciesInCategory policies ?\n"
read -p "Yes or No (y or n) : " confirmationChoice

case $confirmationChoice in
   Y|y|Yes|YES|yes)
     echo "Proceeding..." ;;
   *)
     echo "Exiting now without making changes..." ; exit "$error" ;;
esac

PoliciesInCategory_id_list=$(echo "$FormattedCategoryXML" | awk -F "[><]" '/id/{print $3}')
PoliciesInCategory_id=$(echo "$PoliciesInCategory_id_list" | grep -Eo "[0-9]+")

for policyID in ${PoliciesInCategory_id}; do
    echo -e "\nDisabling policy ID $policyID ..."
    DisableComputerPolicy

    if [[ $? -eq 0 ]]; then
	    echo -e "\nDisabled policy ID $policyID."
    else
	    echo -e "\nERROR! Failed to disable policy ID $policyID."
    fi
done

exit "$error"