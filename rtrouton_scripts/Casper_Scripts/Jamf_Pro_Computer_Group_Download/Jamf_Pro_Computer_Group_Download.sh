#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the computer groups stored on a Jamf Pro server then do the following:
#
# 1. Download the group information as XML
# 2. Remove the group membership from the downloaded XML
# 3. Identify the group name
# 4. Categorize the downloaded group as either a smart or static computer group
# 5. Save the XML to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Smart Computer Groups: Read
# Static Computer Groups: Read

# If you choose to specify a directory to save the downloaded groups into,
# please enter the complete directory path into the ComputerGroupDownloadDirectory
# variable below.

ComputerGroupDownloadDirectory=""

# If the ComputerGroupDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$ComputerGroupDownloadDirectory" ]]; then
   ComputerGroupDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded groups has not been specified."
   echo "Downloaded groups will be stored in $ComputerGroupDownloadDirectory."
fi

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

echo ""

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# Remove the trailing slash from the ComputerGroupDownloadDirectory variable if needed.
ComputerGroupDownloadDirectory=${ComputerGroupDownloadDirectory%%/}

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

DownloadComputerGroup(){

	# Download the profile as encoded XML, then decode and format it
	echo "Downloading computer group from $jamfpro_url..."
	
	if [[ -z "$NoBearerToken" ]]; then
	   CheckAndRenewAPIToken
	   FormattedComputerGroup=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/computergroups/id/${ID}" -X GET | tr $'\n' $'\t' | sed -E 's|<computers>.*</computers>||' |  tr $'\t' $'\n' | xmllint --format - )
	else
	   FormattedComputerGroup=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/computergroups/id/${ID}" -X GET | tr $'\n' $'\t' | sed -E 's|<computers>.*</computers>||' |  tr $'\t' $'\n' | xmllint --format - )		
	fi

	# Identify and display the profile's name
	DisplayName=$(echo "$FormattedComputerGroup" | xmllint --xpath '//computer_group/name/text()' - 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded computer group is named: $DisplayName"
	
	if [[ $(echo "$FormattedComputerGroup" | xmllint --xpath '//computer_group/is_smart/text()' - 2>/dev/null) == "true" ]]; then
	   GroupType="Smart"
	else
	   GroupType="Static"
	fi

	## Save the downloaded computer group
	echo "$DisplayName is a $GroupType group."
	echo "Saving ${DisplayName}.xml file to $ComputerGroupDownloadDirectory/$GroupType Groups."

	if [[ "$GroupType" = "Smart" ]]; then
	   if [[ -d "$ComputerGroupDownloadDirectory/$GroupType Groups" ]]; then
          echo "$FormattedComputerGroup" > "$ComputerGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml" 
        else
           mkdir -p "$ComputerGroupDownloadDirectory/$GroupType Groups"
           echo "$FormattedComputerGroup" > "$ComputerGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml"
        fi
    elif [[ "$GroupType" = "Static" ]]; then
        if [[ -d "$ComputerGroupDownloadDirectory/$GroupType Groups" ]]; then
          echo "$FormattedComputerGroup" > "$ComputerGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml" 
        else
          mkdir -p "$ComputerGroupDownloadDirectory/$GroupType Groups"
          echo "$FormattedComputerGroup" > "$ComputerGroupDownloadDirectory/$GroupType Groups/${DisplayName}.xml"
        fi
    fi

}

if [[ -z "$NoBearerToken" ]]; then
   CheckAndRenewAPIToken
   ComputerGroup_id_list=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/computergroups" | xmllint --xpath '//id' - 2>/dev/null)	
else
   ComputerGroup_id_list=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/computergroups" | xmllint --xpath '//id' - 2>/dev/null)		
fi

ComputerGroup_id=$(echo "$ComputerGroup_id_list" | grep -Eo "[0-9]+")

# Download latest version of all computer groups. For performance reasons, we
# parallelize the execution.
MaximumConcurrentJobs=10
ActiveJobs=0


for ID in ${ComputerGroup_id}; do

   ((ActiveJobs=ActiveJobs%MaximumConcurrentJobs)); ((ActiveJobs++==0)) && wait
   DownloadComputerGroup &

done