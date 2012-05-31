#!/bin/sh

#
# Please see the accompanying README for
# an explanation of what this script is for.
#
# Hat tip to Charles Edge for describing this
# method in this entry on his blog:
# http://krypted.com/mac-os-x/pushing-wireless-networks-out/
#
# Enable the wireless method you need and
# add the correct variables as needed. The
# wireless network name should not contain spaces.

# Determines which OS the script is running on
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# On 10.7 and higher, the Wi-Fi interface needs to be identified.
# On 10.5 and 10.6, the Wi-Fi interface should be named as "AirPort"

wifiDevice=`/usr/sbin/networksetup -listallhardwareports | awk '/^Hardware Port: Wi-Fi/,/^Ethernet Address/' | head -2 | tail -1 | cut -c 9-`

# Set the SSID variable to your wireless network name
# to set the network name you want to connect to.
# Note: Wireless network name cannot contain spaces.
SSID=

# Set the INDEX variable to the index number you’d like
# it to be assigned to (leave it as "0" if you do not know
# what index number to use.)
INDEX=0

# Set the SECURITY variable to the security type of the
# wireless network (NONE, WEP, WPA, WPA2, WPAE or
# WPA2E) Setting it to NONE means that it's an open
# network with no encryption.
SECURITY=

# If you've set the SECURITY variable to something other than NONE,
# set the password here. For example, if you are using WPA
# encryption with a password of "thedrisin", set the PASSWORD
# variable to "thedrisin" (no quotes.)
PASSWORD=
  
# Once the running OS is determined, the settings for the specified
# wireless network are created and set as the first preferred network listed
  
if [[ ${osvers} -ge 7 ]]; then
    networksetup -addpreferredwirelessnetworkatindex $wifiDevice $SSID $INDEX $SECURITY $PASSWORD
else
    networksetup -addpreferredwirelessnetworkatindex AirPort $SSID $INDEX $SECURITY $PASSWORD
fi
