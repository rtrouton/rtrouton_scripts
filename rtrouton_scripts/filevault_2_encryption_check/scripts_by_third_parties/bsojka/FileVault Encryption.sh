#!/bin/bash

# Original author:        Rich Trouton
# Refactoring and update: Bartlomiej Sojka

CORESTORAGESTATUS="/private/tmp/corestorage.txt"
ENCRYPTSTATUS="/private/tmp/encrypt_status.txt"
ENCRYPTDIRECTION="/private/tmp/encrypt_direction.txt"

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

osvers_major=$(sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(sw_vers -productVersion | awk -F. '{print $2}')

# Checks if the OS on the Mac is 10.x:
if [[ ${osvers_major} -ne 10 ]]; then
	echo "<result>macOS 11 and later not supported.</result>"
	exit 0
else
	# Checks if the OS on the Mac is 10.7 or higher:
	if [[ ${osvers_minor} -lt 7 ]]; then
		echo "<result>Not available</result>"
		exit 0
	else
		# If the Mac is running 10.7 or higher and the boot volume is a CoreStorage or APFS volume,
		# the script then checks to see if the machine is encrypted, encrypting, or decrypting.
		# 
		# If encrypted, the following message is displayed without quotes:
		# "Enabled"
		#
		# If encrypting, the following message is displayed without quotes:
		# "In progress"
		# How much has been encrypted of the total amount of space is also displayed.
		#
		# If the amount of encryption is for some reason not known, the following message is displayed without quotes:
		# "Status unknown - Please verify"
		#
		# If decrypting, the following message is displayed without quotes:
		# "Decrypting"
		# How much has been decrypted of the total amount of space is also displayed.
		#
		# If fully decrypted, the following message is displayed without quotes:
		# "Disabled"

		DUINFO=$(diskutil info /)
		FILESYSTEM=$(echo "$DUINFO" | awk '/Type \(Bundle\)/ {print $3;exit}')

		if [[ "$FILESYSTEM" = "hfs" ]]; then
			diskutil cs info / >> $CORESTORAGESTATUS 2>&1

			# Checks if the boot volume is not a CoreStorage volume on a Mac running 10.7 or higher:
			if grep -iE '/ is not a CoreStorage disk' $CORESTORAGESTATUS 1>/dev/null; then
				echo "<result>Not enabled</result>"
				rm -f "$CORESTORAGESTATUS"
				exit 0
			fi

			# Get the Logical Volume UUID (aka "UUID" in diskutil cs info) for the boot drive's CoreStorage volume.
			LV_UUID=$(diskutil cs info / | awk '/UUID/ {print $2;exit}')

			# Get the Logical Volume Family UUID (aka "Parent LVF UUID" in diskutil cs info) for the boot drive's CoreStorage volume.
			LV_FAMILY_UUID=$(diskutil cs info / | awk '/Parent LVF UUID/ {print $4;exit}')

			if [[ ${osvers_minor} -eq 7 || ${osvers_minor} -eq 8 ]]; then
				CONVERTED=$(diskutil cs list $LV_UUID | awk '/Size \(Converted\)/ {print $5,$6;exit}')
			fi

			if [[ ${osvers_minor} -ge 9 ]]; then
				CONVERTED=$(diskutil cs list $LV_UUID | awk '/Conversion Progress/ {print $3;exit}')
			fi

			ENCRYPTIONEXTENTS=$(diskutil cs list $LV_FAMILY_UUID | awk '/Has Encrypted Extents/ {print $4;exit}')
			ENCRYPTION=$(diskutil cs list $LV_FAMILY_UUID | awk '/Encryption Type/ {print $3;exit}')
			SIZE=$(diskutil cs list $LV_UUID | awk '/Size \(Total\)/ {print $5,$6;exit}' | cut -d '(' -f 2 | cut -d ')' -f 1)
		elif [[ "$FILESYSTEM" = "apfs" ]];then
			# Get the UUID for the boot drive's APFS volume.
			LV_UUID=$(echo "$DUINFO" | awk '/\/ Partition UUID/ {print $5;exit}')

			# Get the APFS Container ID for the boot drive's APFS volume.
			CONTAINER_ID=$(echo "$DUINFO" | awk '/Part of Whole/ {print $4;exit}')

			APFSINFO=$(diskutil ap list $CONTAINER_ID)
			APVOLINFO=$(echo "$APFSINFO" | grep -A7 $LV_UUID)

			ENCRYPTION=$(echo "$APVOLINFO" | awk '/Encrypted/ {print $3;exit}')
			CONVERTED=$(echo "$APVOLINFO" | awk '/cryption Progress/ {print $4;exit}')
			SIZE=$(echo "$APFSINFO" | awk '/Capacity Ceiling/ {print $6,$7;exit}' | cut -d '(' -f 2 | cut -d ')' -f 1)
		else
			echo "<result>Unrecognised file system</result>"
			exit 0
		fi
	fi

	# FileVault 2 status on 10.7.x:

	if [[ ${osvers_minor} -eq 7 ]]; then
		CONTEXT=$(diskutil cs list $LV_FAMILY_UUID | awk '/Encryption Context/ {print $3;exit}')
		if [ "$CONTEXT" = "Present" ]; then
			if [ "$ENCRYPTION" = "AES-XTS" ]; then
				diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Status/ {print $3;exit}' >> $ENCRYPTSTATUS
				if grep -iE 'Complete' $ENCRYPTSTATUS 1>/dev/null; then
					echo "<result>Enabled</result>"
				elif  grep -iE 'Converting' $ENCRYPTSTATUS 1>/dev/null; then
					diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
					if grep -iE 'Forward' $ENCRYPTDIRECTION 1>/dev/null; then
						echo "<result>In progress - $CONVERTED of $SIZE encrypted</result>"
					else
						echo "<result>Status unknown - Please verify</result>"
					fi
				fi
			elif [ "$ENCRYPTION" = "None" ]; then
				diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
				if grep -iE 'Backward' $ENCRYPTDIRECTION 1>/dev/null; then
					echo "<result>Decrypting - $CONVERTED of $SIZE decrypted</result>"
				elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
					echo "<result>Disabled</result>"
				fi
			fi
		fi
	fi
		
	# FileVault 2 status on 10.8.x through 10.10.x:

	if [[ ${osvers_minor} -ge 8 ]] && [[ ${osvers_minor} -lt 11 ]]; then
		if [[ "$ENCRYPTIONEXTENTS" = "No" ]]; then
			echo "<result>Not enabled</result>"
		elif [[ "$ENCRYPTIONEXTENTS" = "Yes" ]]; then
			diskutil cs list $LV_FAMILY_UUID | awk '/Fully Secure/ {print $3;exit}' >> $ENCRYPTSTATUS
			if grep -iE 'Yes' $ENCRYPTSTATUS 1>/dev/null; then
				echo "<result>Enabled</result>"
			elif grep -iE 'No' $ENCRYPTSTATUS 1>/dev/null; then
				diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Direction/ {print $3;exit}' >> $ENCRYPTDIRECTION
				if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
					echo "<result>In progress - $CONVERTED of $SIZE encrypted</result>"
				elif grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
					echo "<result>Decrypting - $CONVERTED of $SIZE decrypted</result>"
				elif grep -iE '-none-' $ENCRYPTDIRECTION 1>/dev/null; then
					echo "<result>Disabled</result>"
				fi
			fi
		fi
	fi

	# FileVault 2 status on 10.11.x and higher:

	if [[ ${osvers_minor} -ge 11 ]]; then
		if [[ "$FILESYSTEM" != "apfs" ]]; then
			# HFS:
			if [[ "$ENCRYPTION" = "None" ]] && [[ $(diskutil cs list "$LV_UUID" | awk '/Conversion Progress/ {print $3;exit}') == "" ]]; then
				echo "<result>Not enabled</result>"
			elif [[ "$ENCRYPTION" = "None" ]] && [[ $(diskutil cs list "$LV_UUID" | awk '/Conversion Progress/ {print $3;exit}') == "Complete" ]]; then
				echo "<result>Disabled</result>"
			elif [[ "$ENCRYPTION" = "AES-XTS" ]]; then
				diskutil cs list $LV_FAMILY_UUID | awk '/High Level Queries/ {print $4,$5;exit}' >> $ENCRYPTSTATUS
				if grep -iE 'Fully Secure' $ENCRYPTSTATUS 1>/dev/null; then
					echo "<result>Enabled</result>"
				elif grep -iE 'Not Fully' $ENCRYPTSTATUS 1>/dev/null; then
					if [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $4;exit}') != "" ]]; then
						diskutil cs list $LV_FAMILY_UUID | awk '/Conversion Status/ {print $4;exit}' >> $ENCRYPTDIRECTION
						if grep -iE 'forward' $ENCRYPTDIRECTION 1>/dev/null; then
							if [[ "$CONVERTED" = "Converting" ]] || [[ "$CONVERTED" = "Optimizing" ]]; then
								echo "<result>In progress - Optimizing</result>"
							else
								echo "<result>In progress - $CONVERTED of $SIZE encrypted</result>"
							fi
						elif grep -iE 'backward' $ENCRYPTDIRECTION 1>/dev/null; then
							echo "<result>Decrypting - $CONVERTED of $SIZE decrypted</result>"
						fi
					elif [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $4;exit}') == "" ]]; then
						if [[ $(diskutil cs list "$LV_FAMILY_UUID" | awk '/Conversion Status/ {print $3;exit}') == "Complete" ]]; then
							echo "<result>Disabled</result>"
						else
							echo "<result>In progress - Paused</result>"
						fi
					fi
				fi
			fi
		else
			# APFS:
			if [[ "$ENCRYPTION" = "No" ]]; then
				echo "<result>Not enabled</result>"
			elif [[ "$ENCRYPTION" = "Yes" ]]; then
				echo "<result>Enabled</result>"
			else
				if grep -iE 'Encryption Progress' <<< $APVOLINFO 1>/dev/null; then
					if grep -iE 'Paused' <<< $APVOLINFO 1>/dev/null; then
						echo "<result>In progress - Paused</result>"
					else
						echo "<result>In progress - $CONVERTED of $SIZE encrypted</result>"
					fi
				elif grep -iE 'Decryption Progress' <<< $APVOLINFO 1>/dev/null; then
					if grep -iE 'Paused' <<< $APVOLINFO 1>/dev/null; then
						echo "<result>Decrypting - Paused</result>"
					else
						echo "<result>Decrypting - $CONVERTED of $SIZE decrypted</result>"
					fi
				else
					echo "<result>Status unknown - Please verify</result>"
				fi
			fi
		fi
	fi
fi

# Cleanup:

[ -f "$CORESTORAGESTATUS" ] && rm -f "$CORESTORAGESTATUS"
[ -f "$ENCRYPTSTATUS" ] && rm -f "$ENCRYPTSTATUS"
[ -f "$ENCRYPTDIRECTION" ] && rm -f "$ENCRYPTDIRECTION"

exit 0