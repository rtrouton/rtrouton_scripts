#!/bin/bash

# Set exit status

exitCode=0

# Get download URL for latest UTM Guest Tools installer package

utm_guest_tools_download_url=$(/usr/bin/curl -s https://api.github.com/repos/utmapp/vd_agent/releases/latest | awk '/browser_download_url/ $2 ~ "pkg" {print $2}' | tr -d '"' | tail -1)

# Create download directory and set directory and installer variables.

utm_guest_tools_download_directory=$(mktemp -d)
utm_guest_tools_downloaded_installer="utm-guest-tools-latest.pkg"
utm_guest_tools_installer_path="$utm_guest_tools_download_directory/$utm_guest_tools_downloaded_installer"

# Download latest UTM Guest Tools installer package

/usr/bin/curl -L --silent --show-error --fail "${utm_guest_tools_download_url}" -o "${utm_guest_tools_installer_path}" 2>&1

# Verify if download was successful
download_status=$?

if [[ $download_status -eq 0 ]]; then

   # Check for downloaded installer's code signature. If code signature is valid, install the UTM Guest Tools

   signature_check=$(/usr/sbin/pkgutil --check-signature "${utm_guest_tools_installer_path}" | awk /'Developer ID Installer/{ print $5" "$6" "$7 }' | tr -d ',')

   if [[ ${signature_check} = "Turing Software LLC" ]]; then

      # If signature check was successful, install UTM Guest Tools using the downloaded installer package.
      /usr/sbin/installer -verboseR -pkg "${utm_guest_tools_installer_path}" -target "/"
    else
      echo "Signature check failed. Downloaded installer package not signed by Turing Software LLC."
      exitCode=1
   fi
else
  echo "Download failed with error code $download_status"
  exitCode=1
fi

exit "$exitCode"