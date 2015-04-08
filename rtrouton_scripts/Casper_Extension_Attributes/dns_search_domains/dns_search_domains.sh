#!/bin/sh

if [[ -f "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/networksetup" ]] && [[ ! -f "/usr/sbin/networksetup" ]]; then	
	NetworkInterface=`/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/networksetup -listnetworkserviceorder 2>&1 | grep $(/usr/sbin/netstat -rn 2>&1 | /usr/bin/grep -m 1 'default' | /usr/bin/awk '{ print $6 }') | sed -e "s/.*Port: //g" -e "s/,.*//g"`
	echo "<result>`/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/networksetup -getsearchdomains "$NetworkInterface" 2>&1`</result>"
fi

if [[ -f "/usr/sbin/networksetup" ]]; then
	NetworkInterface=`/usr/sbin/networksetup -listnetworkserviceorder 2>&1 | grep $(/usr/sbin/netstat -rn 2>&1 | /usr/bin/grep -m 1 'default' | /usr/bin/awk '{ print $6 }') | sed -e "s/.*Port: //g" -e "s/,.*//g"`
	echo "<result>`/usr/sbin/networksetup -getsearchdomains "$NetworkInterface" 2>&1`</result>"
fi

if [[ ! -f "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/networksetup" ]] && [[ ! -f "/usr/sbin/networksetup" ]]; then
	echo "<result>The systemsetup binary is not present on this machine.</result>"
fi

exit 0