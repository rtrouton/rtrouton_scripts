#!/bin/bash

ERROR=0

# Set root password to randomized 32 character long password

/usr/bin/dscl . -passwd /Users/root "$(env LC_CTYPE=C tr -dc 'A-Za-z0-9_\ \!\@\#\$\%\^\&\*\(\)-+=' < /dev/urandom | head -c 32)"

# Disable root login by setting root's shell to /usr/bin/false.
# The original UserShell value is as follows:
#
# /bin/sh
#
# To revert it back to /bin/sh, run the following command:
# /usr/bin/dscl . -change /Users/root UserShell /usr/bin/false /bin/sh

rootshell=$(/usr/bin/dscl . -read /Users/root UserShell | awk '{print $2}')

if [[ -z "$rootshell" ]]; then

   # If root shell is blank or otherwise not set,
   # use dscl to set /usr/bin/false as the shell.

   echo "Setting blank root shell to /usr/bin/false"
   /usr/bin/dscl . -create /Users/root UserShell /usr/bin/false
else

   # If root shell is set to an existing value, use dscl
   # to change the shell from the existing value and set
   # /usr/bin/false as the shell.

   echo "Changing root shell from $rootshell to /usr/bin/false"
   /usr/bin/dscl . -change /Users/root UserShell "$rootshell" /usr/bin/false
fi

exit "$ERROR"
