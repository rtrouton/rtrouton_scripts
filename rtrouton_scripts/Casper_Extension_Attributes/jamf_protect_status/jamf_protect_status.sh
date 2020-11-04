#!/bin/bash

# Jamf Pro Extension Attribute which checks and validates the following:
#
# 1. Jamf Protect is installed
# 2. The Jamf Protect processes are running.
#
# If Jamf Protect is installed and running properly:
#
# /Library/Application Support/JamfProtect/JamfProtect.app will be executable.
# Running the following command will return one or more results:
#
# pgrep JamfProtect
#
# If Jamf Protect is installed and the processes are running, 
# the following message is displayed:
#
# 1
#
# Otherwise, the following result is returned:
#
# 0

JamfProtectInstallPath="/Library/Application Support/JamfProtect/JamfProtect.app"
isRunning=0

# If the Jamf Protect app is detected and executable,
# next check for the Jamf Protect processes.

if [[ -x "$JamfProtectInstallPath" ]]; then

	# check for Jamf Protect process
	JPProcess=$( pgrep JamfProtect )

	if [[ -n "$JPProcess" ]]; then
		isRunning=1
	fi
fi

echo "<result>$isRunning</result>"

exit 0
