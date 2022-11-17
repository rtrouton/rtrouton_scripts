#!/bin/bash

# This script checks Apple's IPSW feed to get the appropriate IPSW file
# for the current release of macOS used by the VirtualMac2,1 virtualization
# Mac model.

clear

exitCode=0
Apple_macOS_IPSW_Download_Directory=$(mktemp -d)
Apple_macOS_IPSW_Feed="https://mesu.apple.com/assets/macos/com_apple_macOSIPSW/com_apple_macOSIPSW.xml"
Apple_macOS_IPSW_XML=$(/usr/bin/curl -s "$Apple_macOS_IPSW_Feed" | xmllint --format -)
Apple_macOS_IPSW_Download_URL=$(/usr/libexec/PlistBuddy -c 'print ":MobileDeviceSoftwareVersionsByVersion:1:MobileDeviceSoftwareVersions:VirtualMac2,1"' /dev/stdin <<< "$Apple_macOS_IPSW_XML" | awk '/FirmwareURL/ {print $3}')
Apple_macOS_IPSW_Filename=$(echo "$Apple_macOS_IPSW_Download_URL" | awk -F / '{print $NF}')

# Verify that the IPSW download URL contains a filename which ends in .ipsw

if [[ -n $(echo "$Apple_macOS_IPSW_Download_URL" | grep -o ".ipsw") ]]; then

   # If the IPSW download URL contains a filename which ends in .ipsw,
   # download the IPSW file and store it in a temp directory.

   echo "Downloading $Apple_macOS_IPSW_Filename ..."
   echo "From: $Apple_macOS_IPSW_Download_URL"
   echo "To: $Apple_macOS_IPSW_Download_Directory/$Apple_macOS_IPSW_Filename"
   echo ""

   /usr/bin/curl -L "$Apple_macOS_IPSW_Download_URL" -o "$Apple_macOS_IPSW_Download_Directory"/"$Apple_macOS_IPSW_Filename" && download_success=1

   # If the download succeeds, display a message notifying the user that the
   # download has completed and where the IPSW file is stored.
   #
   # If the download fails, display a message notifying the user that the download failed
   # and exit with an error.

   if [[ -n "$download_success" ]] && [[ -f "$Apple_macOS_IPSW_Download_Directory"/"$Apple_macOS_IPSW_Filename" ]]; then
      echo ""
      echo "$Apple_macOS_IPSW_Filename has been downloaded to the following location:"
      echo "$Apple_macOS_IPSW_Download_Directory/$Apple_macOS_IPSW_Filename"
   else
      echo "Download of $Apple_macOS_IPSW_Filename from $Apple_macOS_IPSW_Download_URL has failed. Exiting."
      exitCode=1
   fi
else

   # If the IPSW download URL does not contain a filename which ends in .ipsw,
   # display a message notifying the user that an IPSW file was not found and
   # exit with an error.

   echo "Unable to detect macOS IPSW file to download. Exiting."
   exitCode=1
fi

exit "$exitCode"