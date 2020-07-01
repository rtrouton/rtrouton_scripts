#!/bin/sh

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Get current date
FILE_DATE=`date +%Y%m%d`


# If the Mac is running 10.5.8 or lower, the script should exit

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 6 ) ]]; then
   exit 0
fi

# If the Mac is running 10.6.0 or higher, the script should should run

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 6 ) ]]; then
   
   # Check for the /Users/username/Library/Preferences/com.apple.sidebarlists.plist file

   if [ -f /Users/username/Library/Preferences/com.apple.sidebarlists.plist ]; then
      
      # Back up the existing file
      
      /bin/cp /Users/username/Library/Preferences/com.apple.sidebarlists.plist /Users/username/Library/Preferences/com.apple.sidebarlists-$FILE_DATE.plist

      # Fix permissions on backup file

      /usr/sbin/chown username /Users/username/Library/Preferences/com.apple.sidebarlists-$FILE_DATE.plist
      
      # Convert plist to XML

      /usr/bin/plutil -convert xml1 /Users/username/Library/Preferences/com.apple.sidebarlists.plist

      # Search and replace in /Users/username/Library/Preferences/com.apple.sidebarlists.plist
      
      /usr/bin/sed -i "" -e 's/smb:\/\/oldservername\/oldsharename/smb:\/\/newservername\/newsharename/g' /Users/username/Library/Preferences/com.apple.sidebarlists.plist

      # Fix permissions on file
      
      /usr/sbin/chown username /Users/username/Library/Preferences/com.apple.sidebarlists.plist

   fi
fi

exit 0
