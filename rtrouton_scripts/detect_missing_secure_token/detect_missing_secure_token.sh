#!/bin/bash

# Script which reports if the current logged-in user has a
# Secure Token attribute associated with their account.

osvers_minor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')
result=0

MissingSecureTokenCheck() {

	# Get the currently logged-in user and go ahead if not root.

	current_user=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

	# This function checks if the logged-in user has Secure Token attribute associated
	# with their account. If the token_status variable returns "0", then the following
	# status is returned from the script:
	#
	# 1
	#
	# If anything else is returned, the following status is
	# returned from the script:
	#
	# 0

	if [[ -n "$current_user" && "$current_user" != "root" ]]; then

	  # Get the Secure Token status.

		token_status=$(/usr/sbin/sysadminctl -adminUser "" -adminPassword "" -secureTokenStatus "$current_user" 2>&1 | /usr/bin/grep -ic enabled)

		# If there is no secure token associated with the logged-in account,
		# the token_status variable should return "0".

		if [[ "$token_status" -eq 0 ]]; then
			result=1
		fi
	fi

	# If unable to determine the logged-in user
	# or if the logged-in user is root, then the following
	# status is returned from the script:
	#
	# 0
}

# Check to see if the OS version of the Mac supports running APFS boot volumes.

if [[ ${osvers_minor} -ge 13 ]]; then

	# If the OS check passes, check to see if the boot volume has an APFS filesystem
	# with FileVault turned on.

	if [[ $(/usr/sbin/diskutil info / | /usr/bin/awk '/Type \(Bundle\)/ {print $3}') = "apfs" && $(/usr/bin/fdesetup status | /usr/bin/grep -io "is on") ]]; then

		# If the boot volume is using APFS for its filesystem and FileVault is on,
		# run the MissingSecureTokenCheck function.
		MissingSecureTokenCheck
	fi

	# If the OS, filesystem or encryption check did not pass, the script sets the following string for the "result" value:
	#
	# 0
fi

echo "$result"

exit 0
