#!/bin/sh

# Set the the "Enable applet plug-in and Web Start Applications" setting for Java in your Mac's default user template and for all existing users.
# Code adapted from DeployStudio's rc130 ds_finalize script, from the section where DeployStudio is disabling the iCloud and gestures demos

osversionlong=`sw_vers -productVersion`
osvers=${osversionlong:3:1}


# Get the system's UUID to set ByHost prefs
MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')

# Checks first to see if the Mac is running 10.7 or 10.8. If so, the script
# checks the system default user template for the presence of 
# the Library/Preferences and Library/Preferences/ByHost directories.
# If the directories are not found, they are created and then the
# "Enable applet plug-in and Web Start Applications" setting for Java
# setting is enabled.

if [[ ${osvers} -eq 7 || 8 ]];
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
        /usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsEnabled" "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
	/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsEnabled bool true" "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
	/usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsLastUsed" "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
	/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsLastUsed real $(( $(date "+%s") - 978307200 ))" "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
      fi
  done
fi


# Checks first to see if the Mac is running 10.7 or 10.8. If so, the script
# checks the existing user folders in /Users for the presence of 
# the Library/Preferences and Library/Preferences/ByHost directories.
# If the directories are not found, they are created and then the
# "Enable applet plug-in and Web Start Applications" setting for Java
# setting is enabled.

if [[ ${osvers} -eq 7 || 8 ]];
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
        /usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsEnabled" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
	/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsEnabled bool true" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
	/usr/libexec/PlistBuddy -c "Delete :GeneralByTask:Any:WebComponentsLastUsed" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
	/usr/libexec/PlistBuddy -c "Add :GeneralByTask:Any:WebComponentsLastUsed real $(( $(date "+%s") - 978307200 ))" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.plist
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.*
      fi
    fi
  done
fi
