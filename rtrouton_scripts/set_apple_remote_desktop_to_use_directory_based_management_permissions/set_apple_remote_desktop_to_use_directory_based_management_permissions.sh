#!/bin/bash

error=0

# To use this script to assign Apple Remote Desktop permissions, define the following:
#
# The username of the account that needs to be assigned Apple Remote Desktop permissions.
# The name of the Apple Remote Desktop management group which assigns the right permissions.
#
# The Apple Remote Desktop group permissions are defined below:
#
# Name: com.apple.local.ard_admin
# Assigned rights: Generate reports, Open and quit applications, Change settings, Copy Items
#                  Delete and replace items, Send messages, Restart and Shut down, Control,
#                  Observe, Show being observed
#
# Name: com.apple.local.ard_interact
# Assigned rights: Send messages, Control, Observe, Show being observed
#
# Name: com.apple.local.ard_manage
# Assigned rights: Generate reports, Open and quit applications, Change settings, Copy Items
#                  Delete and replace items, Send messages, Restart and Shut down
#
# Name: com.apple.local.ard_reports
# Assigned rights: Generate reports
#
# For example, to assign all Apple Remote Desktop permissions to an account named
# "administrator", the user and group variables should appear as shown below:
#
# arduser="administrator"
# ardgroup="com.apple.local.ard_admin"
# 
# To assign only the permissions to screenshare and send messages to an account
# named "helpdesk", the user and group variables should appear as shown below:
#
# arduser="helpdesk"
# ardgroup="com.apple.local.ard_interact"
# 

arduser=""
ardgroup=""

# Do not edit below this line.

CreateGroups(){

# This function will create groups as needed using the dseditgroup tool.

/usr/sbin/dseditgroup -n /Local/Default "$groupname"
  if [ $? != 0 ]; then
      echo "$groupname group does not exist.  Creating $groupname group."
      /usr/sbin/dseditgroup -n /Local/Default -o create "$groupname"
  else
      echo "$groupname group already exists."
  fi
}

CreateAppleRemoteDesktopGroups(){

# This function will use the CreateGroups function to create the local groups used by 
# Apple Remote Desktop's directory-based permissions management.

# To create the com.apple.local.ard_admin group

groupname=com.apple.local.ard_admin

CreateGroups

# To create the com.apple.local.ard_interact group

groupname=com.apple.local.ard_interact

CreateGroups

# To create the com.apple.local.ard_manage group

groupname=com.apple.local.ard_manage

CreateGroups

# To create the com.apple.local.ard_reports group

groupname=com.apple.local.ard_reports

CreateGroups

}

AddUsersToAppleRemoteDesktopGroups(){

   # This function will add users to the groups used by Apple Remote Desktop's directory-based management:

	/usr/sbin/dseditgroup -o edit -a "$arduser" -t user "$ardgroup"
	echo "Added $arduser to $ardgroup"
}

EnableAppleRemoteDesktopDirectoryManagement(){

ardkickstart="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"

# Turn on Apple Remote Desktop by activating
# the Apple Remote Desktop management agent 

$ardkickstart -activate

# Allow Apple Remote Desktop accesss only for specified users

$ardkickstart -configure -allowAccessFor -specifiedUsers

# Enable Apple Remote Desktop management groups

$ardkickstart -configure -clientopts -setdirlogins -dirlogins yes

# Restart the Apple Remote Desktop agent process

$ardkickstart -restart -agent &

}

VerifyUser(){

/usr/bin/id "$arduser"
if [ $? != 0 ]; then
   echo "Unable to set specified Apple Remote Desktop permissions!"
   echo "$arduser account not found on this Mac."
   error=1
   exit "$error"
else
   echo "$arduser account verified as existing on this Mac. Proceeding..."
fi

}


if [[ -n "$arduser" ]] && [[ -n "$ardgroup" ]]; then

   # Verify that the specified user account exists.

   VerifyUser

   # Create Apple Remote Desktop management groups
   # and add the specified user account to the
   # specified management group.
   
   CreateAppleRemoteDesktopGroups
   AddUsersToAppleRemoteDesktopGroups
   
   # Turn on Apple Remote Desktop and configure
   # it to use Apple Remote Desktop's directory-based 
   # management to assign permissions.
   
   EnableAppleRemoteDesktopDirectoryManagement

else
   echo "Unable to set specified Apple Remote Desktop permissions!"
   echo "arduser variable is set to: $arduser"
   echo "ardgroup variable is set to: $ardgroup"
   error=1
fi

exit $error