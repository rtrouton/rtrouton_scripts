#!/bin/sh

CORESTORAGESTATUS="/private/tmp/corestorage.txt"
ENCRYPTSTATUS="/private/tmp/encrypt_status.txt"
ENCRYPTDIRECTION="/private/tmp/encrypt_direction.txt"

# Get number of CoreStorage devices. The egrep pattern used later in the script
# uses this information to only report on the first encrypted drive, which should
# be the boot drive.

DEVICE_COUNT=`diskutil cs list | grep -E "^CoreStorage logical volume groups" | awk '{print $5}' | sed -e's/(//'`

EGREP_STRING=""
if [ "$DEVICE_COUNT" != "1" ]; then
  EGREP_STRING="^\| *"
fi

OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`
CONTEXT=`diskutil cs list | grep -E "$EGREP_STRING\Encryption Context" | sed -e's/\|//' | awk '{print $3}'`
ENCRYPTION=`diskutil cs list | grep -E "$EGREP_STRING\Encryption Type" | sed -e's/\|//' | awk '{print $3}'`
CONVERTED=`diskutil cs list | grep -E "$EGREP_STRING\Size \(Converted\)" | sed -e's/\|//' | awk '{print $5, $6}'`
SIZE=`diskutil cs list | grep -E "$EGREP_STRING\Size \(Total\)" | sed -e's/\|//' | awk '{print $5, $6}'`

# Checks to see if the OS on the Mac is 10.7 or not.
# If it is not, the following message is displayed without quotes:
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"

if [ "$OS" != "10.7" ]; then
  echo '<result>'FileVault 2 Encryption Not Available For This Version Of Mac OS X'</result>'
fi



if [ "$OS" = "10.7" ]; then
  diskutil cs list >> $CORESTORAGESTATUS
  
    # If the Mac is running 10.7, but not does not have
    # any CoreStorage volumes, the following message is 
    # displayed without quotes:
    # "FileVault 2 Encryption Not Enabled"
    
    if grep -iE 'No CoreStorage' $CORESTORAGESTATUS; then
       echo '<result>'FileVault 2 Encryption Not Enabled'</result>'
    fi
    
    # If the Mac is running 10.7 and has CoreStorage volumes,
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


    if grep -iE 'Logical Volume Family' $CORESTORAGESTATUS; then
      if [ "$CONTEXT" = "Present" ]; then
        if [ "$ENCRYPTION" = "AES-XTS" ]; then
	      diskutil cs list | grep -E "$EGREP_STRING\Conversion Status" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTSTATUS
		    if grep -iE 'Complete' $ENCRYPTSTATUS; then 
		      echo '<result>'FileVault 2 Encryption Complete'</result>'
            else
		      if  grep -iE 'Converting' $ENCRYPTSTATUS; then
		        diskutil cs list | grep -E "$EGREP_STRING\Conversion Direction" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
		          if grep -iE 'forward' $ENCRYPTDIRECTION; then
		            echo '<result>'FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Remaining'</result>'
                  else
		            echo '<result>'FileVault 2 Encryption Status Unknown. Please check.'</result>'
	              fi
               fi
             fi
        else
            if [ "$ENCRYPTION" = "None" ]; then
              diskutil cs list | grep -E "$EGREP_STRING\Conversion Direction" | sed -e's/\|//' | awk '{print $3}' >> $ENCRYPTDIRECTION
                if grep -iE 'backward' $ENCRYPTDIRECTION; then
                  echo '<result>'FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Remaining'</result>'
                elif grep -iE '-none-' $ENCRYPTDIRECTION; then
                  echo '<result>'FileVault 2 Decryption Completed'</result>'
                fi
            fi 
        fi
      fi  
fi
fi
# Remove the temp files created during the script

if [ -f /private/tmp/corestorage.txt ]; then
   rm /private/tmp/corestorage.txt
fi

if [ -f /private/tmp/encrypt_status.txt ]; then
   rm /private/tmp/encrypt_status.txt
fi

if [ -f /private/tmp/encrypt_direction.txt ]; then
   rm /private/tmp/encrypt_direction.txt
fi