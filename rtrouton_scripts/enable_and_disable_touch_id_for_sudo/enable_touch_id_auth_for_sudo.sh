#!/bin/bash

# This script is designed to enable Touch ID authentication for sudo on macOS Sonoma 
# 14.x and later. It does this by copying the following file, which is a template file
# which contains the correct command:
#
# /etc/pam.d/sudo_local.template
#
# To the following location:
#
# /etc/pam.d/sudo_local
#
# If there is already a /etc/pam.d/sudo_local file, the existing file is backed up
# and named similarly to what is shown below:
#
# /etc/pam.d/sudo_local_1696683022.bak

# Set exit status

exitCode=0

os_version=$(sw_vers --productVersion)
os_version_check=$(echo "$os_version" | awk -F. '{print $1}')
touch_id_template_file="/etc/pam.d/sudo_local.template"
touch_id_auth_file="/etc/pam.d/sudo_local"

# Verify that Mac is running macOS 14.x or later

if [[ "$os_version_check" -ge 14 ]]; then

# Check to see if the file which normally contains Touch ID authorization for sudo exists.
# If it exists, back up the existing file and rename it to preserve the contents prior to
# installing a new copy of the template.

  if [[ -f "$touch_id_auth_file" ]]; then

   # Back up the existing file and rename it to something similar
   # to what is shown below:
   #
   # /etc/pam.d/sudo_local_1696683022.bak

     /bin/mv "$touch_id_auth_file" "$touch_id_auth_file"_$(date "+%s").bak

  fi


  # Verify that the /etc/pam.d/sudo_local file doesn't exist. If the file does not exist, enable Touch ID
  # authorization for sudo by making a copy of the template file and edit it to remove the comment mark
  # from the line granting Touch ID authorization for sudo.

  if [[ ! -f "$touch_id_auth_file" ]]; then

     /bin/cp "$touch_id_template_file" "$touch_id_auth_file"
     sed -i '' -e 's,#auth       sufficient     pam_tid.so,auth       sufficient     pam_tid.so,g' "$touch_id_auth_file"
     /usr/sbin/chown root:wheel "$touch_id_auth_file"
     /bin/chmod 555 "$touch_id_auth_file"
  else

   # If the /etc/pam.d/sudo_local file does exist, display an error which indicates
   # that the /etc/pam.d/sudo_local exists. This means that an existing copy of the 
   # /etc/pam.d/sudo_local file was found and it wasn't renamed like it should have 
   # been.

     echo "ERROR: Failed to enable Touch ID authorization for sudo."
     echo "PROBLEM: $touch_id_auth_file exists. New $touch_id_auth_file was not able to be created from $touch_id_template_file template file."
     exitCode="1"
 
  fi
else

  # If Mac is running macOS 13.x or earlier, display a message that this script cannot be used
  # on this Mac to enable Touch ID authorization for sudo. 

  echo "This Mac is running $os_version. This script is not able to enable Touch ID authorization for sudo on this macOS version."
  exitCode=1
fi

exit "$exitCode"
