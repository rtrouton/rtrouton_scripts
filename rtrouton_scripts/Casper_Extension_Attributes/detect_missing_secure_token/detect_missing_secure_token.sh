#!/bin/bash

# Extension Attribute which reports if the current logged-in user has a
# Secure Token attribute associated with their account.

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

result=5

# Potential results of this extension attribute:
#
# 0 = Secure Token not enabled for the logged-in user on an encrypted APFS boot volume
# 1 = Secure Token enabled for the logged-in user on an encrypted APFS boot volume
# 2 = OS, filesystem or encryption checks returned as having one or more failed criteria
# 3 = Boot volume is not using APFS for its filesystem with FileVault is on
# 4 = Unable to determine the logged-in user or if the logged-in user is root
# 5 = Nothing changed the original "result" variable from the original value of "5" by the time the script finished its run.

MissingSecureTokenCheck() {

	# Get the currently logged-in user and go ahead if not root.

	current_user=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

	# This function checks if the logged-in user has Secure Token attribute associated
	# with their account. If the logged-in user has a Secure Token, then the following
	# status is returned from the Extension Attribute:
	#
	# 1
	#

	if [[ -n "$current_user" && "$current_user" != "root" ]]; then

	  # Get the Secure Token status.

		token_status=$(/usr/sbin/sysadminctl -adminUser "" -adminPassword "" -secureTokenStatus "$current_user" 2>&1 | /usr/bin/grep -ic enabled)

		# If there is no secure token associated with the logged-in account,
		# the token_status variable should return "0".

		if [[ "$token_status" -eq 1 ]]; then
			result=1
		elif [[ "$token_status" -eq 0 ]]; then
		    result=0
		fi

		# If unable to determine the logged-in user
		# or if the logged-in user is root, then the following
		# status is returned from the Extension Attribute:
		#
		# 4

		else result=4
	fi


}

# Check to see if the OS version of the Mac supports running APFS boot volumes.

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 13 ) || ${osvers_major} -ge 11 ]]; then

	# If the OS check passes, check to see if the boot volume has an APFS filesystem
	# with FileVault turned on.

	if [[ $(/usr/sbin/diskutil info / | /usr/bin/awk '/Type \(Bundle\)/ {print $3}') = "apfs" && $(/usr/bin/fdesetup status | /usr/bin/grep -io "is on") ]]; then

		# If the boot volume is using APFS for its filesystem and FileVault is on,
		# run the MissingSecureTokenCheck function.
		MissingSecureTokenCheck
        else
        
        # If the boot volume is not using APFS for its filesystem with FileVault is on,
        # then the following status is returned from the Extension Attribute:
		#  
		# 3
		
        result=3
	fi

	# If the OS, filesystem or encryption check did not pass, the Extension Attribute sets the following string for the "result" value:
	#
	# 2

    else 
    result=2
fi

# If nothing has changed the original "result" variable by the time the 
# script finishes its run, then the following status is returned from the Extension Attribute:
#  
# 5

echo "<result>$result</result>"

exit 0
