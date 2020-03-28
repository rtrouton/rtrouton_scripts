#!/bin/bash

# Enables the Mac to boot into the following:
# 
# * Recovery 
# * Internet Recovery
# * Diagnostics
# * Internet Diagnostics
#
# For information about Diagnostics: https://support.apple.com/HT202731
# For information about Recovery: https://support.apple.com/HT201314


# some variables we have to declare first
exitCode=0

# This is our logging function. It logs to syslog and also prints the
# log message to STDOUT to make sure, it appears in the Jamf Pro policy log.
log()
{
	local errorMessage="$1"
	echo "$errorMessage"
	/usr/bin/logger "SetBootMode: $errorMessage"
}

# Here we have a function that allows us to display a message box 
# to the user. If Jamf Self Service is installed on the machine, we 
# use its icon, otherwise we check for the existence of the system's
# AlertNoteIcon and use this, if available. If none of those icons 
# are available, we use a generic one.
displayDialog()
{
	local dialogMessage="$1"
	local dialogButtons="$2"
	local defaultButton="$3"
	local dialogIcon="$4"
	local dialogGiveUp="$5"
	
	# set up our buttons and make sure we have at least
	# an OK button if nothing else has been specified
	if [[ -z "$dialogButtons" ]]; then 
		dialogButtons="\"OK\""
	else
		dialogButtons=$(echo "$dialogButtons" | /usr/bin/sed -e 's/^/"/' -e 's/$/"/' -e 's/,/","/g')
	fi

	# if not otherwise specified, the last button is enabled
	local allButtons=$(echo "$dialogButtons" | /usr/bin/awk -F"," '{print NF-1}')
	local lastButton=$(($allButtons + 1))
	if [[ ! "$defaultButton" =~ ^[0-9]+$ || $defaultButton -le 0 || $defaultButton -gt $lastButton ]]; then defaultButton="$lastButton"; fi
	
	# we set the dialog timeout to 0 if not otherwise specified
 	if [[ ! "$dialogGiveUp" =~ ^[0-9]+$ ]]; then dialogGiveUp=0; fi
 	
 	# make sure double quotation marks are properly escaped
 	dialogMessage=$(echo "$dialogMessage" | /usr/bin/sed -e 's/"/\\\"/g')
	
	# get the currently logged-in user
	currentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
	
	# set the dialog's icon
	if [[ ! "$dialogIcon" =~ ^[0-9]+$ || "$dialogIcon" -gt 2 ]]; then
		local selfServicePath="/Applications/Self Service.app"
		local iconName=$(/usr/bin/defaults read "/Applications/Self Service.app/Contents/Info" CFBundleIconFile 2>/dev/null)
		dialogIcon="1"

		if [[ -n "$iconName" && -r "$selfServicePath/Contents/Resources/$iconName.icns" ]]; then
			dialogIcon="alias POSIX file \"$selfServicePath/Contents/Resources/$iconName.icns\""
		
		elif [[ -r "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns" ]]; then
			dialogIcon="alias POSIX file \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertNoteIcon.icns\""
		fi
	fi

	buttonPressed=$(/usr/bin/sudo -u "$currentUser" /usr/bin/osascript << EOF
tell application "System Events"
try
activate
display dialog "$dialogMessage" with icon $dialogIcon buttons {$dialogButtons} default button $defaultButton giving up after $dialogGiveUp
return (button returned of the result)
end try
end tell
EOF
)

	echo "$buttonPressed"
}


# this script must be run with root privileges
if [[ "$(/usr/bin/id -u)" -eq 0 ]]; then

	# bootMode is a 2-bit binary value defined as follows:
	# the most significant bit (MSB) specifies the actual boot mode. "Recovery" is 0 and "Diagnostics" is 1.
	# the least significant bit (LSB) specifies the boot method. 0 means "local" and 1 means "Internet".
	# so "01" would set the boot mode to "Internet Recovery" and "10" would boot local diagnostics.
	bootMode=
	
	# to set the MSB (as explained above) we ask the users if the
	# Mac should be started in recovery or diagnostics mode and
	# then set the MSB accordingly.
	buttonPressed=$(displayDialog "Would you like to restart your Mac in recovery or diagnostics mode?" "Cancel,Diagnostics,Recovery" "" "" "60")

	if [[ "$buttonPressed" = "Recovery" ]]; then
		bootMode="0"
	elif [[ "$buttonPressed" = "Diagnostics" ]]; then
		bootMode="1"
	fi
	
	# we go ahead, if the user did not click "cancel" in the previous dialog ...
	if [[ -n "$bootMode" ]]; then
	
		# ... and ask the user if the Mac should be booted from the local
		# disk or from Internet. So we can set our LSB now.
		buttonPressed=$(displayDialog "Would you like to boot from your Mac's local disk or from the Internet?" "Cancel,Internet,Local" "" "" "60")

		if [[ "$buttonPressed" = "Local" ]]; then
			bootMode="${bootMode}0"
		elif [[ "$buttonPressed" = "Internet" ]]; then
			bootMode="${bootMode}1"
		fi

		# we convert our binary number into an integer and 
		# select the actual argument for the nvram command
		bootArg=
		case "$((2#$bootMode))" in
		
			0)
				bootArg="RecoveryModeDisk"
				;;
			1)
				bootArg="RecoveryModeNetwork"
				;;
			2)
				bootArg="DiagsModeDisk"
				;;
			3)
				bootArg="DiagsModeNetwork"
				;;
		esac
		
		if [[ -n "$bootArg" ]]; then

			# we ask the user to restart the Mac
			buttonPressed=$(displayDialog "Please click \"Restart\" to restart your Mac." "Cancel,Restart" "" "" "60")
	
			if [[ "$buttonPressed" = "Restart" ]]; then
			
				# the user clicked the "Restart" button so we use 
				# the nvram tool to set the boot options ...
				log "Setting boot mode to \"$bootArg\""
				/usr/sbin/nvram "internet-recovery-mode=$bootArg"
				
				# if the user want to boot into recovery mode, we have to
				# make sure the user has admin rights
				if [[ "$bootArg" =~ ^Recovery ]]; then

					isNotAdmin=$(/usr/bin/dsmemberutil checkmembership -U "$currentUser" -G admin | /usr/bin/grep -i "is not")

					if [[ -n "$isNotAdmin" ]]; then
						/usr/sbin/dseditgroup -o edit -a "$currentUser" -t user admin
					fi
					
					# make sure the Recovery environment is aware the user
					# has admin rights, by updating the preboot volume
					/usr/sbin/diskutil apfs updatepreboot / >/dev/null 2>&1
				fi
				
				# ... and restart the machine a few seconds after 
				# this script exited
				(/bin/sleep 5 && /sbin/shutdown -r now) &
			fi
		fi
	fi

else
	log "ERROR! You must be root in order to run this script!"
	exitCode=1
fi

exit $exitCode