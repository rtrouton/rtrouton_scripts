#!/bin/sh

# Set the the "Enable applet plug-in and Web Start Applications" setting for Java in your Mac's default user template and for all existing users.
# Code adapted from DeployStudio's rc130 ds_finalize script, from the section where DeployStudio is disabling the iCloud and gestures demos


# Get the system's UUID to set ByHost prefs
MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

# Checks first to see if the Mac is running 10.7. If so, the script
# checks the system default user template for the presence of 
# the Library/Preferences and Library/Preferences/ByHost directories.
# If the directories are not found, they are created and then the
# "Enable applet plug-in and Web Start Applications" setting for Java
# setting is enabled.

if [ `sw_vers -productVersion | awk -F. '{ print $2 }'` -ge 7 ]
then
  for USER_TEMPLATE in "/System/Library/User Template"/*
  do
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences
     fi
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences/ByHost
     fi
     if [ -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID} '{ GeneralByTask = { Any = { PrefsVersion = 2; WebComponentsEnabled = true;};};}'
      fi
  done
fi


# Checks first to see if the Mac is running 10.7. If so, the script
# checks the existing user folders in /Users for the presence of 
# the Library/Preferences and Library/Preferences/ByHost directories.
# If the directories are not found, they are created and then the
# "Enable applet plug-in and Web Start Applications" setting for Java
# setting is enabled.

if [ `sw_vers -productVersion | awk -F. '{ print $2 }'` -ge 7 ]
then
  for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
    then 
      if [ ! -d "${USER_HOME}"/Library/Preferences ]
      then
        mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ ! -d "${USER_HOME}"/Library/Preferences/ByHost ]
      then
        mkdir -p "${USER_HOME}"/Library/Preferences/ByHost
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
	chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost
      fi
      if [ -d "${USER_HOME}"/Library/Preferences/ByHost ]
      then
        defaults write "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID} '{ GeneralByTask = { Any = { PrefsVersion = 2; WebComponentsEnabled = true;};};}'
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.*
      fi
    fi
  done
fi
