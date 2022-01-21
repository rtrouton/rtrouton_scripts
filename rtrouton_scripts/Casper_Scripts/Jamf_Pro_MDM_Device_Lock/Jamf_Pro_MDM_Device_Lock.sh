#!/bin/bash

# Sends MDM lock commands using Jamf Pro's Classic API.
#
# This script reads a .csv file formatted as follows:
#
# "Jamf Pro ID, PIN Code" as the first line
# 
# Subsequent lines:
# Column 1: A Mac's Jamf Pro ID
# Column 2: Device Lock PIN code
# 
# Example:
#
# Jamf Pro ID, PIN Code
# 26,165234
# 52,197898
# 1226,201145
#
# This script is designed to run as shown below:
#
# /path/to/Jamf_Pro_MDM_Device_Lock.sh filename_goes_here.csv
#
# Once executed, the script will then do the following:
#
# Skip the first line of the .csv file (this is the "Jamf Pro ID, PIN Code" line.)
# Read each subsequent line of the .csv one at a time and assign the values of column 1
# and column 2 to separate variables.
#
# Use the variables in an API PUT call to identify a Jamf Pro computer inventory record
# using the Jamf Pro ID listed in the .csv file and lock the Mac in question using the 
# the PIN code listed in the .csv file.
#
# A successful MDM lock should produce output similar to that shown below:
#
# Attempting to send MDM lock to Jamf Pro ID 1925 with PIN code 348202.
# <?xml version="1.0" encoding="UTF-8"?><computer_command><command><name>DeviceLock</name><command_uuid>98d915a4-6132-4535-b474-c8381e48425a</command_uuid><computer_id>1925</computer_id></command></computer_command>
# Successfully locked computer with Jamf Pro ID 1925 with PIN code 348202.
#
# Failures should look similar to this:
#
# Attempting to send MDM lock to Jamf Pro ID 1234567890 with PIN code 348201.
#
# ERROR! MDM lock of computer with Jamf Pro ID 1234567890 failed.
# 
# Attempting to send MDM lock to Jamf Pro ID 19251925 with PIN code 12345.
#
# Invalid PIN code data provided: 12345
# 
# Attempting to send MDM lock to Jamf Pro ID AA2319 with PIN code 348206.
#
# Invalid Jamf Pro ID data provided: AA2319
#
# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Computers: Create
#
# Jamf Pro Server Action:
#
# Send Computer Remote Lock Command

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

jamfpro_plist="$HOME/Library/Preferences/com.github.jamfpro-info.plist"
filename="$1"
exitCode=0

if [[ -r "$jamfpro_plist" ]]; then

     if [[ -z "$jamfpro_url" ]]; then
          jamfpro_url=$(defaults read "${jamfpro_plist%.*}" jamfpro_url)
     fi

     if [[ -z "$jamfpro_user" ]]; then
          jamfpro_user=$(defaults read "${jamfpro_plist%.*}" jamfpro_user)
     fi

     if [[ -z "$jamfpro_password" ]]; then
          jamfpro_password=$(defaults read "${jamfpro_plist%.*}" jamfpro_password)
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

# Verify that the file exists and is readable

if [[ -r $filename ]]; then

# Set IFS to read the .csv file by setting commas as the character
# which separates fields in the .csv file

	while IFS=, read jamf_pro_id pin_code || [ -n "$jamf_pro_id" ]; do
      echo "Attempting to send MDM lock to Jamf Pro ID $jamf_pro_id with PIN code $pin_code."

      # All Jamf Pro IDs should be positive numbers and 
      # PIN codes should be all positive numbers that are
      # exactly six digits, so we check for those conditions
      # before proceeding.
      
	  if [[ "$jamf_pro_id" =~ ^[0-9]+$ ]]; then
	     if [[ "$pin_code" =~ ^[0-9]{6} ]]; then

      # Due to IFS redefining field separation, the $pin_code
      # value has a carriage return included. The next check
      # below trims that off before it can cause problems for curl.
      
	         pin_code=$(echo $pin_code | tr -d '\r')

      # If the previous checks succeeded, the curl command below
      # sends the DeviceLock command, which will then be sent out
      # by the Jamf Pro server. The curl command uses the "--fail"
      # function to enable curl to send out an exit code, which we
      # use to test if the API call was successful.

	         if [[ -z "$NoBearerToken" ]]; then
		     	CheckAndRenewAPIToken
		     	/usr/bin/curl --fail -s --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computercommands/command/DeviceLock/passcode/$pin_code/id/$jamf_pro_id" -H "Content-Type: application/xml" -X POST
	         else
		     	/usr/bin/curl --fail -su "${jamfpro_user}:${jamfpro_password}" "${jamfpro_url}/JSSResource/computercommands/command/DeviceLock/passcode/$pin_code/id/$jamf_pro_id" -H "Content-Type: application/xml" -X POST
	         fi

      # curl's exit status is checked below. If curl has an exit status of zero, 
      # the API call was sent and received successfully. If curl has a non-zero 
      # exit status, a warning message is displayed which indicates that the API call
      # has failed. 
		     
		    if [[ $? -eq 0 ]]; then
	         echo -e "\nSuccessfully locked computer with Jamf Pro ID $jamf_pro_id with PIN code $pin_code."
		    else
	         echo -e "\nERROR! MDM lock of computer with Jamf Pro ID $jamf_pro_id failed."
		    fi

      # If the PIN code is not all positive numbers
      # and exactly six digits, a warning message is
      # displayed that an invalid PIN code has been
      # provided.

	     else
            echo -e "\nInvalid PIN code provided: $pin_code"
         fi

      # If the Jamf Pro ID number is not all positive numbers,
      # a warning message is displayed that an invalid Jamf Pro ID number
      # has been provided.

	  else
	      echo -e "\nInvalid Jamf Pro ID provided: $jamf_pro_id"
	  fi
	 echo ""
	done < <(tail -n +2 "$filename")
  
else
	
	# If the provided .csv is not readable, a warning message
	# is displayed that the file does not exist or is not readable.
	
	echo "Input file does not exist or is not readable"
	exitCode=1
fi

exit "$exitCode"
