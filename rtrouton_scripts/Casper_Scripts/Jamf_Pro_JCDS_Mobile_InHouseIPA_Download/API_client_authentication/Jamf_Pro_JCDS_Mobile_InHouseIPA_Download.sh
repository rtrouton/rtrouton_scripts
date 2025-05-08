#!/bin/bash

# This script is designed to download IPA files from a JCDS 2 distribution point.
# As part of that, it uses the Jamf Pro API to identify the individual IDs of 
# the IPA files stored on a Jamf Pro server then do the following:
#
# 1. Download the IPA information as XML
# 2. Identify the IPA file name from downloaded XML
# 3. Identify if this is an in-house app, where the IPA file can be downloaded.
# 3. Get the download URL for the IPA file
# 4. Save the IPA file to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# API Role permissions:
#
# Read Mobile Device Apps
# Read Jamf Cloud Distribution Service Files 
# 

# Set exit error status

ERROR=0

# If you choose to specify a directory to save the downloaded IPA files into,
# please enter the complete directory path into the JCDSIPADownloadDirectory
# variable below.

JCDSIPADownloadDirectory=""

# If the JCDSIPADownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$JCDSIPADownloadDirectory" ]]; then
   JCDSIPADownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded IPA files has not been specified."
   echo "Downloaded IPA files will be stored in $JCDSIPADownloadDirectory."
fi

# If you choose to hardcode API information into the script, set one or more of the following values:
#
# The Jamf Pro URL
# An API client ID on the Jamf Pro server with sufficient API privileges
# The API client secret for the API client ID


# Set the Jamf Pro URL here if you want it hardcoded.
jamfpro_url=""	    

# Set the Jamf Pro API Client ID here if you want it hardcoded.
jamfpro_api_client_id=""

# Set the Jamf Pro API Client Secret here if you want it hardcoded.
jamfpro_api_client_secret=""	

# If you do not want to hardcode API information into the script, you can also store
# these values in a ~/Library/Preferences/com.github.jamfpro-info.plist file.
#
# To create the file and set the values, run the following commands and substitute
# your own values where appropriate:
#
# To store the Jamf Pro URL in the plist file:
# defaults write com.github.jamfpro-info jamfpro_url https://jamf.pro.server.goes.here:port_number_goes_here
#
# To store the Jamf Pro API Client ID in the plist file:
# defaults write com.github.jamfpro-info jamfpro_api_client_id api_client_id_information_goes_here
#
# To store the Jamf Pro API Client Secret in the plist file:
# defaults write com.github.jamfpro-info jamfpro_api_client_secret api_client_secret_information_goes_here
#
# If the com.github.jamfpro-info.plist file is available, the script will read in the
# relevant information from the plist file.

if [[ -f "$HOME/Library/Preferences/com.github.jamfpro-info.plist" ]]; then

  if [[ -z "$jamfpro_url" ]]; then
     jamfpro_url=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_url)
  fi     

  if [[ -z "$jamfpro_api_client_id" ]]; then
     jamfpro_api_client_id=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_api_client_id)
  fi
  
  if [[ -z "$jamfpro_api_client_secret" ]]; then
     jamfpro_api_client_secret=$(defaults read $HOME/Library/Preferences/com.github.jamfpro-info jamfpro_api_client_secret)
  fi

fi

# If the Jamf Pro URL, the API Client ID or the API Client Secret aren't available
# otherwise, you will be prompted to enter the requested URL or API client credentials.

if [[ -z "$jamfpro_url" ]]; then
     read -p "Please enter your Jamf Pro server URL : " jamfpro_url
fi

if [[ -z "$jamfpro_api_client_id" ]]; then
     read -p "Please enter your Jamf Pro API client ID : " jamfpro_api_client_id
fi

if [[ -z "$jamfpro_api_client_secret" ]]; then
     read -p "Please enter the API client secret for the $jamfpro_api_client_id API ID client: " -s jamfpro_api_client_secret
fi

echo ""

GetJamfProAPIToken() {

# This function uses the API client ID and client ID secret to get a new bearer token for API authentication.

if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | python -c 'import sys, json; print json.load(sys.stdin)["access_token"]')
else
   api_token=$(/usr/bin/curl -s -X POST "$jamfpro_url/api/oauth/token" --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode client_id="$jamfpro_api_client_id" --data-urlencode 'grant_type=client_credentials' --data-urlencode client_secret="$jamfpro_api_client_secret" | plutil -extract access_token raw -)
fi

}

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_url=${jamfpro_url%%/}

initializeJCDSIPADownloadDirectory ()
{

if [[ -z "$JCDSIPADownloadDirectory" ]]; then
   JCDSIPADownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded IPA files has not been specified."
   echo "Downloaded IPA files will be stored in $JCDSIPADownloadDirectory."
   echo "$JCDSIPADownloadDirectory not found.  Creating..."
   mkdir -p $JCDSIPADownloadDirectory
   if [[ $? -eq 0 ]]; then
   		echo "Successfully created $JCDSIPADownloadDirectory"
   	else
   		echo "Could not create $JCDSIPADownloadDirectory"
   		echo "Please make sure the parent directory is writable. Exiting...."
   		ERROR=1
   	fi
else

   # Remove the trailing slash from the JCDSIPADownloadDirectory variable if needed.
   JCDSIPADownloadDirectory=${JCDSIPADownloadDirectory%%/}

   if [[ -d "$JCDSIPADownloadDirectory" ]] && [[ -z "$(ls -A "$JCDSIPADownloadDirectory")" ]]; then
		echo  "$JCDSIPADownloadDirectory exists but is empty. Using existing directory for downloading IPA files."
   elif [[ -n "$JCDSIPADownloadDirectory" ]] && [[ ! -d "$JCDSIPADownloadDirectory" ]]; then
		echo  "$JCDSIPADownloadDirectory does not exist. Creating $JCDSIPADownloadDirectory for downloading IPA files."
		mkdir -p $JCDSIPADownloadDirectory
			if [[ $? -eq 0 ]]; then
				echo "Successfully created new $JCDSIPADownloadDirectory"
			else
				echo "Could not create new $JCDSIPADownloadDirectory"
				echo "Please make sure the parent directory is writable. Exiting...."
				ERROR=1
			fi
	fi

fi
}

IPADownloadURLRetrieval() {

# Replace spaces in filenames with %20, so that
# curl isn't trying to send a filename with spaces
# as part of an API command.

IPAFilenameSpacesSanitized=${IPAFilename// /%20}

# Retrieves a download URL for an IPA file
GetJamfProAPIToken
if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   IPAURI=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/api/v1/jcds/files/${IPAFilenameSpacesSanitized}" -H "Accept: application/json" | python -c 'import sys, json; print json.load(sys.stdin)["uri"]')
else
   IPAURI=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/api/v1/jcds/files/${IPAFilenameSpacesSanitized}" -H "Accept: application/json" | plutil -extract uri raw -)
fi
}

# The following function downloads individual Jamf Pro mobile device application entries as XML data
# then mines the policy data for the relevant information used to identify the IPA files stored on the
# the JCDS distribution point. Once the IPA files are identified, the individual download URLs are 
# identified for the IPA files stored in the JCDS distribution point.
#
# Once the download URLs are identified, the IPA files are then
# downloaded to the specified download directory.
#
# If there are IPA files already in the download directory which
# have the same name as an IPA file in the JCDS distribution point, 
# the MD5 hash of the existing IPA file is checked against the MD5
# hash of the IPA file stored in the JCDS distribution point. If 
# the MD5 hashes match, the IPA file with the matching name is skipped.
# If the MD5 hashes do not match, the existing IPA file in the download 
# directory is deleted and a fresh copy of the IPA file is downloaded.

DownloadIPAFiles(){

	local IPAID="$1"

	if [[ -n "$IPAID" ]]; then

		GetJamfProAPIToken
		local DownloadedXMLData=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledeviceapplications/id/$IPAID")
		local DownloadedJSONData=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/json" "${jamfpro_url}/api/v1/jcds/files" )
		local IPAFilename=$( echo "$DownloadedXMLData" | xmllint --xpath '/mobile_device_application/general/ipa/name/text()' - 2>/dev/null)
		local IPAInHouse=$( echo "$DownloadedXMLData" | xmllint --xpath '/mobile_device_application/general/internal_app/text()' - 2>/dev/null)
		local IPAInHouseMD5=$( echo "$DownloadedJSONData" | awk -v IPAFileNameMatch="$IPAFilename" '$0~IPAFileNameMatch {c=NR+2}(NR<=c){print}' - 2>/dev/null | awk '/md5/ {print $3}' | sed -e 's/"//g' -e 's/,//g')

		# Download IPA files to the download directory
		if [[ -n "$IPAFilename" ]] && [[ "$IPAInHouse" = "false" ]] ; then
		    IPACheck=$(ls -a "$JCDSIPADownloadDirectory" | grep "$IPAFilename")
		    echo ""
		    # Only download IPA files that haven't already been downloaded.
		    
		    if [[ -n "$IPACheck" ]]; then
		       echo "$IPAFilename found in $JCDSIPADownloadDirectory."
		       echo "Checking MD5 hash of $IPAFilename in $JCDSIPADownloadDirectory to verify match with $IPAFilename on $jamfpro_url..."
		       # Check MD5 hash of existing IPA file to verify match with IPA file on the Jamf Pro server.
		       IPAMD5Check=$(md5 -q "${JCDSIPADownloadDirectory}"/"${IPAFilename}")
		       if [[ "$IPAMD5Check" == "$IPAInHouseMD5" ]]; then
		       	   echo "MD5 hash of $IPAFilename in $JCDSIPADownloadDirectory matches $IPAFilename on $jamfpro_url."
		       	   echo "$IPAFilename is available in $JCDSIPADownloadDirectory."
		       else
		       	   echo "MD5 hash of $IPAFilename in $JCDSIPADownloadDirectory does not match $IPAFilename on $jamfpro_url."
		       	   echo "Deleting $IPAFilename from $JCDSIPADownloadDirectory."
		       	   rm -rf "${JCDSIPADownloadDirectory}"/"${IPAFilename}"
		       	   echo "Downloading $IPAFilename to $JCDSIPADownloadDirectory."
		       	   IPADownloadURLRetrieval
		       	   curl --progress-bar ${IPAURI} -X GET --output "${JCDSIPADownloadDirectory}"/"${IPAFilename}"
		       	   
		       	   # Verify the IPA file exists following the download.
		       	   
		       	   IPACheck=$(ls -a "$JCDSIPADownloadDirectory" | grep "$IPAFilename")
		       	   if [[ -n "$IPACheck" ]]; then
		       	      echo "$IPAFilename is available in $JCDSIPADownloadDirectory."
		       	   else
		       	      echo "ERROR: $IPAFilename not found in $JCDSIPADownloadDirectory."
		       	   fi
		       fi

		    elif [[ -z "$IPACheck" ]]; then
		       echo "Downloading $IPAFilename to $JCDSIPADownloadDirectory."
		       IPADownloadURLRetrieval
		       curl --progress-bar ${IPAURI} -X GET --output "${JCDSIPADownloadDirectory}"/"${IPAFilename}"
		       
		       # Verify the IPA file exists following the download.
		       
		       IPACheck=$(ls -a "$JCDSIPADownloadDirectory" | grep "$IPAFilename")
		       if [[ -n "$IPACheck" ]]; then
		          echo "$IPAFilename is available in $JCDSIPADownloadDirectory."
		       else
		          echo "ERROR: $IPAFilename not found in $JCDSIPADownloadDirectory."
		       fi
		    fi
		fi
	fi
}

initializeJCDSIPADownloadDirectory

if [[ $ERROR -eq 0 ]]; then
  
  # Download all Jamf Pro IPA file ID numbers
  
   GetJamfProAPIToken
   IPAIDList=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/mobiledeviceapplications" | xmllint --xpath '//id' - 2>/dev/null)  

IPAIDs=$(echo "$IPAIDList" | grep -Eo "[0-9]+")

for anID in ${IPAIDs}; do

   # Download IPA files from the JCDS distribution point.
   DownloadIPAFiles $anID
   
done

fi

exit $ERROR