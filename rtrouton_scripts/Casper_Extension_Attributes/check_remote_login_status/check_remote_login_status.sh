#!/bin/sh

if [[ -f "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup" ]] && [[ ! -f "/usr/sbin/systemsetup" ]]; then		
	echo "<result>`/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup -getremotelogin | awk '{print $3}'`</result>"
fi

if [[ -f "/usr/sbin/systemsetup" ]]; then
	echo "<result>`/usr/sbin/systemsetup -getremotelogin | awk '{print $3}'`</result>"
fi

if [[ ! -f "/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Support/systemsetup" ]] && [[ ! -f "/usr/sbin/systemsetup" ]]; then
	echo "<result>The systemsetup binary is not present on this machine.</result>"
fi

exit 0