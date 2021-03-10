#!/bin/bash

# Jamf Pro Extension Attribute which checks to see if Jamf Protect's protectctl
# tool is installed. If protectctl tool is installed, check for Jamf Protect
# tenant name.
#
# If Jamf Protect's protectctl tool is installed:
#
# Output similar to that shown below will be returned:
#
# jamf_protect_server_name_here.protect
#
# Otherwise, the following result is returned:
#
# NA

if [[ -x /usr/local/bin/protectctl ]]; then
  JAMF_PROTECT_SERVER=$(protectctl info | awk '/Tenant/ {print $2}')
  echo "<result>$JAMF_PROTECT_SERVER</result>"
else
  echo "<result>NA</result>"
fi

exit 0
