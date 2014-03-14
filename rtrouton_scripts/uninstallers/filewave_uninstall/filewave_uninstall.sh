#!/bin/sh

# Script for uninstalling FileWave: http://www.filewave.com
# Kills the client, removes all FileWave software (including the catalog and anything inactive)
# The system will stay in its current state, FW will no longer have control over any files.
#
# Original script from here: https://jamfnation.jamfsoftware.com/discussion.html?id=9986

/usr/bin/killall fwcld
/usr/bin/killall fwGUI
/bin/rm -rf /var/FileWave/
/bin/rm -R /usr/local/sbin/FileWave.app
/bin/rm /usr/local/etc/fwcld.plist
/bin/rm /sbin/fwcontrol

/bin/rm /Library/LaunchAgents/com.filewave.fwGUI.plist
/bin/rm /Library/LaunchDaemons/com.filewave.fwcld.plist
/bin/rm /private/var/db/receipts/com.filewave.fwcld.pkg.bom
/bin/rm /private/var/db/receipts/com.filewave.fwcld.pkg.plist
/bin/rm /var/log/fwcld*

exit 0