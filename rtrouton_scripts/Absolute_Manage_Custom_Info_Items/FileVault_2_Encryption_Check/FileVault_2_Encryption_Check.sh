#!/bin/bash

CORESTORAGESTATUS="/private/tmp/corestorage.txt"
ENCRYPTSTATUS="/private/tmp/encrypt_status.txt"
ENCRYPTDIRECTION="/private/tmp/encrypt_direction.txt"

osvers_major=$(sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(sw_vers -productVersion | awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ ${osvers_major} -ne 10 ]]; then
  echo "Unknown Version Of Mac OS X"
fi

# Checks to see if the OS on the Mac is 10.7 or higher.
# If it is not, the following message is displayed without quotes:
#
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 7 ]]; then
  echo "FileVault 2 Encryption Not Available For This Version Of Mac OS X"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 7 ]]; then
  diskutil cs info / >> $CORESTORAGESTATUS 2>&1
  
    # If the Mac is running 10.7 or higher, but the boot volume
    # is not a CoreStorage volume, the following message is 
    # displayed without quotes:
    #
    # "FileVault 2 Encryption Not Enabled"
    
    if grep -iE '/ is not a CoreStorage disk' $CORESTORAGESTATUS 1>/dev/null; then
       echo "FileVault 2 Encryption Not Enabled"
       rm -f "$CORESTORAGESTATUS"
       exit 0
    fi
    
    # If the Mac is running 10.7 or higher and the boot volume
    # is a CoreStorage volume, the script then checks to see if 
    # the machine is encrypted, encrypting, or decrypting.
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

    # Get the Logical Volume UUID (aka "UUID" in diskutil cs info)
    # for the boot drive's CoreStorage volume.
    
    LV_UUID=`diskutil cs info / | awk '/UUID/ {print $2;exit}'`
    
    # Get the Logical Volume Family UUID (aka "Parent LVF UUID" in diskutil cs info)
    # for the boot drive's CoreStorage volume.
    
    LV_FAMILY_UUID=`diskutil cs info / | awk '/Parent LVF UUID/ {print $4;exit}'`
    
    CONTEXT=`diskutil cs list $LV_FAMILY_UUID | awk '/Encryption Context/ {print $3;exit}'`
    
    if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 7 || ${osvers_minor} -eq 8 ]]; then
        CONVERTED=`diskutil cs list $LV_UUID | awk '/Size \(Converted\)/ {print $5,$6;exit}'`
    fi
    
    if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 9 ]]; then
        CONVERTED=`diskutil cs list $LV_UUID | awk '/Conversion Progress/ {print $3;exit}'`    
    fi
    
    ENCRYPTIONEXTENTS=`diskutil cs list $LV_FAMILY_UUID | awk '/Has Encrypted Extents/ {print $4;exit}'`
    ENCRYPTION=`diskutil cs list $LV_FAMILY_UUID | awk '/Encryption Type/ {print $3;exit}'`
    SIZE=`diskutil cs list $LV_UUID | awk '/Size \(Total\)/ {print $5,$6;exit}'`

    # This section does 10.7-specific checking of the Mac's
    # FileVault 2 status

   if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 7 ]]; then
      if [ "$CONTEXT" = "Present" ]; then
        if [ "$ENCRYPTION" = "AES-XTS" ]; then
          diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Status/ {print $3;exit}' >> $ENCRYPTSTATUS
		    if grep -iE 'Complete' $ENCRYPTSTATUS 1>/dev/null; then 
		      echo "FileVault 2 Encryption Complete"
            else
		      if  grep -iE 'Converting' $ENCRYPTSTATUS 1>/dev/null; then
		        diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
		          if grep -iE 'Forward' $ENCRYPTDIRECTION 1>/dev/null; then
		            echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
                  else
		            echo "FileVault 2 Encryption Status Unknown. Please check."
	              fi
               fi
             fi
        else
            if [ "$ENCRYPTION" = "None" ]; then
              diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
                if grep -iE 'Backward' $ENCRYPTDIRECTION 1>/dev/null; then
                  echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
                elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
                  echo "FileVault 2 Decryption Completed"
                fi
            fi 
        fi
      fi  
    fi
   fi



    # This section does checking of the Mac's FileVault 2 status
    # on 10.8.x through 10.10.x
    
    if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 8 ]] && [[ ${osvers_minor} -lt 11 ]]; then
      if [[ "$ENCRYPTIONEXTENTS" = "No" ]]; then
		      echo "FileVault 2 Encryption Not Enabled"
      elif [[ "$ENCRYPTIONEXTENTS" = "Yes" ]]; then
	      diskutil cs list $LV_FAMILY_UUID | awk '/Fully Secure/ {print $3;exit}' >> $ENCRYPTSTATUS
		    if grep -iE 'Yes' $ENCRYPTSTATUS 1>/dev/null; then 
		      echo "FileVault 2 Encryption Complete"
            else
		      if  grep -iE 'No' $ENCRYPTSTATUS 1>/dev/null; then
		        diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
		          if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
		            echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
                  else
		            if grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
                  	    echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
		            elif grep -iE 'none' $ENCRYPTDIRECTION 1>/dev/null; then
                  	    echo "FileVault 2 Decryption Completed"
	                fi
                  fi
		      fi
		    fi  
      fi
    fi

    # This section does checking of the Mac's FileVault 2 status
    # on 10.11.x and higher
    
    if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 11 ]]; then
      if [[ "$ENCRYPTION" = "None" ]] && [[ $(diskutil cs list "$LV_UUID" | awk '/Conversion Progress/ {print $3;exit}') == "" ]]; then
	      echo "FileVault 2 Encryption Not Enabled"
      elif [[ "$ENCRYPTION" = "None" ]] && [[ $(diskutil cs list "$LV_UUID" | awk '/Conversion Progress/ {print $3;exit}') == "Complete" ]]; then
	      echo "FileVault 2 Decryption Completed"
      elif [[ "$ENCRYPTION" = "AES-XTS" ]]; then
	      diskutil cs list $LV_FAMILY_UUID | awk '/High Level Queries/ {print $4,$5;exit}' >> $ENCRYPTSTATUS
		    if grep -iE 'Fully Secure' $ENCRYPTSTATUS 1>/dev/null; then 
		      echo "FileVault 2 Encryption Complete"
            else
		      if grep -iE 'Not Fully' $ENCRYPTSTATUS 1>/dev/null; then
		        if [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $4;exit}') != "" ]]; then 
		          diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Status/ {print $4;exit}' >> $ENCRYPTDIRECTION
		            if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
		              echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
		            elif grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
		              echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
		            fi
		        elif [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $4;exit}') == "" ]]; then
		          if [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $3;exit}') == "Complete" ]]; then
		              echo "FileVault 2 Decryption Completed"
		          fi
		        fi
		      fi
      fi  
    fi
fi

# Remove the temp files created during the script

if [ -f "$CORESTORAGESTATUS" ]; then
   rm -f "$CORESTORAGESTATUS"
fi

if [ -f "$ENCRYPTSTATUS" ]; then
   rm -f "$ENCRYPTSTATUS"
fi

if [ -f "$ENCRYPTDIRECTION" ]; then
   rm -f "$ENCRYPTDIRECTION"
fi

exit 0