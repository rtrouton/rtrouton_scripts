#!/bin/sh

#################################################
##  Create localadmin user on imaged machine   ##
#################################################

/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n localadmin

#################################################
##  		Create home folder     	       ##
#################################################

/usr/sbin/createhomedir -c -u localadmin

#################################################
##  Give the localadmin account admin rights   ##
#################################################

/usr/sbin/dseditgroup -o edit -a localadmin -t user admin

# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.setup_admin_user.plist 

# Make script self-destruct

rm -rf $0
