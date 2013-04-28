#!/bin/sh

# Get today's date
TODAY=$(/bin/date "+%FT%TZ")

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Server1's address
SERVER1=server1.name.here

# Server2's address
SERVER2=server2.name.here

# Get Java plug-in info
JAVA_PLUGIN=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

# Check com.apple.Safari.plist for Server1 address
SERVER1_WHITELIST_CHECK=`/usr/bin/defaults read $HOME/Library/Preferences/com.apple.Safari WhitelistedBlockedPlugins | grep PluginHostname | awk '{print $3}' | grep $SERVER1 | tr -d '";'`

# Check com.apple.Safari.plist for Server2 address
SERVER2_WHITELIST_CHECK=`/usr/bin/defaults read $HOME/Library/Preferences/com.apple.Safari WhitelistedBlockedPlugins | grep PluginHostname | awk '{print $3}' | grep $SERVER2 | tr -d '";'`

if [[ ${osvers} -ge 6 ]]; then
  if [[ -n ${SERVER1_WHITELIST_CHECK} ]]; then

        # Server1 settings are present
	/usr/bin/logger "${SERVER1_WHITELIST_CHECK} is part of the Java whitelist in Safari. Nothing to do here."
    else	    
	# Add Server1 to Java whitelist
        /usr/bin/defaults write $HOME/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "'$SERVER1'"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://'$SERVER1'"; "PluginPolicy" = "PluginPolicyNeverBlock";}'
        /usr/bin/logger "$SERVER1 has been added to the Java whitelist in Safari."
  fi

  if [[ -n ${SERVER2_WHITELIST_CHECK} ]]; then

	# Server2 settings are present
	/usr/bin/logger "${SERVER2_WHITELIST_CHECK} is part of the Java whitelist in Safari. Nothing to do here."
     else		
        # Add Server2 to Java whitelist
	/usr/bin/defaults write $HOME/Library/Preferences/com.apple.Safari "WhitelistedBlockedPlugins" -array-add '{"PluginHostname" = "'$SERVER2'"; "PluginIdentifier" = "'$JAVA_PLUGIN'"; "PluginLastVisitedDate" = "'$TODAY'"; "PluginName" = "Java Applet Plug-in"; "PluginPageURL" = "https://'$SERVER2'"; "PluginPolicy" = "PluginPolicyNeverBlock";}'
        /usr/bin/logger "$SERVER2 has been added to the Java whitelist in Safari."
  fi

fi

exit 0
