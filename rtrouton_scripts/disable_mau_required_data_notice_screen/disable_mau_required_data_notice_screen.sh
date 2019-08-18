#!/bin/bash

# This script is designed to suppress the Microsoft AutoUpdate Required Data Notice screen
# The script runs the following actions:
# 
# 1. Identifies all users on the Mac with a UID greater than 500
# 2. Identifies the home folder location of all users identified
#    in the previous step.
# 3. Sets the com.microsoft.autoupdate2.plist file with the following
#    key and value. This will suppress Microsoft AutoUpdate's 
#    Required Data Notice screen and stop it from appearing.
#
#    Key: AcknowledgedDataCollectionPolicy
#    Value: RequiredDataOnly


# Identify all users on the Mac with a UID greater than 500

allLocalUsers=$(/usr/bin/dscl . -list /Users UniqueID | awk '$2>500 {print $1}')

for userName in ${allLocalUsers}; do

	  # Identify the home folder location of all users with a UID greater than 500.

	  userHome=$(/usr/bin/dscl . -read "/Users/$userName" NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g')
	  
	  # Verify that home folder actually exists.
	  
	  if [[ -d  "$userHome" ]]; then

 	    # If the home folder exists, sets the com.microsoft.autoupdate2.plist file with the needed key and value.

 	    /usr/bin/defaults write "${userHome}/Library/Preferences/com.microsoft.autoupdate2.plist" AcknowledgedDataCollectionPolicy RequiredDataOnly

 	    # This script is designed to be run with root privileges, so the ownership of the com.microsoft.autoupdate2.plist file
 	    # and the enclosing directories are re-set to that of the account which owns the home folder. 

 	    /usr/sbin/chown "$userName" "${userHome}/Library/"
 	    /usr/sbin/chown "$userName" "${userHome}/Library/Preferences"
 	    /usr/sbin/chown "$userName" "${userHome}/Library/Preferences/com.microsoft.autoupdate2.plist"
      
	  fi

done
