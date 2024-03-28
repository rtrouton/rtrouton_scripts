#!/bin/bash

# This script is designed to download installer packages from a JCDS 2 distribution point.
# As part of that, it uses the Jamf Pro API to identify the individual IDs of 
# the installer packages stored on a Jamf Pro server then do the following:
#
# 1. Download the package information as XML
# 2. Identify the installer package name from downloaded XML
# 3. Get the download URL for the installer package
# 4. Save the installer package to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Packages: Read
# Jamf Content Distribution Server Files: Read
# 

# Set exit error status

ERROR=0

# If you choose to specify a directory to save the downloaded installer packages into,
# please enter the complete directory path into the JCDSInstallerDownloadDirectory
# variable below.

JCDSInstallerDownloadDirectory=""

# If the JCDSInstallerDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$JCDSInstallerDownloadDirectory" ]]; then
   JCDSInstallerDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded installer packages has not been specified."
   echo "Downloaded installer packages will be stored in $JCDSInstallerDownloadDirectory."
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

initializeJCDSInstallerDownloadDirectory ()
{

if [[ -z "$JCDSInstallerDownloadDirectory" ]]; then
   JCDSInstallerDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded installer packages has not been specified."
   echo "Downloaded installer packages will be stored in $JCDSInstallerDownloadDirectory."
   echo "$JCDSInstallerDownloadDirectory not found.  Creating..."
   mkdir -p $JCDSInstallerDownloadDirectory
   if [[ $? -eq 0 ]]; then
   		echo "Successfully created $JCDSInstallerDownloadDirectory"
   	else
   		echo "Could not create $JCDSInstallerDownloadDirectory"
   		echo "Please make sure the parent directory is writable. Exiting...."
   		ERROR=1
   	fi
else

   # Remove the trailing slash from the JCDSInstallerDownloadDirectory variable if needed.
   JCDSInstallerDownloadDirectory=${JCDSInstallerDownloadDirectory%%/}

   if [[ -d "$JCDSInstallerDownloadDirectory" ]] && [[ -z "$(ls -A "$JCDSInstallerDownloadDirectory")" ]]; then
		echo  "$JCDSInstallerDownloadDirectory exists but is empty. Using existing directory for downloading installer packages."
   elif [[ -n "$JCDSInstallerDownloadDirectory" ]] && [[ ! -d "$JCDSInstallerDownloadDirectory" ]]; then
		echo  "$JCDSInstallerDownloadDirectory does not exist. Creating $JCDSInstallerDownloadDirectory for downloading installer packages."
		mkdir -p $JCDSInstallerDownloadDirectory
			if [[ $? -eq 0 ]]; then
				echo "Successfully created new $JCDSInstallerDownloadDirectory"
			else
				echo "Could not create new $JCDSInstallerDownloadDirectory"
				echo "Please make sure the parent directory is writable. Exiting...."
				ERROR=1
			fi
	fi

fi
}

InstallerPackageDownloadURLRetrieval() {

# Replace spaces in filenames with %20, so that
# curl isn't trying to send a filename with spaces
# as part of an API command.

PackageNameSpacesSanitized=${PackageName// /%20}

# Retrieves a download URL for an installer package
GetJamfProAPIToken
if [[ $(/usr/bin/sw_vers -productVersion | awk -F . '{print $1}') -lt 12 ]]; then
   InstallerPackageURI=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/api/v1/jcds/files/${PackageNameSpacesSanitized}" -H "Accept: application/json" | python -c 'import sys, json; print json.load(sys.stdin)["uri"]')
else
   InstallerPackageURI=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" "${jamfpro_url}/api/v1/jcds/files/${PackageNameSpacesSanitized}" -H "Accept: application/json" | plutil -extract uri raw -)
fi
}

# The following function downloads individual Jamf Pro policy as XML data
# then mines the policy data for the relevant information, which are the
# download URLs for the packages stored in the JCDS distribution point.
#
# Once the download URLs are identified, the installer packages are then
# downloaded to the specified download directory.
#
# If there are installer packages already in the download directory which
# have the same name as an installer package in the JCDS distribution point, 
# the MD5 hash of the existing installer package is checked against the MD5
# hash of the installer package stored in the JCDS distribution point. If 
# the MD5 hashes match, the installer package with the matching name is skipped.
# If the MD5 hashes do not match, the existing installer package in the download 
# directory is deleted and a fresh copy of the installer package is downloaded.

DownloadInstallerPackages(){

	local InstallerPackageID="$1"

	if [[ -n "$InstallerPackageID" ]]; then
		GetJamfProAPIToken
		local DownloadedXMLData=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/packages/id/$InstallerPackageID")
		local PackageName=$( echo "$DownloadedXMLData" | xmllint --xpath '/package/filename/text()' - 2>/dev/null)
		local PackageMD5=$( echo "$DownloadedXMLData" | xmllint --xpath '/package/hash_value/text()' - 2>/dev/null)

		# Download installer packages to the download directory
		echo ""
		if [[ -n "$PackageName" ]]; then
		    InstallerPackageCheck=$(ls -a "$JCDSInstallerDownloadDirectory" | grep "$PackageName")
		    
		    # Only download installer packages that haven't already been downloaded.
		    
		    if [[ -n "$InstallerPackageCheck" ]]; then
		       echo "$PackageName found in $JCDSInstallerDownloadDirectory."
		       echo "Checking MD5 hash of $PackageName in $JCDSInstallerDownloadDirectory to verify match with $PackageName on $jamfpro_url..."
		       # Check MD5 hash of existing package to verify match with installer package on the Jamf Pro server.
		       InstallerPackageMD5Check=$(md5 -q "${JCDSInstallerDownloadDirectory}"/"${PackageName}")
		       if [[ "$InstallerPackageMD5Check" == "$PackageMD5" ]]; then
		       	   echo "MD5 hash of $PackageName in $JCDSInstallerDownloadDirectory matches $PackageName on $jamfpro_url."
		       	   echo "$PackageName is available in $JCDSInstallerDownloadDirectory."
		       else
		       	   echo "MD5 hash of $PackageName in $JCDSInstallerDownloadDirectory does not match $PackageName on $jamfpro_url."
		       	   echo "Deleting $PackageName from $JCDSInstallerDownloadDirectory."
		       	   rm -rf "${JCDSInstallerDownloadDirectory}"/"${PackageName}"
		       	   echo "Downloading $PackageName to $JCDSInstallerDownloadDirectory."
		       	   InstallerPackageDownloadURLRetrieval
		       	   curl --progress-bar ${InstallerPackageURI} -X GET --output "${JCDSInstallerDownloadDirectory}"/"${PackageName}"
		       	   
		       	   # Verify the package exists following the download.
		       	   
		       	   InstallerPackageCheck=$(ls -a "$JCDSInstallerDownloadDirectory" | grep "$PackageName")
		       	   if [[ -n "$InstallerPackageCheck" ]]; then
		       	      echo "$PackageName is available in $JCDSInstallerDownloadDirectory."
		       	   else
		       	      echo "ERROR: $PackageName not found in $JCDSInstallerDownloadDirectory."
		       	   fi
		       fi
		    elif [[ -z "$InstallerPackageCheck" ]]; then
		       echo "Downloading $PackageName to $JCDSInstallerDownloadDirectory."
		       InstallerPackageDownloadURLRetrieval
		       curl --progress-bar ${InstallerPackageURI} -X GET --output "${JCDSInstallerDownloadDirectory}"/"${PackageName}"
		       
		       # Verify the package exists following the download.
		       
		       InstallerPackageCheck=$(ls -a "$JCDSInstallerDownloadDirectory" | grep "$PackageName")
		       if [[ -n "$InstallerPackageCheck" ]]; then
		          echo "$PackageName is available in $JCDSInstallerDownloadDirectory."
		       else
		          echo "ERROR: $PackageName not found in $JCDSInstallerDownloadDirectory."
		       fi
		    fi
		fi
	fi
}

initializeJCDSInstallerDownloadDirectory

if [[ $ERROR -eq 0 ]]; then
  
# Download all Jamf Pro installer package ID numbers

GetJamfProAPIToken
InstallerPackageIDList=$(/usr/bin/curl -s --header "Authorization: Bearer ${api_token}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/packages" | xmllint --xpath '//id' - 2>/dev/null)  

InstallerPackageIDs=$(echo "$InstallerPackageIDList" | grep -Eo "[0-9]+")

for anID in ${InstallerPackageIDs}; do

   # Download installer packages from the JCDS distribution point.
   DownloadInstallerPackages $anID
   
done

fi

exit $ERROR