#!/bin/bash

# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# If the Mac is running 10.8.5 or earlier, the
# script will return the following output:
# "Mac is not running 10.9. Not affected by this issue."

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 9 ) ]]; then
  echo "Mac is not running 10.9. Not affected by this issue."
else

# If the Mac is running 10.9.0 or later, the
# script will return the following output if
# the BypassPreLoginCheck returns a value of 1:
# "Fix has already been applied"
#
# All other results will cause the following command
# to be run to set the bypass:
# 
# defaults write /Library/Preferences/com.apple.mdmclient BypassPreLoginCheck -bool YES

	mdmbypass=`defaults read /Library/Preferences/com.apple.mdmclient BypassPreLoginCheck`
	if [[ "$mdmbypass" = 1 ]]; then
          echo "Fix has already been applied."
   	elif [[ "$mdmbypass" != 1 ]]; then
          defaults write /Library/Preferences/com.apple.mdmclient BypassPreLoginCheck -bool YES
   	fi
fi

exit 0
