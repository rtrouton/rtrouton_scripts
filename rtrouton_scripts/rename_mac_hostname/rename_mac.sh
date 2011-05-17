#!/bin/sh

# Rename the Mac to ChangeMe

scutil --set ComputerName ChangeMe
scutil --set LocalHostName ChangeMe

# Remove setup LaunchDaemon item

srm /Library/LaunchDaemons/com.company.rename_mac.plist

# Make script self-destruct

srm $0

