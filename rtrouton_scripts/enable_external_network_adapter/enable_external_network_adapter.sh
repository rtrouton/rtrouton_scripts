#!/bin/sh

# Checks to see if the Mac is either a MacBook Pro Retina or MacBook Air
# If it's either of these machines, the script will then check for external USB
# or Thunderbolt network adapters. If either adapter is present, it will add the 
# adapter to network services.
#
# Resolves an issue with USB & Thunderbolt Ethernet adapters with DeployStudio
#
# Original script by Allen Golbig:
# https://github.com/golbiga/Scripts/tree/master/enable_external_network_adapter


mbpr=`system_profiler SPHardwareDataType | awk '/Model Identifier/{print $3}' | cut -f1 -d ","`
mba=`system_profiler SPHardwareDataType | awk '/Model Identifier/{print $3}' | cut -c-10`
usbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB Ethernet"`
tbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Thunderbolt Ethernet"`

/usr/sbin/networksetup -detectnewhardware

if [[ $mbpr = "MacBookPro10" ]] || [[ $mbpr = "MacBookPro11" ]] || [[ $mbpr = "MacBookPro12" ]]; then
	if [ "$usbAdapter" != "" ]; then
		/usr/sbin/networksetup -createnetworkservice USB\ Ethernet 'USB Ethernet'
		echo "USB Ethernet added to Network Services"
	else
		echo "No USB Adapter connected"
	fi
	if [ "$tbAdapter" != "" ]; then
		/usr/sbin/networksetup -createnetworkservice Thunderbolt\ Ethernet 'Thunderbolt Ethernet'
		echo "Thunderbolt Ethernet added to Network Services"
	else
		echo "No Thunderbolt Adapter connected"
	fi	
elif [ $mba = "MacBookAir" ]; then
	if [ "$usbAdapter" != "" ]; then
		/usr/sbin/networksetup -createnetworkservice USB\ Ethernet 'USB Ethernet'
		echo "USB Ethernet added to Network Services"
	else
		echo "No USB Adapter connected"
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