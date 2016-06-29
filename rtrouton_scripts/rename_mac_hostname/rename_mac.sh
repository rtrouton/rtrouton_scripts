#!/bin/sh

# Rename the Mac to ChangeMe

scutil --set ComputerName ChangeMe
scutil --set LocalHostName ChangeMe
scutil --set HostName ChangeMe

# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.rename_mac.plist

# Make script self-destruct

rm -rf $0

