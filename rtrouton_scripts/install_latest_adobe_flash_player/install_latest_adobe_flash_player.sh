#!/bin/sh

# This script downloads and installs the latest Flash player for compatible Macs

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers} -lt 6 ]]; then
  echo "Adobe Flash Player is not available for Mac OS X 10.5.8 or below."
fi

if [[ ${osvers} -ge 6 ]]; then
 
	# Change working directory to /tmp

	/usr/bin/cd /tmp

	# Download the latest Adobe Flash Player software disk image

	/usr/bin/curl -O http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_13_osx_pkg.dmg

	# Mount the install_flash_player_13_osx.dmg disk image in /Volumes

	/usr/bin/hdiutil attach install_flash_player_13_osx_pkg.dmg -nobrowse -noverify -noautoopen

	# Install Adobe Flash Player from the installer package inside Install Adobe Flash Player.app
	# Note: Installing Flash Player this way will not install the Adobe Flash Updater

	/usr/sbin/installer -dumplog -verbose -pkg "/Volumes/Flash Player/Install Adobe Flash Player.pkg" -target "/"

	# Clean-up
 
	# Unmount the install_flash_player_11_osx.dmg disk image from /Volumes

	/usr/bin/hdiutil eject -force /Volumes/Flash\ Player

	# Remove the install_flash_player_11_osx.dmg disk image from /tmp

	/bin/rm -rf /tmp/install_flash_player_13_osx_pkg.dmg

fi

exit 0
