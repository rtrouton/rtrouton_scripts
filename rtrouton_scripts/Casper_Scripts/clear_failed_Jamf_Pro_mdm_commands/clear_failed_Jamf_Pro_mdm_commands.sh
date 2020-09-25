#!/bin/bash

# This script is designed to be run on a Mac via a Jamf Pro policy to clear failed MDM commands on a regular basis. This
# allows failed MDM commands or profiles to be re-pushed automatically.
#
# API rights required by account specified in jamfpro_user variable:
#
# Jamf Pro Server Objects:
#
# Computers: Read
#
# Jamf Pro Server Actions:
#
# Flush MDM Commands
#
# Original script from https://aporlebeke.wordpress.com/2019/01/04/auto-clearing-failed-mdm-commands-for-macos-in-jamf-pro/
# GitHub gist: https://gist.github.com/apizz/48da271e15e8f0a9fc6eafd97625eacd#file-ea_clear_failed_mdm_commands-sh

error=0

jamfpro_server_address=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf jss_url)
jamfpro_user="username_goes_here"
jamfpro_password="password_goes_here"
machineUUID=$(/usr/sbin/ioreg -rd1 -c IOPlatformExpertDevice | /usr/bin/awk '/IOPlatformUUID/ { gsub(/"/,"",$3); print $3; }')

# Remove the trailing slash from the Jamf Pro URL if needed.
jamfpro_server_address=${jamfpro_server_address%%/}


# These functions use the Jamf Pro Classic API to perform various tasks.
#
# ClearFailedMDMCommands - Clears all failed MDM commands associated with a Jamf Pro computer ID.
# GetJamfProComputerID - Uses the Mac's hardware UUID to identify the Mac's computer ID in Jamf Pro.
# GetFailedMDMCommands - Uses the Mac's hardware UUID to download the list of failed MDM commands.

ClearFailedMDMCommands () {
	/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_server_address}/JSSResource/commandflush/computers/id/${computerID}/status/Failed" -X DELETE
}

GetJamfProComputerID () {
	local computerID=$(/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_server_address}/JSSResource/computers/udid/${machineUUID}" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer/general/id/text()" - 2>/dev/null)
	echo "$computerID"
}

GetFailedMDMCommands () {
	local xmlResult=$(/usr/bin/curl -sfu "${jamfpro_user}:${jamfpro_password}" "${jamfpro_server_address}/JSSResource/computerhistory/udid/${machineUUID}/subset/Commands" -X GET -H "accept: application/xml" | /usr/bin/xmllint --xpath "/computer_history/commands/failed[node()]" - 2>/dev/null)
	echo "$xmlResult"
}


# Build a list of failed MDM commands associated with a particular Mac.

xmlResult=$(GetFailedMDMCommands)

# Clear failed MDM commands if they exist

if [[ -n "$xmlResult" ]]; then

	computerID=$(GetJamfProComputerID)

	if [[ "$computerID" =~ ^[0-9]+$ ]]; then
	
	    echo "Removing failed MDM commands....."
	    ClearFailedMDMCommands

	  	if [[ $? -eq 0 ]]; then
	    	echo "Removed failed MDM commands."
	  	else
	   		echo "ERROR! Problem occurred when removing failed MDM commands!"
	   		error=1
	  	fi
	  
	else
	   echo "ERROR! Problem occurred when identifying Jamf Pro computer ID!"
	   error=1
	fi

else
	echo "No failed MDM commands found."
fi

exit $error