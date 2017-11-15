#!/bin/bash

CORESTORAGE_STATUS_FILE="/private/tmp/corestorage.txt"
ENCRYPT_STATUS_FILE="/private/tmp/encrypt_status.txt"
ENCRYPT_DIRECTION_FILE="/private/tmp/encrypt_direction.txt"

osversMajor="$(sw_vers -productVersion | awk -F. '{print $1}')"
osversMinor="$(sw_vers -productVersion | awk -F. '{print $2}')"

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ "${osversMajor}" -ne 10 ]]; then
	echo "<result>Unknown Version Of Mac OS X</result>"
	exit 0
fi

# Checks to see if the OS on the Mac is 10.7 or higher.
# If it is not, the following message is displayed without quotes:
#
# "FileVault 2 Encryption Not Available For This Version Of Mac OS X"

if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -lt 7 ]]; then
	echo "<result>FileVault 2 Encryption Not Available For This Version Of Mac OS X</result>"
	exit 0
fi

if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -ge 7 ]]; then
	diskutil cs info / >> "${CORESTORAGE_STATUS_FILE}" 2>&1
	
	# If the Mac is running 10.7 or higher, but the boot volume
	# is not a CoreStorage volume, the following message is
	# displayed without quotes:
	#
	# "FileVault 2 Encryption Not Enabled"
	
	if grep -iE '/ is not a CoreStorage disk' "${CORESTORAGE_STATUS_FILE}" 1>/dev/null; then
		echo "<result>FileVault 2 Encryption Not Enabled</result>"
		rm -f "${CORESTORAGE_STATUS_FILE}"
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
	
	lvUUID="$(diskutil cs info / | awk '/UUID/ {print $2;exit}')"
	
	# Get the Logical Volume Family UUID (aka "Parent LVF UUID" in diskutil cs info)
	# for the boot drive's CoreStorage volume.
	
	lvFamilyUUID="$(diskutil cs info / | awk '/Parent LVF UUID/ {print $4;exit}')"
	
	encContext="$(diskutil cs list "${lvFamilyUUID}" | awk '/Encryption Context/ {print $3;exit}')"
	
	if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -eq 7 || "${osversMinor}" -eq 8 ]]; then
		convertedProgress="$(diskutil cs list "${lvUUID}" | awk '/Size \(Converted\)/ {print $5,$6;exit}')"
	fi
	
	if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -ge 9 ]]; then
		convertedProgress="$(diskutil cs list "${lvUUID}" | awk '/Conversion Progress/ {print $3;exit}')"
	fi
	
	encryptionExtents="$(diskutil cs list "${lvFamilyUUID}" | awk '/Has Encrypted Extents/ {print $4;exit}')"
	encryptionType="$(diskutil cs list "${lvFamilyUUID}" | awk '/Encryption Type/ {print $3;exit}')"
	encryptionSize="$(diskutil cs list "${lvUUID}" | awk '/Size \(Total\)/ {print $5,$6;exit}')"
fi

# This section does 10.7-specific checking of the Mac's
# FileVault 2 status

if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -eq 7 ]]; then
	if [ "${encContext}" = "Present" ]; then
		if [ "${encryptionType}" = "AES-XTS" ]; then
			diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Status/ {print $3;exit}' >> "${ENCRYPT_STATUS_FILE}"
			if grep -iE 'Complete' "${ENCRYPT_STATUS_FILE}" 1>/dev/null; then
				echo "<result>FileVault 2 Encryption Complete</result>"
			else
				if grep -iE 'Converting' "${ENCRYPT_STATUS_FILE}" 1>/dev/null; then
					diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Direction/ {print $3;exit}' >> "${ENCRYPT_DIRECTION_FILE}"
					if grep -iE 'Forward' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
						echo "<result>FileVault 2 Encryption Proceeding. ${convertedProgress} of ${encryptionSize} Encrypted</result>"
					else
						echo "<result>FileVault 2 Encryption Status Unknown. Please check.</result>"
					fi
				fi
			fi
		else
			if [ "${encryptionType}" = "None" ]; then
				diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Direction/ {print $3;exit}' >> "${ENCRYPT_DIRECTION_FILE}"
				if grep -iE 'Backward' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
					echo "<result>FileVault 2 Decryption Proceeding. ${convertedProgress} of ${encryptionSize} Decrypted</result>"
				elif grep -iE '-none-' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
					echo "<result>FileVault 2 Decryption Completed</result>"
				fi
			fi
		fi
	fi
fi

# This section does checking of the Mac's FileVault 2 status
# on 10.8.x through 10.10.x

if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -ge 8 ]] && [[ "${osversMinor}" -lt 11 ]]; then
	if [[ "${encryptionExtents}" = "No" ]]; then
		echo "<result>FileVault 2 Encryption Not Enabled</result>"
	elif [[ "${encryptionExtents}" = "Yes" ]]; then
		diskutil cs list "${lvFamilyUUID}" | awk '/Fully Secure/ {print $3;exit}' >> "${ENCRYPT_STATUS_FILE}"
		if grep -iE 'Yes' "${ENCRYPT_STATUS_FILE}" 1>/dev/null; then
			echo "<result>FileVault 2 Encryption Complete</result>"
		else
			if grep -iE 'No' "${ENCRYPT_STATUS_FILE}" 1>/dev/null; then
				diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Direction/ {print $3;exit}' >> "${ENCRYPT_DIRECTION_FILE}"
				if grep -iE 'forward' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
					echo "<result>FileVault 2 Encryption Proceeding. ${convertedProgress} of ${encryptionSize} Encrypted</result>"
				else
					if grep -iE 'backward' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
						echo "<result>FileVault 2 Decryption Proceeding. ${convertedProgress} of ${encryptionSize} Decrypted</result>"
					elif grep -iE '-none-' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
						echo "<result>FileVault 2 Decryption Completed</result>"
					fi
				fi
			fi
		fi
	fi
fi

# This section does checking of the Mac's FileVault 2 status
# on 10.11.x and higher

if [[ "${osversMajor}" -eq 10 ]] && [[ "${osversMinor}" -ge 11 ]]; then
	if [[ "${encryptionType}" = "None" ]] && [[ $(diskutil cs list "${lvUUID}" | awk '/Conversion Progress/ {print $3;exit}') == "" ]]; then
		echo "<result>FileVault 2 Encryption Not Enabled</result>"
	elif [[ "${encryptionType}" = "None" ]] && [[ $(diskutil cs list "${lvUUID}" | awk '/Conversion Progress/ {print $3;exit}') == "Complete" ]]; then
		echo "<result>FileVault 2 Decryption Completed</result>"
	elif [[ "${encryptionType}" = "AES-XTS" ]]; then
		diskutil cs list "${lvFamilyUUID}" | awk '/High Level Queries/ {print $4,$5;exit}' >> "${ENCRYPT_STATUS_FILE}"
		if grep -iE 'Fully Secure' "${ENCRYPT_STATUS_FILE}" 1>/dev/null; then
			echo "<result>FileVault 2 Encryption Complete</result>"
		else
			if grep -iE 'Not Fully' "${ENCRYPT_STATUS_FILE}" 1>/dev/null; then
				if [[ $(diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Status/ {print $4;exit}') != "" ]]; then
					diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Status/ {print $4;exit}' >> "${ENCRYPT_DIRECTION_FILE}"
					if grep -iE 'forward' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
						echo "<result>FileVault 2 Encryption Proceeding. ${convertedProgress} of ${encryptionSize} Encrypted</result>"
					elif grep -iE 'backward' "${ENCRYPT_DIRECTION_FILE}" 1>/dev/null; then
						echo "<result>FileVault 2 Decryption Proceeding. ${convertedProgress} of ${encryptionSize} Decrypted</result>"
					fi
				elif [[ $(diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Status/ {print $4;exit}') == "" ]]; then
					if [[ $(diskutil cs list "${lvFamilyUUID}" | awk '/Conversion Status/ {print $3;exit}') == "Complete" ]]; then
						echo "<result>FileVault 2 Decryption Completed</result>"
					fi
				fi
			fi
		fi
	fi
fi

# Remove the temp files created during the script

if [ -f "${CORESTORAGE_STATUS_FILE}" ]; then
	rm -f "${CORESTORAGE_STATUS_FILE}"
fi

if [ -f "${ENCRYPT_STATUS_FILE}" ]; then
	rm -f "${ENCRYPT_STATUS_FILE}"
fi

if [ -f "${ENCRYPT_DIRECTION_FILE}" ]; then
	rm -f "${ENCRYPT_DIRECTION_FILE}"
fi

exit 0