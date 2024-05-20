#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the policies stored on a Jamf Pro server then do the following:
#
# 1. Back up existing downloaded policies
# 2. Download the policy as XML
# 3. Identify the policy name
# 4. Categorize the downloaded policy
# 5. Save the policy to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Policies: Read

# Set exit error status

ERROR=0

# If you choose to specify a directory to save the downloaded policies into,
# please enter the complete directory path into the PolicyDownloadDirectory
# variable below.

PolicyDownloadDirectory=""

# If the PolicyDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

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

# If configured to get one, get a Jamf Pro API Bearer Token
	
if [[ -z "$NoBearerToken" ]]; then
    GetJamfProAPIToken
fi

initializePolicyDownloadDirectory ()
{

if [[ -z "$PolicyDownloadDirectory" ]]; then
   PolicyDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded policies has not been specified."
   echo "Downloaded policies will be stored in $PolicyDownloadDirectory."
   echo "$PolicyDownloadDirectory not found.  Creating..."
   mkdir -p $PolicyDownloadDirectory
   if (( $? == 0 ))
   	then
   		echo "Successfully created $PolicyDownloadDirectory"
   	else
   		echo "Could not create $PolicyDownloadDirectory"
   		echo "Please make sure the parent directory is writable. Exiting...."
   		ERROR=1
   		exit $ERROR
   	fi
else

   # Remove the trailing slash from the PolicyDownloadDirectory variable if needed.
   PolicyDownloadDirectory=${PolicyDownloadDirectory%%/}

   if [[ -d "$PolicyDownloadDirectory" ]] && [[ -n "$(ls -A "$PolicyDownloadDirectory")" ]]; then
		archive_file="PolicyDownloadDirectoryArchive-`date +%Y%m%d%H%M%S`.zip"
		echo "Archiving previous policy download directory to ${PolicyDownloadDirectory%/*}/$archive_file"
		ditto -ck "$PolicyDownloadDirectory" "${PolicyDownloadDirectory%/*}/$archive_file"
		if (( $? == 0 )); then
				echo "Successfully created ${PolicyDownloadDirectory%/*}/$archive_file"
			else
				echo "Could not create $archive_file. Exiting...."
				ERROR=1
				exit $ERROR
		fi

		# Removing existing directory after archiving is complete.
		rm -rf $PolicyDownloadDirectory
		
		# Creating a new directory with the same name.
		mkdir -p $PolicyDownloadDirectory
				if (( $? == 0 ))
			then
				echo "Successfully created new $PolicyDownloadDirectory"
			else
				echo "Could not create new $PolicyDownloadDirectory"
				echo "Please make sure the parent directory is writable. Exiting...."
				ERROR=1
				exit $ERROR
		fi
   elif [[ -d "$PolicyDownloadDirectory" ]] && [[ -z "$(ls -A "$PolicyDownloadDirectory")" ]]; then
		echo  "$PolicyDownloadDirectory exists but is empty. Using existing directory for downloading policies."
   elif [[ -n "$PolicyDownloadDirectory" ]] && [[ ! -d "$PolicyDownloadDirectory" ]]; then
		echo  "$PolicyDownloadDirectory does not exist. Creating $PolicyDownloadDirectory for downloading policies."
		mkdir -p $PolicyDownloadDirectory
			if (( $? == 0 )); then
				echo "Successfully created new $PolicyDownloadDirectory"
			else
				echo "Could not create new $PolicyDownloadDirectory"
				echo "Please make sure the parent directory is writable. Exiting...."
				ERROR=1
				exit $ERROR
			fi
	fi

fi
}

DownloadComputerPolicy(){

	# Download the policy information as raw XML,
	# then format it to be readable.
	echo "Downloading macOS computer policies from $jamfpro_url..."
	
	if [[ -z "$NoBearerToken" ]]; then
		CheckAndRenewAPIToken
		FormattedComputerPolicy=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/id/${ID}" -X GET | xmllint --format - )
	else
		FormattedComputerPolicy=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies/id/${ID}" -X GET | xmllint --format - )		
	fi

	# Identify and display the policy's name.
	DisplayName=$(echo "$FormattedComputerPolicy" | xmllint --xpath "/policy/general/name/text()" - 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded policy is named: $DisplayName"
	
	# Identify the policy category
	
	PolicyCategory=$(echo "$FormattedComputerPolicy" | xmllint --xpath "/policy/general/category/name/text()" - 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')

	# Save the downloaded policy.

	echo "Saving ${DisplayName}.xml file to $PolicyDownloadDirectory/$PolicyCategory."
	
	if [[ -d "$PolicyDownloadDirectory/$PolicyCategory" ]]; then
	  echo "$FormattedComputerPolicy" > "$PolicyDownloadDirectory/$PolicyCategory/${DisplayName}.xml" 
	else
	  mkdir -p "$PolicyDownloadDirectory/$PolicyCategory"
	  echo "$FormattedComputerPolicy" > "$PolicyDownloadDirectory/$PolicyCategory/${DisplayName}.xml"
	fi
}

# Back up existing policy downloads and create policy download directory.

initializePolicyDownloadDirectory

# Download latest version of all computer policies

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	ComputerPolicy_id_list=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xmllint --xpath "//id" - 2>/dev/null)
else
	ComputerPolicy_id_list=$(/usr/bin/curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/policies" | xmllint --xpath "//id" - 2>/dev/null)		
fi

ComputerPolicy_id=$(echo "$ComputerPolicy_id_list" | grep -Eo "[0-9]+")

# Download latest version of all advanced computer searches. For performance reasons, we
# parallelize the execution.
MaximumConcurrentJobs=10
ActiveJobs=0

for ID in ${ComputerPolicy_id}; do
   ((ActiveJobs=ActiveJobs%MaximumConcurrentJobs)); ((ActiveJobs++==0)) && wait
   DownloadComputerPolicy &

done

exit $ERROR