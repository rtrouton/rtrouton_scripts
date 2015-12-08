#!/bin/bash

# This script downloads and installs the latest Oracle Java 8 for compatible Macs

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Specify the "OracleUpdateXML" variable by adding the "SUFeedURL" value included in the
# /Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist file. 
#
# Note: The "OracleUpdateXML" variable is currently specified in the script as that for 
# Java 8 Update 20, but the XML address embedded with Java 8 Update 20 is not special in 
# this regard. I have verified that using the address for Java 8 Update 5 will also work 
# to pull the address of the latest Oracle Java 8 installer disk image. To get the "SUFeedURL"
# value embedded with your currently installed version of Java 8 on Mac OS X, please run
# the following command in Terminal:
#
# defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" SUFeedURL
#
# As of Java 8 Update 20, that produces the following return:
#
# https://javadl-esd-secure.oracle.com/update/mac/au-1.8.0_20.xml
#

OracleUpdateXML="https://javadl-esd-secure.oracle.com/update/mac/au-1.8.0_20.xml"

# Use the XML address defined in the OracleUpdateXML variable to query Oracle via curl 
# for the complete address of the latest Oracle Java 8 installer disk image.

fileURL=`/usr/bin/curl --silent $OracleUpdateXML | awk -F \" /enclosure/'{print $(NF-1)}'`

# Specify name of downloaded disk image

java_eight_dmg="/tmp/java_eight.dmg"

if [[ ${osvers} -lt 7 ]]; then
  echo "Oracle Java 8 is not available for Mac OS X 10.6.8 or earlier."
fi

if [[ ${osvers} -ge 7 ]]; then
 
    # Download the latest Oracle Java 8 software disk image
    # The curl -L option is needed because there is a redirect 
    # that the requested page has moved to a different location.

    /usr/bin/curl --retry 3 -Lo "$java_eight_dmg" "$fileURL"

    # Specify a /tmp/java_eight.XXXX mountpoint for the disk image
 
    TMPMOUNT=`/usr/bin/mktemp -d /tmp/java_eight.XXXX`

    # Mount the latest Oracle Java 8 disk image to /tmp/java_eight.XXXX mountpoint
 
    hdiutil attach "$java_eight_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

    # Install Oracle Java 8 from the installer package. This installer may
    # be stored inside an install application on the disk image, or there
    # may be an installer package available at the root of the mounted disk
    # image.

    if [[ -e "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))" ]]; then    
      pkg_path="$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))"
    elif [[ -e "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.app \))" ]]; then
         oracle_app=`(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.app \))`
        if [[ -e "$(/usr/bin/find "$oracle_app"/Contents/Resources -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))" ]]; then
          pkg_path="$(/usr/bin/find "$oracle_app"/Contents/Resources -maxdepth 1 \( -iname \*Java*\.pkg -o -iname \*Java*\.mpkg \))"
        fi
    fi
         
    # Before installation, the installer's developer certificate is checked to
    # see if it has been signed by Oracle's developer certificate. Once the 
    # certificate check has been passed, the package is then installed.
    
    if [[ "${pkg_path}" != "" ]]; then
        signature_check=`/usr/sbin/pkgutil --check-signature "$pkg_path" | awk /'Developer ID Installer/{ print $5 }'`
           if [[ ${signature_check} = "Oracle" ]]; then
             # Install Oracle Java 8 from the installer package stored inside the disk image
             /usr/sbin/installer -dumplog -verbose -pkg "${pkg_path}" -target "/"
           fi
    fi

    # Clean-up
 
    # Unmount the Oracle Java 8 disk image from /tmp/java_eight.XXXX
 
    /usr/bin/hdiutil detach -force "$TMPMOUNT"
 
    # Remove the /tmp/java_eight.XXXX mountpoint
 
    /bin/rm -rf "$TMPMOUNT"

    # Remove the downloaded disk image

    /bin/rm -rf "$java_eight_dmg"
fi

exit 0