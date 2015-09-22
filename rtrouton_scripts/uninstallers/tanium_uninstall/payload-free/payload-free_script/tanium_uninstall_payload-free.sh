#!/bin/bash

if [[ -f "$3/Library/LaunchDaemons/com.tanium.taniumclient.plist" ]]; then 
   /bin/launchctl unload -w "$3/Library/LaunchDaemons/com.tanium.taniumclient.plist"
   /bin/rm "$3/Library/LaunchDaemons/com.tanium.taniumclient.plist"
fi

if [[ -d "$3/Library/Tanium" ]]; then
   /bin/rm -rf "$3/Library/Tanium"
fi

/usr/sbin/pkgutil --forget com.tanium.taniumclient.TaniumClient.pkg

if [[ -e "$3/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.bom" ]]; then
   /bin/rm "$3/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.bom"
elif [[ -e "$3/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.plist" ]]; then
   /bin/rm "$3/var/db/receipts/com.tanium.taniumclient.TaniumClient.pkg.plist"
fi

exit 0