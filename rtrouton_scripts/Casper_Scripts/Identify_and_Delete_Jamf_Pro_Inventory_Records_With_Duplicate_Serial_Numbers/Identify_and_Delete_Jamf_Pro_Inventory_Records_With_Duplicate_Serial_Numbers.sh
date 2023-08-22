#!/bin/bash

# This script identifies all Mac Jamf Pro inventory records which have the same Apple serial number
# as at least one more Mac's inventory record. 
#
# This duplication is usually caused by a Mac having a logic board repair, as the Mac's existing serial number
# will be flashed onto the replacement logic board but the board itself will have a new and unique hardware UUID.
# If the Mac is subsequently un-enrolled and re-enrolled into Jamf Pro, the new hardware UUID will prompt Jamf Pro
# to set up a new inventory record for the Mac.
#
# Once the duplicate serial numbers are identified, the script takes the following actions:
#
# 1. Loop through the duplicate serial number list and get all of the associated Jamf Pro computer IDs
# 2. Loop through the Jamf Pro IDs and identify the IDs with the most recent enrollment dates.
# 3. Verify that the individual Jamf Pro IDs are associated with Macs, as opposed to virtual machines running macOS.
# 4. Loop through the list of identified Macs with Jamf Pro IDs and delete all Macs except for the one with
#    the most recent enrollment date.
# 5. Create a report in tab-separated value (.tsv) format which contains the following information
#    about the deleted Macs
#
#    Jamf Pro ID
#    Manufacturer
#    Model
#    Serial Number
#    Hardware UDID

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
jamf_plist="$HOME/Library/Preferences/com.github.jamfpro-info1.plist"

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

echo

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

# If configured to get one, get a Jamf Pro API Bearer Token

if [[ -z "$NoBearerToken" ]]; then
   GetJamfProAPIToken
fi

IFS=$'\n'

echo "Downloading list of computer information..."

if [[ -z "$NoBearerToken" ]]; then
	CheckAndRenewAPIToken
	ComputerXML=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/subset/basic" -H "Accept: application/xml" 2>/dev/null)
else
	ComputerXML=$(/usr/bin/curl -sfu "$jamfpro_user:$jamfpro_password" "${jamfpro_url}/JSSResource/computers/subset/basic" -H "Accept: application/xml" 2>/dev/null)
fi

if [[ -n "$ComputerXML" ]]; then

	echo "Checking for duplicates ..."
	
	# get a list of serial number tags
	SerialList=$(echo "$ComputerXML" | xmllint --xpath "//computers/computer/serial_number" - 2>/dev/null)

	# get a list of sorted serial numbers
	SortedSerialList=$(echo "$SerialList" | grep -Eo "<serial_number[^<]*" | sed -n 's/<serial_number\/*>\([^<]*\).*/\1/p' | sort)

	# get a list of duplicate serials
	Duplicate_Computer_Serials_List=$(echo "$SortedSerialList" | uniq -d)
	
	if [[ -n "$Duplicate_Computer_Serials_List" ]]; then
	  printf "Found %d serial number(s) with duplicates\n\n" $(echo "$Duplicate_Computer_Serials_List" | grep -Ec "^")
	
	  # loop through all duplicates and get the respective computer ids
	  for aDuplicateSerial in ${Duplicate_Computer_Serials_List}; do
	
		# check the variable to skip blank serial numbers
		if [[ -n "$aDuplicateSerial" ]]; then
		
			echo
			echo "Processing serial number $aDuplicateSerial"
		
			# get all ids matching the serial
			matchingIDs=$(echo "$ComputerXML" | xmllint --xpath "//computers/computer[serial_number='$aDuplicateSerial']/id" - 2>/dev/null | grep -Eo "<id[^<]*" | grep -Eo "[0-9]+")
			IDtoKeep=
			IgnoredIDs=()
			NewestEnrollmentDate=0
			
			# loop through all ids and get the one with the newest enrollment date
			for anID in ${matchingIDs}; do
				
				if [[ -z "$NoBearerToken" ]]; then
					CheckAndRenewAPIToken
					ComputerRecord=$(/usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/id/$anID" -H "Accept: application/xml" 2>/dev/null)
				else
					ComputerRecord=$(/usr/bin/curl -sfu "$jamfpro_user:$jamfpro_password" "${jamfpro_url}/JSSResource/computers/id/$anID" -H "Accept: application/xml" 2>/dev/null)
				fi
				
				MachineModel=$(echo "$ComputerRecord" | xmllint --xpath "//computer/hardware/model_identifier/text()" - 2>/dev/null)
				
				if [[ ! "$MachineModel" =~ ^i?Mac.*$ ]]; then
				
				   echo "Computer with id $anID seems not to be a Mac ($MachineModel). Will be ignored."
				   IgnoredIDs+=($anID)
				   
				else
				
					echo "Getting enrollment date of computer with id $anID"

					EnrollmentDate=$(echo "$ComputerRecord" | xmllint --xpath "//computer/general/last_enrolled_date_epoch/text()" - 2>/dev/null)
				  
				 	if [[ "$EnrollmentDate" =~ ^[0-9]+$ && $EnrollmentDate -gt $NewestEnrollmentDate ]]; then
						NewestEnrollmentDate=$EnrollmentDate
						IDtoKeep=$anID
				  	fi
				fi	
					
			done
			
			echo "Keeping computer record with id $IDtoKeep"
			
			# loop through the ids again and delete all computers 
			# except the one with the newest enrollment date
		 	for anID in ${matchingIDs}; do
			
				if [[ ! "$anID" = "$IDtoKeep" && ! " ${IgnoredIDs[@]} " =~ "$anID " ]]; then
					
					if [[ ! -f "$report_file" ]]; then
					   touch "$report_file"
					   printf "Jamf Pro ID Number\tMake\tModel\tSerial Number\tUDID\n" > "$report_file"
					fi
					
					Make=$(echo "$ComputerRecord" | xmllint --xpath '//computer/hardware/make/text()' - 2>/dev/null)
					SerialNumber=$(echo "$ComputerRecord" | xmllint --xpath '//computer/general/serial_number/text()' - 2>/dev/null)
					UDIDIdentifier=$(echo "$ComputerRecord" | xmllint --xpath '//computer/general/udid/text()' - 2>/dev/null)				
					
					
					if [[ -z "$NoBearerToken" ]]; then
					   CheckAndRenewAPIToken
					   /usr/bin/curl -sf --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/JSSResource/computers/id/$anID" -X DELETE
					else
					   /usr/bin/curl -sfu "$jamfpro_user:$jamfpro_password" "${jamfpro_url}/JSSResource/computers/id/$anID" -X DELETE
					fi
					
					if [[ $? -eq 0 ]]; then
						echo "Deleted computer record with id $anID"
						printf "$anID\t$Make\t$MachineModel\t$SerialNumber\t$UDIDIdentifier\n" >> "$report_file"
					else
						echo "ERROR! Failed to delete computer record with id $anID"
					fi
				fi
				
			done
			
		fi
	done
	
  if [[ -f "$report_file" ]]; then
     echo "Report on deleted Macs available here: $report_file"
  fi

 else
   echo "No duplicate serial numbers detected."
 fi

fi

exit 0