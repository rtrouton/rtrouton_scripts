#!/bin/sh
# This script downloads and installs the latest Flash player for compatible Macs

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers} -lt 6 ]]; then
  echo "Adobe Flash Player is not available for Mac OS X 10.5.8 or below."
  exit 1
fi

if [[ ${osvers} -ge 6 ]]; then

  # Download the latest Adobe Flash Player software disk image
  curl http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_13_osx_pkg.dmg -L -o /tmp/install_flash_player_13_osx_pkg.dmg

  # Mount the install_flash_player_13_osx.dmg disk image in /Volumes
  hdiutil mount -quiet -nobrowse /tmp/install_flash_player_13_osx_pkg.dmg

  # Install Adobe Flash Player from the installer package inside Install Adobe Flash Player.app
  # Note: Installing Flash Player this way will not install the Adobe Flash Updater
  installer -pkg "/Volumes/Flash Player/Install Adobe Flash Player.pkg" -target "/"

  # Unmount the install_flash_player_13_osx.dmg disk image from   /Volumes
  hdiutil unmount /Volumes/Flash\ Player

  # Remove the install_flash_player_13_osx.dmg disk image from /tmp
  rm /tmp/install_flash_player_13_osx_pkg.dmg

fi
exit 0
