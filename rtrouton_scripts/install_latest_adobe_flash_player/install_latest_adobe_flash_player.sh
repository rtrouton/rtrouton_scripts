#!/bin/sh

# This script downloads and installs the latest Flash player for compatible Macs

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Specify the complete address of the Adobe Flash Player
# disk image
 
fileURL="http://fpdownload.macromedia.com/get/flashplayer/current/licensing/mac/install_flash_player_14_osx_pkg.dmg"

# Specify name of downloaded disk image

flash_dmg="/tmp/flash.dmg"

if [[ ${osvers} -lt 6 ]]; then
  echo "Adobe Flash Player is not available for Mac OS X 10.5.8 or below."
fi

if [[ ${osvers} -ge 6 ]]; then
 
  # Download the latest Adobe Flash Player software disk image

  /usr/bin/curl --output "$flash_dmg" "$fileURL"

    # Specify a /tmp/flashplayer.XXXX mountpoint for the disk image
 
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/flashplayer.XXXX`

    # Mount the latest Flash Player disk image to /tmp/flashplayer.XXXX mountpoint
 
    hdiutil attach "$flash_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

  # Install Adobe Flash Player from the installer package stored inside the disk image

    /usr/sbin/installer -dumplog -verbose -pkg "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "/"

  # Clean-up
 
    # Unmount the Flash Player disk image from /tmp/flashplayer.XXXX
 
    /usr/bin/hdiutil detach "$TMPMOUNT"
 
    # Remove the /tmp/flashplayer.XXXX mountpoint
 
    /bin/rm -rf "$TMPMOUNT"

    # Remove the downloaded disk image

    /bin/rm -rf "$flash_dmg"
fi

exit 0
