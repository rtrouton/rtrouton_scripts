#!/bin/bash

# This script is designed to block login access
# to the root account on macOS. It does this using
# the following actions:
#
# 1. Sets the root account's password to a random 32
#    character long password using the openssl command.
# 2. Sets the root account's login shell to /usr/bin/false
# 3. Disables the root account, since setting the account
#    password enables the root account.

ERROR=0

# Set root password to randomized 32 character long password

rootpassword=$(openssl rand -base64 32)

/usr/bin/dscl . -passwd /Users/root "$rootpassword"

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

# Disable the root account, since setting the password enables the root account.

/usr/sbin/dsenableroot -d -u root -p "$rootpassword"

exit "$ERROR"