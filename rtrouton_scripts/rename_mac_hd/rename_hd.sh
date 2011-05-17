#!/bin/sh

# Rename Mac's boot drive to Macintosh HD

diskutil rename / "Macintosh HD"

# Remove setup LaunchDaemon item

srm /Library/LaunchDaemons/com.company.rename_hd.plist

# Make script self-destruct

srm $0
