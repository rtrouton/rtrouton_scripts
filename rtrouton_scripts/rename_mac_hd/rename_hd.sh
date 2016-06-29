#!/bin/sh

# Rename Mac's boot drive to Macintosh HD

diskutil rename / "Macintosh HD"

# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.rename_hd.plist

# Make script self-destruct

rm -rf $0
