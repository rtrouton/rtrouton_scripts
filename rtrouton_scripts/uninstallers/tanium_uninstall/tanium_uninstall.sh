#!/bin/bash

if [[ -f "/Library/LaunchDaemons/com.tanium.taniumclient.plist" ]]; then 
   /bin/launchctl unload -w "/Library/LaunchDaemons/com.tanium.taniumclient.plist"
   /bin/rm "/Library/LaunchDaemons/com.tanium.taniumclient.plist"
fi

if [[ -d "/Library/Tanium" ]]; then
   /bin/rm -rf "/Library/Tanium"
fi

/usr/sbin/pkgutil --forget com.tanium.taniumclient.TaniumClient.pkg

if [[ -e "/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.bom" ]]; then
   /bin/rm "/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.bom"
elif [[ -e "/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.plist" ]]; then
   /bin/rm "/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.plist"
fi