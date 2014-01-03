#!/bin/sh
# Checks to see if the Mac is either a MacBook Pro Retina or MacBook Air
# If it's either of these machines, the script will then check for External Network Adapters
# If either adapter is present, it will add the adapter to network services
# Resolves an issue with USB & Thunderbolt Ethernet adapters with DeployStudio 1.6.3

mbpr=`system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}' | cut -f1 -d ","`
mba=`system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}' | cut -c-10`
usbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: USB Ethernet"`
tbAdapter=`/usr/sbin/networksetup -listallhardwareports | grep "Hardware Port: Thunderbolt Ethernet"`

/usr/sbin/networksetup -detectnewhardware

if [ $mbpr = "MacBookPro10" -o $mbpr = "MacBookPro11" ]; then
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
