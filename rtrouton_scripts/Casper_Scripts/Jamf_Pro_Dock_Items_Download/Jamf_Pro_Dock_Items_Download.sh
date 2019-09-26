#!/bin/bash

# This script is designed to use the Jamf Pro API to identify the individual IDs of 
# the dock items stored on a Jamf Pro server then do the following:
#
# 1. Back up existing downloaded dock item directory
# 2. Download the dock item as XML
# 3. Identify the dock item name
# 4. Save the dock item to a specified directory

# If setting up a specific user account with limited rights, here are the required API privileges
# for the account on the Jamf Pro server:
#
# Jamf Pro Server Objects:
#
# Dock Items: Read

# Set exit error status

ERROR=0

# If you choose to specify a directory to save the downloaded dock items into,
# please enter the complete directory path into the DockItemDownloadDirectory
# variable below.


DockItemDownloadDirectory=""

# If the DockItemDownloadDirectory isn't specified above, a directory will be
# created and the complete directory path displayed by the script.

if [[ -z "$DockItemDownloadDirectory" ]]; then
   DockItemDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded dock items has not been specified."
   echo "Downloaded dock items will be stored in $DockItemDownloadDirectory."
fi

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


initializeDockItemDownloadDirectory ()
{

if [[ -z "$DockItemDownloadDirectory" ]]; then
   DockItemDownloadDirectory=$(mktemp -d)
   echo "A location to store downloaded dock items has not been specified."
   echo "Downloaded dock items will be stored in $DockItemDownloadDirectory."
   echo "$DockItemDownloadDirectory not found.  Creating..."
   mkdir -p $DockItemDownloadDirectory
   if [[ $? -eq 0 ]]; then
   		echo "Successfully created $DockItemDownloadDirectory"
   	else
   		echo "Could not create $DockItemDownloadDirectory"
   		echo "Please make sure the parent directory is writable. Exiting...."
   		ERROR=1
   	fi
else

   # Remove the trailing slash from the DockItemDownloadDirectory variable if needed.
   DockItemDownloadDirectory=${DockItemDownloadDirectory%%/}

   if [[ -d "$DockItemDownloadDirectory" ]] && [[ -z "$(ls -A "$DockItemDownloadDirectory")" ]]; then
		echo  "$DockItemDownloadDirectory exists but is empty. Using existing directory for downloading dock items."
   elif [[ -n "$DockItemDownloadDirectory" ]] && [[ ! -d "$DockItemDownloadDirectory" ]]; then
		echo  "$DockItemDownloadDirectory does not exist. Creating $DockItemDownloadDirectory for downloading dock items."
		mkdir -p $DockItemDownloadDirectory
			if [[ $? -eq 0 ]]; then
				echo "Successfully created new $DockItemDownloadDirectory"
			else
				echo "Could not create new $DockItemDownloadDirectory"
				echo "Please make sure the parent directory is writable. Exiting...."
				ERROR=1
			fi
	fi

fi
}

DownloadDockItem(){

	# Download the dock item information as raw XML,
	# then format it to be readable.
	echo "Downloading dock items from $jamfpro_url..."
	FormattedDockItem=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/dockitems/id/${ID}" -X GET | xmllint --format - )

	# Identify and display the advanced computer search's name.
	DisplayName=$(echo "$FormattedDockItem" | xpath "/dock_item/name/text()" 2>/dev/null | sed -e 's|:|(colon)|g' -e 's/\//\\/g')
	echo "Downloaded dock item is named: $DisplayName"

	# Save the downloaded advanced computer search.

	echo "Saving ${DisplayName}.xml file to $DockItemDownloadDirectory."
	
	if [[ -d "$DockItemDownloadDirectory" ]]; then
	  echo "$FormattedDockItem" > "$DockItemDownloadDirectory/${DisplayName}.xml" 
	else
	  mkdir -p "$DockItemDownloadDirectory/$PolicyCategory"
	  echo "$FormattedDockItem" > "$DockItemDownloadDirectory/${DisplayName}.xml"
	fi
}

# Back up existing dock item downloads and create dock item download directory.

initializeDockItemDownloadDirectory

if [[ $ERROR -eq 0 ]]; then

  # Download latest version of all dock items

  DockItem_id_list=$(curl -su "${jamfpro_user}:${jamfpro_password}" -H "Accept: application/xml" "${jamfpro_url}/JSSResource/dockitems" | xpath "//id" 2>/dev/null)

  DockItem_id=$(echo "$DockItem_id_list" | grep -Eo "[0-9]+")

  # Download latest version of all dock items. For performance reasons, we
  # parallelize the execution.
  MaximumConcurrentJobs=10
  ActiveJobs=0


  for ID in ${DockItem_id}; do

   ((ActiveJobs=ActiveJobs%MaximumConcurrentJobs)); ((ActiveJobs++==0)) && wait
   DownloadDockItem &

  done

fi

exit $ERROR