#!/bin/bash

# This script downloads and installs the latest Oracle Java 7 for compatible Macs

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Including an OS check to pull the minor version number.
# This is to help provide a check for 10.7.0 through 10.7.2,
# as Oracle's Java 7 only runs on 10.7.3 and higher.

osminorvers=$(sw_vers -productVersion | awk -F. '{print $3}')

# Specify the "OracleUpdateXML" variable by adding the "SUFeedURL" value included in the
# /Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist file. 
#
# Note: The "OracleUpdateXML" variable is currently specified in the script as that for 
# Java 7 Update 67, but the XML address embedded with Java 7 Update 67 is not special in 
# this regard. I have verified that using the address for Java 7 Update 15 and 65 will 
# also work to pull the address of the latest Oracle Java 7 installer disk image. To get 
# the "SUFeedURL" value embedded with your currently installed version of Java 7 on Mac OS X,
# please run the following command in Terminal:
#
# defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" SUFeedURL
#
# As of Java 7 Update 67, that produces the following return:
#
# https://javadl-esd-secure.oracle.com/update/mac/au-1.7.0_67.xml
#

OracleUpdateXML="https://javadl-esd-secure.oracle.com/update/mac/au-1.7.0_67.xml"

# Use the XML address defined in the OracleUpdateXML variable to query Oracle via curl 
# for the complete address of the latest Oracle Java 7 installer disk image.

fileURL=`/usr/bin/curl --silent $OracleUpdateXML | awk -F \" /enclosure/'{print $(NF-1)}'`

# Specify name of downloaded disk image

java_seven_dmg="$3/tmp/java_seven.dmg"

if [[ ${osvers} -lt 7 ]]; then
  echo "Oracle Java 7 is not available for Mac OS X 10.6.8 or below."
fi

if [[ ${osvers} -ge 7 ]]; then

    if [[ ${osvers} -eq 7 ]]; then
      if [[ ${osminorvers} -lt 3 ]]; then
        echo "Oracle Java 7 is not available for Mac OS X 10.7.2 or below."
        exit 0
      fi
    fi
 
    # Download the latest Oracle Java 7 software disk image
    # The curl -L option is needed because there is a redirect 
    # that the requested page has moved to a different location.

    /usr/bin/curl --retry 3 -Lo "$java_seven_dmg" "$fileURL"

    # Specify a /tmp/java_seven.XXXX mountpoint for the disk image
 
    TMPMOUNT=`/usr/bin/mktemp -d "$3"/tmp/java_seven.XXXX`

    # Mount the latest Oracle Java 7 disk image to /tmp/java_seven.XXXX mountpoint
 
    hdiutil attach "$java_seven_dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen

    # Install Oracle Java 7 from the installer package stored inside the disk image

    /usr/sbin/installer -dumplog -verbose -pkg "$(/usr/bin/find $TMPMOUNT -maxdepth 1 \( -iname \*\.pkg -o -iname \*\.mpkg \))" -target "$3"

    # Clean-up
 
    # Unmount the Oracle Java 7 disk image from /tmp/java_seven.XXXX
 
    /usr/bin/hdiutil detach -force "$TMPMOUNT"
 
    # Remove the /tmp/java_seven.XXXX mountpoint
 
    /bin/rm -rf "$TMPMOUNT"

    # Remove the downloaded disk image

    /bin/rm -rf "$java_seven_dmg"
fi

exit 0