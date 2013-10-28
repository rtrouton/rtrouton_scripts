#!/bin/sh
# Script by rtrouton
# Cleanup by Arjen van Bochoven (oct 2013)

# Get major OS version (uses uname -r and bash substitution)
# osvers is 10 for 10.6, 11 for 10.7, 12 for 10.8, etc.
osversionlong=$(uname -r)
osvers=${osversionlong/.*/}

# Checks to see if the OS on the Mac is >= 10.7
# If it is not, the following message is displayed without quotes:
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"
if [[ ${osvers} -lt 11 ]]; then
  echo "FileVault 2 Encryption Not Available For This Version Of Mac OS X"
  exit 0
fi

CORESTORAGESTATUS="/private/tmp/corestorage.txt"
ENCRYPTSTATUS="/private/tmp/encrypt_status.txt"
ENCRYPTDIRECTION="/private/tmp/encrypt_direction.txt"

# Get number of CoreStorage devices. The egrep pattern used later in the script
# uses this information to only report on the first encrypted drive, which should
# be the boot drive.
#
# Credit to Mike Osterman for identifying this problem in the original version of
# the script and finding a fix for it.
#

# Store the output of diskutil cs list in a temporary file
diskutil cs list >> $CORESTORAGESTATUS

DEVICE_COUNT=`grep -E "^CoreStorage logical volume groups" $CORESTORAGESTATUS| awk '{print $5}' | sed -e's/(//'`

EGREP_STRING=""
if [ "$DEVICE_COUNT" != "1" ]; then
  EGREP_STRING="^\| *"
fi


CONTEXT=`grep -E "$EGREP_STRING\Encryption Context" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}'`
ENCRYPTIONEXTENTS=`grep -E "$EGREP_STRING\Has Encrypted Extents" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $4}'`
ENCRYPTION=`grep -E "$EGREP_STRING\Encryption Type" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}'`
CONVERTED=`grep -E "$EGREP_STRING\Size \(Converted\)" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $5, $6}'`
SIZE=`grep -E "$EGREP_STRING\Size \(Total\)" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $5, $6}'`


  
# If the Mac does not have
# any CoreStorage volumes, the following message is 
# displayed without quotes:
# "FileVault 2 Encryption Not Enabled"

if grep -iq 'No CoreStorage' $CORESTORAGESTATUS; then
  echo "FileVault 2 Encryption Not Enabled"
fi
    
# If the Mac has CoreStorage volumes,
# the script then checks to see if the machine is encrypted,
# encrypting, or decrypting.
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
#

# This section does 10.7-specific checking of the Mac's
# FileVault 2 status
if grep -iq 'Logical Volume Family' $CORESTORAGESTATUS; then
  if [ "$CONTEXT" = "Present" ]; then
    if [ "$ENCRYPTION" = "AES-XTS" ]; then
      grep -E "$EGREP_STRING\Conversion Status" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTSTATUS
	    if grep -iq 'Complete' $ENCRYPTSTATUS; then 
	      echo "FileVault 2 Encryption Complete"
      elif  grep -iq 'Converting' $ENCRYPTSTATUS; then
        grep -E "$EGREP_STRING\Conversion Direction" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
        if grep -iq 'Forward' $ENCRYPTDIRECTION; then
          echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
        else
          echo "FileVault 2 Encryption Status Unknown. Please check."
        fi
      fi
    elif [ "$ENCRYPTION" = "None" ]; then
      grep -E "$EGREP_STRING\Conversion Direction" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
      if grep -iq 'Backward' $ENCRYPTDIRECTION; then
        echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
      elif grep -iq '-none-' $ENCRYPTDIRECTION; then
        echo "FileVault 2 Decryption Completed"
      fi
    fi
  fi  
fi

# This section does 10.9-specific checking of the Mac's
# FileVault 2 status
if [[ ${osvers} -ge 13 ]]; then
  CONVERTED=`grep -E "\Conversion \Progress" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}'`
fi

# This section does 10.8-10.9 specific checking of the Mac's
# FileVault 2 status
if [ "$ENCRYPTIONEXTENTS" = "Yes" ]; then
  grep -E "$EGREP_STRING\Fully Secure" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTSTATUS
  if grep -iq 'Yes' $ENCRYPTSTATUS; then 
    echo "FileVault 2 Encryption Complete"
  elif  grep -iq 'No' $ENCRYPTSTATUS; then
    grep -E "$EGREP_STRING\Conversion Direction" $CORESTORAGESTATUS | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
    if grep -iq 'forward' $ENCRYPTDIRECTION; then
       echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
    else
      if grep -iq 'backward' $ENCRYPTDIRECTION; then
        echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
      elif grep -iq '-none-' $ENCRYPTDIRECTION; then
        echo "FileVault 2 Decryption Completed"
      fi
    fi
  fi  
fi

if [ "$ENCRYPTIONEXTENTS" = "No" ]; then
    echo "FileVault 2 Encryption Not Enabled"
fi

# Remove the temp files created during the script
rm -f $CORESTORAGESTATUS $ENCRYPTSTATUS $ENCRYPTDIRECTION
