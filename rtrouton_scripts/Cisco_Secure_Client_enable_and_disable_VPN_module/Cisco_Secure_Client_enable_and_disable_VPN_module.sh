#!/bin/bash

# This script enables and disables the VPN module for Cisco Secure Connect.

vpn_setting_file="/opt/cisco/secureclient/vpn/profile/VPNDisable_ServiceProfile.xml"

# Detect the current setting for the VPN module being enabled or disabled.
#
# If disabled, the following value should be set in the XML file:
#
# <ServiceDisable>true</ServiceDisable>
#
# If enabled, the following value should be set in the XML file:
#
# <ServiceDisable>false</ServiceDisable>

vpn_setting_status=$(/usr/bin/xmllint --xpath "//*[local-name()='ServiceDisable']/text()" "${vpn_setting_file}")

# This function allows us to display a message box to the user. 
# The script checks for the existence of the system's AlertNoteIcon 
# and uses this, if available.

displayDialog()
{
	local dialogMessage="$1"
	local dialogButtons="$2"
	local defaultButton="$3"
	local dialogIcon="$4"
	local dialogGiveUp="$5"
	
	# set up our buttons and make sure we have at least
	# an OK button if nothing else has been specified

	if [[ -z "${dialogButtons}" ]]; then 
		dialogButtons="\"OK\""
	else
		dialogButtons=$(echo "${dialogButtons}" | /usr/bin/sed -e 's/^/"/' -e 's/$/"/' -e 's/,/","/g')
	fi

	# if not otherwise specified, the last button is enabled
	local allButtons=$(echo "${dialogButtons}" | /usr/bin/awk -F"," '{print NF-1}')
	local lastButton=$((${allButtons} + 1))
	if [[ ! "${defaultButton}" =~ ^[0-9]+$ || ${defaultButton} -le 0 || ${defaultButton} -gt ${lastButton} ]]; then defaultButton="${lastButton}"; fi
	
	# we set the dialog timeout to 0 if not otherwise specified
 	if [[ ! "${dialogGiveUp}" =~ ^[0-9]+$ ]]; then dialogGiveUp=0; fi
 	
 	# make sure double quotation marks are properly escaped
 	dialogMessage=$(echo "${dialogMessage}" | /usr/bin/sed -e 's/"/\\\"/g')
	
	# get the currently logged-in user
	currentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
	
	# set the dialog's icon
	if [[ -r "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" ]]; then
			dialogIcon="alias POSIX file \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns\""
	fi

	buttonPressed=$(/usr/bin/sudo -u "${currentUser}" /usr/bin/osascript << EOF
tell application "System Events"
try
activate
display dialog "${dialogMessage}" with icon ${dialogIcon} buttons {${dialogButtons}} default button ${defaultButton} giving up after ${dialogGiveUp}
return (button returned of the result)
end try
end tell
EOF
)

	echo "${buttonPressed}"
}

# If the VPN module is enabled, ask the user if they want to disable it.

if [[ "${vpn_setting_status}" = "false" ]]; then
    userChoice=$(displayDialog "The Cisco Secure Client VPN functionality is currently enabled. Disable the VPN?" "Yes,No" "" "0" "60")
    
    if [[ "${userChoice}" = "Yes" ]]; then
	   sed -i '' -e "s/<ServiceDisable>false<\/ServiceDisable>/<ServiceDisable>true<\/ServiceDisable>/g" "${vpn_setting_file}"
	   echo "User chose to disable VPN."
    elif [[ "${userChoice}" = "No" ]]; then
	   echo "User chose not to disable VPN."
    fi
fi

# If the VPN module is disabled, ask the user if they want to enable it.

if [[ "${vpn_setting_status}" = "true" ]]; then
    userChoice=$(displayDialog "The Cisco Secure Client VPN functionality is currently disabled. Enable the VPN?" "Yes,No" "" "0" "60")
    
    if [[ "${userChoice}" = "Yes" ]]; then
	   sed -i '' -e "s/<ServiceDisable>true<\/ServiceDisable>/<ServiceDisable>false<\/ServiceDisable>/g" "${vpn_setting_file}"
	   echo "User chose to enable VPN."
    elif [[ "${userChoice}" = "No" ]]; then
	   echo "User chose not to enable VPN."  
    fi
fi