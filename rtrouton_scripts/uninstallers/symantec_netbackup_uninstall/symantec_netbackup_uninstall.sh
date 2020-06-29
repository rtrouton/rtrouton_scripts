#!/bin/sh

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 3 ) || ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 4 ) ]]; then
	/usr/openv/netbackup/bin/bp.kill_all
	rm -rf /usr/openv
	rm -rf /Library/StartupItems/netbackup
	rm /etc/xinetd.d/bpcd
	rm /etc/xinetd.d/bpjava-msvc
	rm /etc/xinetd.d/vnetd
	rm /etc/xinetd.d/vopied
	# Restart xinetd - 10.4 and lower only
	kill -HUP `cat /var/run/xinetd.pid`
if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 5 ) || ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 6 || ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 7 || ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 8 ) ]]; then
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