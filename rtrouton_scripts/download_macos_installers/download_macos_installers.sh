#!/bin/bash

# This script uses the softwareupdate command to display all available macOS
# installers for a particular Mac and then offers the option to download a 
# selected OS installer.

available_os_installers=$(mktemp)

# Set exit status
error=0

#Check for available macOS installers

/usr/sbin/softwareupdate --list-full-installers > "$available_os_installers"

clear

echo "The following macOS installers are available for this Mac:"
echo ""
cat "$available_os_installers" | tail -n +3 | awk -F ': |, |KiB' '($1 == "* Title") { print $2" "$4" Build "$9 ": "(int((($6 * 1024) / 1000000000) * 10 + 0.5) / 10) " GB" }'
echo ""
echo "Version numbers:"
grep -oE '\d+\.(\d|\.)*\d' "$available_os_installers"
echo ""
read -p  "Please enter the version number of the macOS installer you wish to download: " macos_version

# Verify that data entered contains only numbers and periods by extracting all the numbers and
# periods and seeing if there's anything left over. If there is, not a valid version number.

macos_version_check=$(echo "$macos_version" | sed 's/[0-9]//g' | tr -d '.')

# If the version check returns no data, a version number containing only numbers and periods was entered.

if [[ -z "$macos_version_check" ]]; then
   echo "Downloading installer..."
   /usr/sbin/softwareupdate --fetch-full-installer --full-installer-version ${macos_version}
else
   echo "$macos_version is not a valid version number. Exiting..."
   error=1
fi

exit $error