#!/bin/sh

#
# This extension attribute detects whether or not
# a specific 802.11x wireless network is available
# on a Mac by checking the preferred wireless list
# and if the root CA for the 802.11x network is stored
# in /Library/Keychains/System.keychain
#

# Enter the name of the wireless network
# for the wifiNetwork variable

wifiNetwork="Secure_WiFi_SSID_Here"

# Enter the name of the root CA 
# of the 802.11x network for the
# rootCertificate variable

rootCertificate="Certificate_Common_Name_Here"

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# On 10.7 and higher, the Wi-Fi interface needs to be identified.
# On 10.5 and 10.6, the Wi-Fi interface should be named as "AirPort"

wifiDevice=`/usr/sbin/networksetup -listallhardwareports | awk '/^Hardware Port: Wi-Fi/,/^Ethernet Address/' | head -2 | tail -1 | cut -c 9-`

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 7 ) ]]; then
   wifiNetworkCheck=`networksetup -listpreferredwirelessnetworks $wifiDevice | grep "$wifiNetwork" | awk '{print $1}'`
else
   wifiNetworkCheck=`networksetup -listpreferredwirelessnetworks AirPort | grep "$wifiNetwork" | awk '{print $1}'`
fi

certificateCheck=`security find-certificate -c $rootCertificate /Library/Keychains/System.keychain 2>/dev/null | awk '/labl/' | cut -d'=' -f 2 | sed 's/"//g'` 
  
# Once the running OS is determined, the Mac is checked to see if the
# preferred wireless network is listed and the root CA is installed in
# /Library/Keychains/System.keychain

if [[ "${wifiNetworkCheck}" == "" ]]; then
    result="No"
fi

if [[ "${wifiNetworkCheck}" != "" ]] && [[ "${wifiNetworkCheck}" != "$wifiNetwork" ]]; then
    result="No"
fi

if [[ "${wifiNetworkCheck}" == "$wifiNetwork" ]]; then
   if [[ "${certificateCheck}" == "$rootCertificate" ]]; then
        result="Yes"
    else
        result="No"
   fi
fi

echo "<result>$result</result>"