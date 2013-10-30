#!/bin/sh

# This script removes all Active Directory binding
# and AD-related Kerberos information on 10.6.x Macs
#
# Original script written by Ben LeRoy
# Source: http://groups.google.com/group/macenterprise/msg/c635ab7bfc2b71d9?dmode=source
# 

rm /Library/Preferences/DirectoryService/ActiveDirectory.plist
rm /Library/Preferences/DirectoryService/ActiveDirectoryDomainCache.plist
rm /Library/Preferences/DirectoryService/ActiveDirectoryDomainPolicies.plist
rm /Library/Preferences/DirectoryService/ActiveDirectoryDynamicData.plist
dscl /Search -delete / CSPSearchPath /Active\ Directory/All\ Domains
dscl /Search -delete /Search/Contact CSPSearchPath /Active\ Directory/All\ Domains
rm /Library/Preferences/edu.mit.Kerberos*
rm /var/db/dslocal/nodes/Default/config/Kerberos\:*
rm /var/db/dslocal/nodes/Default/config/AD\ DS\ Plugin.plist
killall DirectoryService