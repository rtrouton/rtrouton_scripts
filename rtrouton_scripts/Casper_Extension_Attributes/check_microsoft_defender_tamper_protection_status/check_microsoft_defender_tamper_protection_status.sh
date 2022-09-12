#!/bin/bash

# Check to see if Microsoft Defender's tamper protection is enabled.
# This Jamf Pro Extension Attribute will return one of four statuses
#
# 000 = The /usr/local/bin/mdatp command-line tool cannot be found or is not executable.
# 001 = Tamper protection is fully disabled.
# 010 = Tamper protection is set to audit mode.
# 100 = Tamper protection is fully enabled.

mdatpPath="/usr/local/bin/mdatp"

# Set default result for the Extension Attribute to be the following:
#
# 000 = The /usr/local/bin/mdatp command-line tool cannot be found or is not executable.

eaResult="000"

# Verify that the following tool is installed and executable:
#
# /usr/local/bin/mdatp

if [[ -x "$mdatpPath" ]]; then
		
		# If the mdatp tool is installed, Defender's tamper protection
		# status is checked by running the following command:
		#
		# /usr/local/bin/mdatp" health --field tamper_protection
		#
		# There are three possible keywords that can be returned by this command:
		#
		# disabled - tamper protection is completely off.
		# audit - tampering operations are logged, but not blocked.
		# block - tamper protection is on, tampering operations are blocked.
		
		tamper_protection_enabled="$("$mdatpPath" health --field tamper_protection | awk -F'"' '{print $2}')"
	
		if [[ "$tamper_protection_enabled" = "disabled" ]]; then
			eaResult="001"
		elif [[ "$tamper_protection_enabled" = "audit" ]]; then
			eaResult="010"
		elif [[ "$tamper_protection_enabled" = "block" ]]; then
			eaResult="100"
		fi	 
fi

echo "<result>$eaResult</result>"

exit 0