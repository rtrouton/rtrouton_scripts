#!/bin/bash

# This script is designed to disable Touch ID authentication for sudo on macOS 14.x
# and later. It does this by checking for and removing the following file:
#
# /etc/pam.d/sudo_local

os_version=$(sw_vers --productVersion)
os_version_check=$(echo "$os_version" | awk -F. '{print $1}')
touch_id_auth_file="/etc/pam.d/sudo_local"

# Set exit status

exitCode=0

# Verify that Mac is running macOS 14.x or later

if [[ "$os_version_check" -ge 14 ]]; then

   if [[ -f "$touch_id_auth_file" ]]; then
      /bin/rm "$touch_id_auth_file"
   fi

else

  # If Mac is running macOS 13.x or earlier, display a message that this script cannot be used
  # on this Mac to disable Touch ID authorization for sudo. 

  echo "This Mac is running $os_version. This script is not able to disable Touch ID authorization for sudo on this macOS version."
  exitCode=1
fi

exit "$exitCode"