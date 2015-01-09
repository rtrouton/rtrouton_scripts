#!/bin/sh
# Orginal script by rtrouton
# Modified by Doug Campbell (Nov 2014)

cleanup()
{
  # Remove the temp files created during the script
  rm -f $CSLIST $LVINFO $LVFINFO
}

# temporary files
CSLIST="/private/tmp/corestorage.txt"
LVINFO="/private/tmp/lvinfo.txt"
LVFINFO="/private/tmp/lvfinfo.txt"
 
# Get major OS vresion (uses uname -r and bash substituion)
# osvers is 10 for 10.6, 11 for 10.7, 12 for 10.8, etc.
osversionlong=$(uname -r)
osvers=${osversionlong/.*/}

# Checks to see if the OS on the Mac is >= 10.7
if [[ ${osvers} -lt 11 ]]; then
  echo "FileVault 2 Encryption Not Available for this Version of Mac OS X"
  exit 0
fi

# Store the output of diskutil cs list in a temporary file
diskutil cs list > $CSLIST

# find out disk identifier mounted as / filesystem
DISK_ID=$(df / | tail -1 | awk '{print $1}' | awk -F "/" '{print $3}')

# get list of all logical volumes in core storage
LOGICAL_VOLUMES=$(grep -v "Family" $CSLIST | grep -v "Group" | grep "Logical Volume" | awk '{print $NF}')

# find logical volume that matches the disk mount as / filesystem, if any
for lv in $LOGICAL_VOLUMES; do
  # get device identifier for logical volume, if it exists
  DEVICE_ID=$(diskutil cs info $lv | grep "Device Identifier" | awk '{print $3}')
  if [ "$DEVICE_ID" == "$DISK_ID" ]; then
    LV=$lv
    break
  fi
done

if [[ -z $LV ]]; then
  echo "FileVault 2 Encryption Not Enabled."
  cleanup
  exit 0
fi

# get Logical Volume Family UUID
LVF=$(diskutil cs info $LV | grep "Parent LVF UUID:" | awk '{print $4}')

# get logical volume info
diskutil cs list $LV > $LVINFO

# get logical volume family info
diskutil cs list $LVF > $LVFINFO

CONTEXT=$(grep -E "Encryption Context" $LVFINFO | awk '{print $3}')
ENCRYPTIONEXTENTS=$(grep -E "Has Encrypted Extents" $LVFINFO | awk '{print $4}')
ENCRYPTION=$(grep -E "Encryption Type" $LVFINFO | awk '{print $3}')
if [[ ${osvers} -lt 13 ]]; then
  CONVERTED=$(grep -E "Size \(Converted\)" $LVINFO | awk '{print $5, $6}')
else
  CONVERTED=$(grep -E "Conversion Progress" $LVINFO | awk '{print $3}')
fi
SIZE=$(grep -E "Size \(Total\)" $LVINFO | awk '{print $5, $6}')

# for OS X 10.7
if [[ ${osvers} -eq 11 ]]; then
  # check either that CONTEXT is "Present" for OS X 10.7 or ENCRYPTIONEXTENTS is "Yes" for OS X 10.8 and above
  if [ "$CONTEXT" = "Present" ]; then
    if [ "$ENCRYPTION" = "AES-XTS" ]; then
      CONVERSION_STATUS=$(grep -E "Conversion Status" $LVFINFO | awk '{print $3}' | tr [:upper:] [:lower:])
      if [ "$CONVERSION_STATUS" = "complete" ]; then
        echo "FileVault 2 Encryption Complete"
      else
        if [ "$CONVERSION_STATUS" = "converting" ]; then
          ENCRYPTION_DIRECTION=$(grep -E "Conversion Direction" $LVFINFO | awk '{print $3}' | tr [:upper:] [:lower:])
          if [ "$ENCRYPTION_DIRECTION" = "forward" ]; then
            echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
          else
            echo "FileVault 2 Encryption Status Unknown. Please check."
          fi
        fi
      fi
    else
      if [ "$ENCRYPTION" = "None" ]; then
        ENCRYPTION_DIRECTION=$(grep -E "Conversion Direction" $LVFINFO | awk '{print $3}' | tr [:upper:] [:lower:])  
        if [ "$ENCRYPTION_DIRECTION" = "backward" ]; then
          echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
        elif [ "$ENCRYPTION_DIRECTION" = "-none-" ]; then
          echo "FileVault 2 Decryption Completed"
        fi
      fi
    fi
  fi
fi

# for OS X 10.8 and above
if [[ ${osvers} -ge 12 ]]; then
  if [ "$ENCRYPTIONEXTENTS" = "Yes" ]; then
    ENCRYPTSTATUS=$(grep -E "Fully Secure" $LVFINFO | awk '{print $3}' | tr [:upper:] [:lower:])
    if [ "$ENCRYPTSTATUS" = "yes" ]; then
      echo "FileVault 2 Encryption Complete"
    else
      if [ "$ENCRYPTSTATUS" = "no" ]; then
        ENCRYPTION_DIRECTION=$(grep -E "Conversion Direction" $LVFINFO | awk '{print $3}' | tr [:upper:] [:lower:])
        if [ "$ENCRYPTION_DIRECTION" = "forward" ]; then
          echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Encrypted"
        elif [ "$ENCRYPTION_DIRECTION" = "backward" ]; then
          echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Decrypted"
        elif [ "$ENCRYPTION_DIRECTION" = "-none-" ]; then
          echo "FileVault 2 Decryption Completed"
        fi
      fi
    fi
  fi
fi

cleanup
exit 0