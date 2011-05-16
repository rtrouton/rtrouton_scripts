#!/bin/sh

#################################################
##  Create localadmin user on imaged machine   ##
#################################################

/System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n localadmin

#################################################
##  		Create home folder     	       ##
#################################################

createhomedir -c -u localadmin

#################################################
##  Give the localadmin account admin rights   ##
#################################################

dscl . -append /Groups/admin GroupMembership localadmin

# Remove setup LaunchDaemon item

srm /Library/LaunchDaemons/com.company.setup_admin_user.plist 

# Make script self-destruct

srm $0
