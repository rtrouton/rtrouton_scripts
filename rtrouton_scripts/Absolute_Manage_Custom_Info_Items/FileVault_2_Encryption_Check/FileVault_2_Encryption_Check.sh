#!/bin/sh

CORESTORAGESTATUS="/private/tmp/corestorage.txt"
ENCRYPTSTATUS="/private/tmp/encrypt_status.txt"
ENCRYPTDIRECTION="/private/tmp/encrypt_direction.txt"

OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`
CONTEXT=`diskutil cs list | grep -E "Encryption Context" | awk '{print $3}'`
ENCRYPTION=`diskutil cs list | grep -E "Encryption Type" | awk '{print $3}'`
CONVERTED=`diskutil cs list | grep "Size (Converted)" | awk '{print $5, $6}'`
SIZE=`diskutil cs list | grep "Size (Total)" | awk '{print $5, $6}'`

# Checks to see if the OS on the Mac is 10.7 or not.
# If it is not, the following message is displayed without quotes:
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"

if [ "$OS" != "10.7" ]; then
  echo "FileVault 2 Encryption Not Available For This Version Of Mac OS X"
fi



if [ "$OS" = "10.7" ]; then
  diskutil cs list >> $CORESTORAGESTATUS
  
    # If the Mac is running 10.7, but not does not have
    # any CoreStorage volumes, the following message is 
    # displayed without quotes:
    # "FileVault 2 Encryption Not Enabled"
    
    if grep -iE 'No CoreStorage' $CORESTORAGESTATUS 1>/dev/null; then
       echo "FileVault 2 Encryption Not Enabled"
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


    if grep -iE 'Logical Volume Family' $CORESTORAGESTATUS 1>/dev/null; then
      if [ "$CONTEXT" = "Present" ]; then
        if [ "$ENCRYPTION" = "AES-XTS" ]; then
	      diskutil cs list | grep -E "Conversion Status" | awk '{print $3}' >> $ENCRYPTSTATUS
		    if grep -iE 'Complete' $ENCRYPTSTATUS; then 
		      echo "FileVault 2 Encryption Complete"
            else
		      if  grep -iE 'Converting' $ENCRYPTSTATUS 1>/dev/null; then
		        diskutil cs list | grep -E "Conversion Direction" | awk '{print $3}' >> $ENCRYPTDIRECTION
		          if grep -iE 'Forward' $ENCRYPTDIRECTION 1>/dev/null; then
		            echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Remaining"
                  else
		            echo "FileVault 2 Encryption Status Unknown. Please check."
	              fi
               fi
             fi
        else
            if [ "$ENCRYPTION" = "None" ]; then
              diskutil cs list | grep -E "Conversion Direction" | awk '{print $3}' >> $ENCRYPTDIRECTION
                if grep -iE 'Backward' $ENCRYPTDIRECTION 1>/dev/null; then
                  echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Remaining"
                elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
                  echo "FileVault 2 Decryption Completed"
                fi
            fi 
        fi
      fi  
fi
fi

# Remove the temp files created during the script

if [ -f /private/tmp/corestorage.txt ]; then
   srm /private/tmp/corestorage.txt
fi

if [ -f /private/tmp/encrypt_status.txt ]; then
   srm /private/tmp/encrypt_status.txt
fi

if [ -f /private/tmp/encrypt_direction.txt ]; then
   srm /private/tmp/encrypt_direction.txt
fi