#!/bin/bash

# Checks to see if the Mac is either a MacBook, MacBook Pro Retina or MacBook Air.
# If it's any of these machines, the script will then check for external USB
# or Thunderbolt network adapters. If an adapter is present, it will add the 
# adapter to network services.
#
# Resolves an issue with USB & Thunderbolt Ethernet adapters with DeployStudio
#
# Original script by Allen Golbig:
# https://github.com/golbiga/Scripts/tree/master/enable_external_network_adapter

macbook_check=`/usr/sbin/system_profiler SPHardwareDataType | awk '/Model Name/' | awk -F': ' '{print substr($2,1,7)}'`
usbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB Ethernet"`
usbGigAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB Gigabit Ethernet"`
tbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Thunderbolt Ethernet"`

/usr/sbin/networksetup -detectnewhardware

if [ "$macbook_check" = "MacBook" ]; then
	if [ "$usbAdapter" != "" ]; then
		/usr/sbin/networksetup -createnetworkservice USB\ Ethernet 'USB Ethernet'
		echo "USB Ethernet added to Network Services"
	else
		echo "No USB Adapter connected"
	fi

	if [ "$usbGigAdapter" != "" ]; then
		/usr/sbin/networksetup -createnetworkservice USB\ Gigabit\ Ethernet 'USB Gigabit Ethernet'
		echo "USB Gigabit Ethernet Adapter added to Network Services"
	else
		echo "No USB Gigabit Ethernet Adapter connected"
	fi

	if [ "$tbAdapter" != "" ]; then
		/usr/sbin/networksetup -createnetworkservice Thunderbolt\ Ethernet 'Thunderbolt Ethernet'
		echo "Thunderbolt Ethernet added to Network Services"
	else
		echo "No Thunderbolt Adapter connected"
	fi
else
	echo "This machine does not use external network adapters"	
fi

exit 0