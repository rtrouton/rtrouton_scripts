#!/bin/bash

diskutilInfo=$("/usr/sbin/diskutil" info /)
workingDir="/private/tmp/filevault_2_encryption_check"
ENCRYPTSTATUS="$workingDir/encrypt_status.txt"
ENCRYPTDIRECTION="$workingDir/encrypt_direction.txt"

osvers_major=$(sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(sw_vers -productVersion | awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ ${osvers_major} -ne 10 ]]; then
  fvCheck="Unknown Version Of Mac OS X"

# Checks to see if the OS on the Mac is 10.7 or higher.
# If it is not, the following message is displayed without quotes:
#
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"

elif [[ ${osvers_minor} -lt 7 ]]; then
  fvCheck="FileVault 2 Encryption Not Available For This Version Of Mac OS X"

else
  # If the Mac meets all the above OS requirements, runs a file system
  # personality check to determine the method of checking disk encryption
  # status (differs for APFS and CoreStorage)
  #
  # If the Mac is running 10.7 or higher, but the boot volume
  # is not a CoreStorage volume, the following message is
  # displayed without quotes:
  #
  # "FileVault 2 Encryption Not Enabled"
  fileSystemPersonality=$(echo "$diskutilInfo" | awk -F: '/File System Personality/ {print $NF}' | sed 's/^ *//')
  if [[ ${osvers_minor} -lt 13 ]] || [[ "$fileSystemPersonality" =~ "Journaled HFS+" ]]; then
    if [[ $("/usr/sbin/diskutil" coreStorage info / 2>&1) =~ "is not a CoreStorage disk" ]]; then
      fvCheck="FileVault 2 Encryption Not Enabled"
    else
      diskType="CoreStorage"
    fi
  elif [[ "$fileSystemPersonality" =~ "APFS" ]]; then
    diskType="APFS"
  else
    diskType="Classic"
    fvCheck="Unrecognized File System Personality"
  fi
fi

# Run FileVault status checks per disk format type and operating system build.

if [[ "$diskType" = "APFS" ]]; then
  # If the boot volume is an APFS volume, the script then runs fdesetup to
  # determine encryption status.
  fdesetupStatus=$("/usr/bin/fdesetup" status)
  if [[ $(echo "$fdesetupStatus" | head -1) = "FileVault is On." ]]; then
    if [[ "$fdesetupStatus" =~ "Decryption in progress" ]]; then
      progressPercent=$(echo "$fdesetupStatus" | awk '/Decryption/ {print $NF}')
      fvCheck="FileVault 2 Decryption Proceeding, $progressPercent% Decrypted"
    elif [[ "$fdesetupStatus" =~ "Encryption in progress" ]]; then
      progressPercent=$(echo "$fdesetupStatus" | awk '/Encryption/ {print $NF}')
      fvCheck="FileVault 2 Encryption Proceeding, $progressPercent% Encrypted"
    else
      fvCheck="FileVault 2 Encryption Complete"
    fi
  else
    fvCheck="FileVault 2 Encryption Not Enabled"
  fi

elif [[ "$diskType" = "CoreStorage" ]]; then

  # If the boot volume is a CoreStorage volume,
  # the script then checks to see if the machine is
  # encrypted, encrypting, or decrypting.
  #
  # If encrypted, the following message is
  # displayed without quotes:
  # "FileVault 2 Encryption Complete"
  #
  # If encrypting, the following message is
  # displayed without quotes:
  # "FileVault 2 Encryption Proceeding."
  # How much has been encrypted of of the total
  # amount of space is also displayed. If the
  # amount of encryption is for some reason not
  # known, the following message is
  # displayed without quotes:
  # "FileVault 2 Encryption Status Unknown. Please check."
  #
  # If decrypting, the following message is
  # displayed without quotes:
  # "FileVault 2 Decryption Proceeding"
  # How much has been decrypted of of the total
  # amount of space is also displayed
  #
  # If fully decrypted, the following message is
  # displayed without quotes:
  # "FileVault 2 Decryption Complete"

  # Create working directory for temp files

  if [[ ! -d "$workingDir" ]]; then
    mkdir -p "$workingDir"
  fi

  # Get the Logical Volume UUID (aka "UUID" in diskutil cs info)
  # for the boot drive's CoreStorage volume.

  LV_UUID=`diskutil cs info / | awk '/UUID/ {print $2;exit}'`

  # Get the Logical Volume Family UUID (aka "Parent LVF UUID" in diskutil cs info)
  # for the boot drive's CoreStorage volume.

  LV_FAMILY_UUID=`diskutil cs info / | awk '/Parent LVF UUID/ {print $4;exit}'`

  CONTEXT=`diskutil cs list $LV_FAMILY_UUID | awk '/Encryption Context/ {print $3;exit}'`

  if [[ ${osvers_minor} -eq 7 || ${osvers_minor} -eq 8 ]]; then
    CONVERTED=`diskutil cs list $LV_UUID | awk '/Size \(Converted\)/ {print $5,$6;exit}'`
  fi

  if [[ ${osvers_minor} -ge 9 ]]; then
    CONVERTED=`diskutil cs list $LV_UUID | awk '/Conversion Progress/ {print $3;exit}'`
  fi

  ENCRYPTIONEXTENTS=`diskutil cs list $LV_FAMILY_UUID | awk '/Has Encrypted Extents/ {print $4;exit}'`
  ENCRYPTION=`diskutil cs list $LV_FAMILY_UUID | awk '/Encryption Type/ {print $3;exit}'`
  SIZE=`diskutil cs list $LV_UUID | awk '/Size \(Total\)/ {print $5,$6;exit}'`

  # This section does 10.7-specific checking of the Mac's
  # FileVault 2 status

  if [[ ${osvers_minor} -eq 7 ]]; then
    if [ "$CONTEXT" = "Present" ]; then
      if [ "$ENCRYPTION" = "AES-XTS" ]; then
        diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Status/ {print $3;exit}' >> $ENCRYPTSTATUS
        if grep -iE 'Complete' $ENCRYPTSTATUS 1>/dev/null; then
          fvCheck="FileVault 2 Encryption Complete"
        else
          if  grep -iE 'Converting' $ENCRYPTSTATUS 1>/dev/null; then
            diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
            if grep -iE 'Forward' $ENCRYPTDIRECTION 1>/dev/null; then
              fvCheck="FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
            else
              fvCheck="FileVault 2 Encryption Status Unknown. Please check"
            fi
          fi
        fi
      else
        if [ "$ENCRYPTION" = "None" ]; then
          diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
          if grep -iE 'Backward' $ENCRYPTDIRECTION 1>/dev/null; then
            fvCheck="FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
          elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
            fvCheck="FileVault 2 Decryption Completed"
          fi
        fi
      fi
    fi

  # This section does checking of the Mac's FileVault 2 status
  # on 10.8.x through 10.10.x

  elif [[ ${osvers_minor} -ge 8 ]] && [[ ${osvers_minor} -lt 11 ]]; then
    if [[ "$ENCRYPTIONEXTENTS" = "No" ]]; then
      fvCheck="FileVault 2 Encryption Not Enabled"
    elif [[ "$ENCRYPTIONEXTENTS" = "Yes" ]]; then
      diskutil cs list $LV_FAMILY_UUID | awk '/Fully Secure/ {print $3;exit}' >> $ENCRYPTSTATUS
	    if grep -iE 'Yes' $ENCRYPTSTATUS 1>/dev/null; then
	      fvCheck="FileVault 2 Encryption Complete"
      else
	      if  grep -iE 'No' $ENCRYPTSTATUS 1>/dev/null; then
          diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
          if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
            fvCheck="FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
          else
	          if grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
              fvCheck="FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
            elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
              fvCheck="FileVault 2 Decryption Completed"
            fi
          fi
	      fi
	    fi
    fi

  # This section does checking of the Mac's FileVault 2 status
  # on 10.11.x and higher

  elif [[ ${osvers_minor} -ge 11 ]]; then
    if [[ "$ENCRYPTION" = "None" ]] && [[ $(diskutil cs list "$LV_UUID" | awk '/Conversion Progress/ {print $3;exit}') == "" ]]; then
      fvCheck="FileVault 2 Encryption Not Enabled"
    elif [[ "$ENCRYPTION" = "None" ]] && [[ $(diskutil cs list "$LV_UUID" | awk '/Conversion Progress/ {print $3;exit}') == "Complete" ]]; then
      fvCheck="FileVault 2 Decryption Completed"
    elif [[ "$ENCRYPTION" = "AES-XTS" ]]; then
      diskutil cs list $LV_FAMILY_UUID | awk '/High Level Queries/ {print $4,$5;exit}' >> $ENCRYPTSTATUS
	    if grep -iE 'Fully Secure' $ENCRYPTSTATUS 1>/dev/null; then
	      fvCheck="FileVault 2 Encryption Complete"
      else
	      if grep -iE 'Not Fully' $ENCRYPTSTATUS 1>/dev/null; then
	        if [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $4;exit}') != "" ]]; then
	          diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Status/ {print $4;exit}' >> $ENCRYPTDIRECTION
            if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
              fvCheck="FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
            elif grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
              fvCheck="FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
            fi
	        elif [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $4;exit}') == "" ]]; then
	          if [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $3;exit}') == "Complete" ]]; then
              fvCheck="FileVault 2 Decryption Completed"
	          fi
	        fi
	      fi
      fi
    fi
  fi
fi

# Remove the temp files created during the script

if [[ -d "$workingDir" ]]; then
   rm -r "$workingDir"
fi

# Report result

echo "<result>$fvCheck</result>"

exit 0
