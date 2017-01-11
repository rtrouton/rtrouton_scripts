#!/bin/bash

# This script downloads and installs the latest Flash player for compatible Macs

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Determine current major version of Adobe Flash for use
# with the fileURL variable

flash_version=`/usr/bin/curl --silent http://fpdownload2.macromedia.com/get/flashplayer/update/current/xml/version_en_mac_pl.xml | sed -n 's/.*update version="\([^"]*\).*/\1/p' | sed 's/,/./g'`

# Specify the complete address of the Adobe Flash Player
# disk image
 
fileURL="https://fpdownload.adobe.com/get/flashplayer/pdc/"$flash_version"/install_flash_player_osx.dmg"

# Specify name of downloaded disk image

flash_dmg="$3/tmp/flash.dmg"

if [[ ${osvers} -lt 6 ]]; then
  echo "Adobe Flash Player is not available for Mac OS X 10.5.8 or below."
fi

if [[ ${osvers} -ge 6 ]]; then
 
    # Download the latest Adobe Flash Player software disk image

    /usr/bin/curl --output "$flash_dmg" "$fileURL"

    # Specify a /tmp/flashplayer.XXXX mountpoint for the disk image
 
    TMPMOUNT=`/usr/bin/mktemp -d "$3"/tmp/flashplayer.XXXX`

    # Mount the latest Flash Player disk image to /tmp/flashplayer.XXXX mountpoint
 
    hdiutil attach "$flash_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

    # Install Adobe Flash Player using the installer package. This installer may
    # be stored inside an install application on the disk image, or there may be
    # an installer package available at the root of the mounted disk image.

    if [[ -e "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Flash*\.pkg -o -iname \*Flash*\.mpkg \))" ]]; then    
      pkg_path="$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Flash*\.pkg -o -iname \*Flash*\.mpkg \))"
    elif [[ -e "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.app \))" ]]; then
         adobe_app=`(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.app \))`
        if [[ -e "$(/usr/bin/find "$adobe_app"/Contents/Resources -maxdepth 1 \( -iname \*Flash*\.pkg -o -iname \*Flash*\.mpkg \))" ]]; then
          pkg_path="$(/usr/bin/find "$adobe_app"/Contents/Resources -maxdepth 1 \( -iname \*Flash*\.pkg -o -iname \*Flash*\.mpkg \))"
        fi
    fi

    # Before installation on Mac OS X 10.7.x and later, the installer's
    # developer certificate is checked to see if it has been signed by
    # Adobe's developer certificate. Once the certificate check has been
    # passed, the package is then installed.

    if [[ ${pkg_path} != "" ]]; then
       if [[ ${osvers} -ge 7 ]]; then
         signature_check=`/usr/sbin/pkgutil --check-signature "$pkg_path" | awk /'Developer ID Installer/{ print $5 }'`
         if [[ ${signature_check} = "Adobe" ]]; then
           # Install Adobe Flash Player from the installer package stored inside the disk image
           /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "$3"
         fi
       fi

    # On Mac OS X 10.6.x, the developer certificate check is not an
    # available option, so the package is just installed.
    
       if [[ ${osvers} -eq 6 ]]; then
           # Install Adobe Flash Player from the installer package stored inside the disk image
           /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "$3"
       fi
    fi

    # Clean-up
 
    # Unmount the Flash Player disk image from /tmp/flashplayer.XXXX
 
    /usr/bin/hdiutil detach "$TMPMOUNT"
 
    # Remove the /tmp/flashplayer.XXXX mountpoint
 
    /bin/rm -rf "$TMPMOUNT"

    # Remove the downloaded disk image

    /bin/rm -rf "$flash_dmg"
fi

exit 0