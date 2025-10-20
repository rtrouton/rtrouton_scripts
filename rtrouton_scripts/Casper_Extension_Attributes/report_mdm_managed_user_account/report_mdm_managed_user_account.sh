#!/bin/zsh

# Get the GeneratedUID of the MDM-managed user account.
MDMManagedUserGUID=$(/usr/sbin/system_profiler SPConfigurationProfileDataType | grep "Managed User" | LC_ALL=C sed -E 's/.*([0-9A-F-]{36}).*/\1/')

# Use the GeneratedUID of the MDM-manager user account to get the account shortname of the MDM-managed user account.
MDMManagedUserUsername=$(/usr/bin/dscl . -search /Users GeneratedUID "$MDMManagedUserGUID" | awk '{print $1}' | head -n 1 2>/dev/null)

# If both the GeneratedUID and account shortname of the MDM-managed user account are reported,
# the Extension Attribute will report the account shortname of the MDM-managed user account.
#
# In all other scenarios, the following result will be reported:
#
# NA

if [[ -n ${MDMManagedUserGUID} ]] && [[ -n ${MDMManagedUserUsername} ]]; then
	result="${MDMManagedUserUsername}"
else
    result="NA"
fi

echo "<result>$result</result>"