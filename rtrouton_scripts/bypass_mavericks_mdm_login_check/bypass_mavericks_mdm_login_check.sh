#!/bin/bash

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# If the Mac is running 10.8.5 or earlier, the
# script will return the following output:
# "Mac is not running 10.9. Not affected by this issue."

if [[ ${osvers} -lt 9 ]]; then
  echo "Mac is not running 10.9. Not affected by this issue."
fi

# If the Mac is running 10.9.0 or later, the
# script will return the following output if
# the BypassPreLoginCheck returns a value of 1:
# "Fix has already been applied"
#
# All other results will cause the following command
# to be run to set the bypass:
# 
# defaults write /Library/Preferences/com.apple.mdmclient BypassPreLoginCheck -bool YES

if [[ ${osvers} -ge 9 ]]; then
	mdmbypass=`defaults read /Library/Preferences/com.apple.mdmclient BypassPreLoginCheck`
	if [[ "$mdmbypass" = 1 ]]; then
          echo "Fix has already been applied."
   	elif [[ "$mdmbypass" != 1 ]]; then
          defaults write /Library/Preferences/com.apple.mdmclient BypassPreLoginCheck -bool YES
   	fi
fi

exit 0
