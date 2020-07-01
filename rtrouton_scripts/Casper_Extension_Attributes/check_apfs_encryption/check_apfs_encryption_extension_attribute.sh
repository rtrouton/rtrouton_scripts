#!/bin/bash

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

ERROR=0

# Checks to see if the OS on the Mac is 10.13 or higher.
# If it is not, the following message is displayed without quotes:
#
# "APFS Encryption Not Available For This Version Of macOS"

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 13 ) ]]; then
  echo "<result>APFS Encryption Not Available For This Version Of macOS</result>"
fi

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 13 ) || ${osvers_major} -ge 11 ]]; then

# If the OS on the Mac is 10.13 or higher, check to see if the
# boot drive is formatted with APFS or HFS+

boot_filesystem_check=$(/usr/sbin/diskutil info / | awk '/Type \(Bundle\)/ {print $3}')
  
# If the drive is formatted with APFS, the fdesetup tool will
# be available and is able to display the encryption status.

  if [[ "$boot_filesystem_check" = "apfs" ]]; then

    # If encrypted, the following message is 
    # displayed without quotes:
    # "FileVault is On."
    #
    # If encrypting, the following message is 
    # displayed without quotes:
    # "Encryption in progress:"
    # How much has been encrypted of of the total
    # amount of space is also displayed.
    #
    # If decrypting, the following message is 
    # displayed without quotes:
    # "Decryption in progress:"
    # How much has been decrypted of of the total
    # amount of space is also displayed
    #
    # If not encrypted, the following message is 
    # displayed without quotes:
    # "FileVault is Off."

     ENCRYPTSTATUS=$(fdesetup status | xargs)
     if [[ -z $(echo "$ENCRYPTSTATUS" | awk '/Encryption | Decryption/') ]]; then
       ENCRYPTSTATUS=$(fdesetup status | head -1)
       echo "<result>$ENCRYPTSTATUS</result>"
     else
       ENCRYPTSTATUS=$(fdesetup status | tail -1)
       echo "<result>$ENCRYPTSTATUS</result>"
     fi
    else
      echo "<result>Unable to display encryption status for filesystems other than APFS.</result>"
  fi
fi
  
exit $ERROR
