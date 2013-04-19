#!/bin/sh

# Adding two websites to Safari's Java whitelist in your Mac's default user template and for all existing users.
# Code adapted from DeployStudio's rc130 ds_finalize script, from the section where DeployStudio is disabling the iCloud and gestures demos

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Get today's date

TODAY=$(date "+%FT%TZ")

# Get Java plug-in info
JAVA_PLUGIN=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

# Checks first to see if the Mac is running 10.6 or higher. 
# If so, the script checks the system default user template
# for the presence of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# Java whitelist settings are created.

if [[ ${osvers} -ge 6 ]];
then
  for USER_TEMPLATE in "/System/Library/User Template"/*
  do
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
      then
        /bin/mkdir -p "${USER_TEMPLATE}"/Library/Preferences
     fi
     if [ -d "${USER_TEMPLATE}"/Library/Preferences ]
      then

         # Add Server1 to Java whitelist

         /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "server1.name.here"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://server1.name.here"; "PluginPolicy" = "PluginPolicyNeverBlock";}'

         # Add Server2 to Java whitelist

         /usr/bin/defaults write "${USER_TEMPLATE}"/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "server2.name.here"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://server2.name.here"; "PluginPolicy" = "PluginPolicyNeverBlock";}'
        
     fi
  done
fi


# Checks first to see if the Mac is running 10.6 or higher.
# If so, the script checks the existing user folders in /Users
# for the presence of the Library/Preferences directory.
#
# If the directory is not found, it is created and then the
# Java whitelist settings are created.

if [[ ${osvers} -ge 6 ]];
then
  for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
    then 
      if [ ! -f "${USER_HOME}"/Library/Preferences ]
      then
        /bin/mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ -d "${USER_HOME}"/Library/Preferences ]
      then

         # Add Server1 to Java whitelist

         /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "server1.name.here"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://server1.name.here"; "PluginPolicy" = "PluginPolicyNeverBlock";}'

         # Add Server2 to Java whitelist

         /usr/bin/defaults write "${USER_HOME}"/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "server2.name.here"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://server2.name.here"; "PluginPolicy" = "PluginPolicyNeverBlock";}'

        # Fix permissions on com.apple.Safari.plist

         /usr/sbin/chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/com.apple.Safari.*

      fi
    fi
  done
fi

# Remove setup LaunchDaemon item

srm /Library/LaunchDaemons/com.company.safari_java_whitelist_firstboot.plist

# Make script self-destruct

srm $0
