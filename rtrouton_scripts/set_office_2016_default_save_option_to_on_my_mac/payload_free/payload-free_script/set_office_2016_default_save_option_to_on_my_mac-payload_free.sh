#!/bin/bash

# Set the Open and Save options in Office 2016 apps to default to 
# "On My Mac" instead of "Online Locations" in the default user template

 for USER_TEMPLATE in "$3/System/Library/User Template"/*
  do
    /usr/bin/defaults write "${USER_TEMPLATE}/Library/Group Containers/UBF8T346G9.Office/"com.microsoft.officeprefs DefaultsToLocalOpenSave -bool true   
  done

# Set the Open and Save options in Office 2016 apps to default to 
# "On My Mac" instead of "Online Locations" in the user folders
# located in /Users, then fixes the permissions on the affected
# file so that the file is owned by the user folder's owner rather
# than being owned by root.

 for USER_HOME in "$3/Users"*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ]; then
      if [ ! -d "${USER_HOME}/Library/Group Containers/UBF8T346G9.Office" ]; then
        /bin/mkdir -p "${USER_HOME}/Library/Group Containers/UBF8T346G9.Office"
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}/Library"
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}/Library/Group Containers"
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}/Library/Group Containers/UBF8T346G9.Office"
      fi
      if [ -d "${USER_HOME}/Library/Group Containers/UBF8T346G9.Office" ]; then
        /usr/bin/defaults write "${USER_HOME}/Library/Group Containers/UBF8T346G9.Office/"com.microsoft.officeprefs DefaultsToLocalOpenSave -bool true
        /usr/sbin/chown "${USER_UID}" "${USER_HOME}/Library/Group Containers/UBF8T346G9.Office/"com.microsoft.officeprefs.plist
      fi
    fi
  done