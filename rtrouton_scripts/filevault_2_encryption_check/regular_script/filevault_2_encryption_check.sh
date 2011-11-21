#!/bin/sh

# Ensure we're running 10.7 before continuing.
OS=$(/usr/bin/sw_vers -productVersion)
if [[ "$OS" =~ "10.7" ]]; then

	# Define temp file location
	CSSTATUS="/private/tmp/corestorage.txt"

	# Write output of 'diskutil cs list' to temp file, overwriting if one exists.
	diskutil cs list > $CSSTATUS
	
	# Ensure that a Logical Volume Family exists before continuing
	LOGVOLCHK=$(awk '/Logical Volume Family/' $CSSTATUS)
	if [ "$LOGVOLCHK" = "" ]; then
		echo "FileVault 2 Encryption Not Enabled"

	else
		# If a line containing "===..." begins with a pipe character, then we know
		# that we have multiple CoreStorage logical volume groups, and we must select
		# results from only the first one using regex.

		COUNTCHK=$(awk '/^\|[ \t]+=+/' $CSSTATUS)
		echo "============DEBUGGING============"	# for troubleshooting
		if [[ "$COUNTCHK" =~ "|" ]]; then
			echo "Volume Groups:      Multiple"		# for troubleshooting
			# Get values from first volume group using regex.
			CONTEXT=$(awk '/^\|[ \t]+Encryption Context/{print $4}' $CSSTATUS)
			ENCRYPTION=$(awk '/^\|[ \t]+Encryption Type/{print $4}' $CSSTATUS)
			ENCRYPTSTATUS=$(awk '/^\|[ \t]+Conversion Status/{print $4}' $CSSTATUS)
			ENCRYPTDIRECTION=$(awk '/^\|[ \t]+Conversion Direction/{print $4}' $CSSTATUS)
			CONVERTED=$(awk '/^\|[ \t]+Size (Converted)/{print $6, $7}' $CSSTATUS)
			SIZE=$(awk '/^\|[ \t]+Size (Total)/{print $6, $7}' $CSSTATUS)
			
		# If a line containing "===..." doesn't begin with a pipe character, we know we
		# have only one CoreStorage logical volume group, so no special regex is needed.
		else
			echo "Volume Groups:      Single"		# for troubleshooting
			# Get values from volume group
			CONTEXT=$(awk '/Encryption Context/{print $3}' $CSSTATUS)
			ENCRYPTION=$(awk '/Encryption Type/{print $3}' $CSSTATUS)
			ENCRYPTSTATUS=$(awk '/Conversion Status/{print $3}' $CSSTATUS)
			ENCRYPTDIRECTION=$(awk '/Conversion Direction/{print $3}' $CSSTATUS)
			CONVERTED=$(awk '/Size (Converted)/{print $5, $6}' $CSSTATUS)
			SIZE=$(awk '/Size (Total)/{print $5, $6}' $CSSTATUS)
		fi
		
		# Echo the results of above if/else for troubleshooting:
		echo "Encryption Context: $CONTEXT"			# for troubleshooting
		echo "Encryption Type:    $ENCRYPTION"		# for troubleshooting
		echo "Size Converted:     $CONVERTED"		# for troubleshooting
		echo "Total Size:         $SIZE"			# for troubleshooting
		echo "Conversion Status:  $ENCRYPTSTATUS"	# for troubleshooting
		echo "================================="	# for troubleshooting
		echo ""										# for troubleshooting

		# Check if encrypted or encrypting
		if [[ "$CONTEXT" =~ "Present" ]]; then
			if [[ "$ENCRYPTION" =~ "AES-XTS" ]]; then
				if [[ "$ENCRYPTSTATUS" =~ "Complete" ]]; then 
					echo "FileVault 2 Encryption Complete"
				elif [[ "$ENCRYPTSTATUS" =~ "Converting" ]]; then
	                if [[ "$ENCRYPTDIRECTION" =~ "Forward" ]]; then
	                    echo "FileVault 2 Encryption Proceeding. $CONVERTED of $SIZE Remaining"
                    else
	                    echo "FileVault 2 Encryption Status Unknown. Please check."
                    fi
                fi

            # Check if decrypted or decrypting
            elif [[ "$ENCRYPTION" =~ "None" ]]; then
                if [[ "$ENCRYPTDIRECTION" =~ "Backward" ]]; then
                    echo "FileVault 2 Decryption Proceeding. $CONVERTED of $SIZE Remaining"
                elif [[ "$ENCRYPTDIRECTION" =~ "none" ]]; then
                    echo "FileVault 2 Decryption Completed"
                fi
            fi
        fi  
    fi
    
    # Securely remove the temp file    
    if [ -f /private/tmp/corestorage.txt ]; then
        srm /private/tmp/corestorage.txt
    fi

else
    # Display this is OS version is not 10.7. 
    echo "FileVault 2 Encryption Not Available For This Version Of Mac OS X"
fi