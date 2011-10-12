#!/bin/sh

CWD=`pwd`

CONTEXT=`diskutil cs list | grep -E "Encryption Context" | awk '{print $3}'`
ENCRYPTION=`diskutil cs list | grep -E "Encryption Type" | awk '{print $3}'`
CONVERTED=`diskutil cs list | grep "Size (Converted)" | awk '{print $5, $6}'`
SIZE=`diskutil cs list | grep "Size (Total)" | awk '{print $5, $6}'`

diskutil cs list >> $CWD/corestorage.txt
 if grep -iE 'Logical Volume Family' $CWD/corestorage.txt; then
  if [ "$CONTEXT" = "Present" ]; then
   if [ "$ENCRYPTION" = "AES-XTS" ]; then
	diskutil cs list | grep -E "Conversion Status" | awk '{print $3}' >> $CWD/encrypt_status.txt
		if grep -iE 'Complete' $CWD/encrypt_status.txt; then 
		  echo "FileVault 2 Encryption Complete"
		else
		  if  grep -iE 'Converting' $CWD/encrypt_status.txt; then
		   diskutil cs list | grep -E "Conversion Direction" | awk '{print $3}' >> $CWD/encrypt_direction.txt
		    if grep -iE 'Forward' $CWD/encrypt_direction.txt; then
		        echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Remaining"
		   else
		        echo "FileVault 2 Encryption Status Unknown. Please check."
	            fi
                   fi
	          fi
   else
    if [ "$ENCRYPTION" = "None" ]; then
      if grep -iE 'Reverse' $CWD/encrypt_direction.txt; then
      echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Remaining"
      fi
    fi 
   fi
  fi
else 
  if grep -iE 'No CoreStorage' $CWD/corestorage.txt; then
   echo "FileVault 2 Encryption Not Enabled"
  fi
fi
rm $CWD/encrypt_direction.txt
rm $CWD/encrypt_status.txt
rm $CWD/corestorage.txt
