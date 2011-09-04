#!/bin/sh

osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}

if [ $osvers -eq 3 || 4 ]; then
	/usr/openv/netbackup/bin/bp.kill_all
	rm -rf /usr/openv
	rm -rf /Library/StartupItems/netbackup
	rm /etc/xinetd.d/bpcd
	rm /etc/xinetd.d/bpjava-msvc
	rm /etc/xinetd.d/vnetd
	rm /etc/xinetd.d/vopied
	# Restart xinetd - 10.4 and lower only
	kill -HUP `cat /var/run/xinetd.pid`
else if [[ ${osvers} -eq 5 || 6 || 7 ]]; then
	/usr/openv/netbackup/bin/bp.kill_all
	rm -rf /usr/openv
	launchctl unload /Library/LaunchDaemons/bpcd.plist
	launchctl unload /Library/LaunchDaemons/bpjava-msvc.plist
	launchctl unload /Library/LaunchDaemons/vnetd.plist
	launchctl unload /Library/LaunchDaemons/vopied.plist
 	rm /Library/LaunchDaemons/bpcd.plist
	rm /Library/LaunchDaemons/bpjava-msvc.plist
	rm /Library/LaunchDaemons/vnetd.plist
	rm /Library/LaunchDaemons/vopied.plist
fi
fi