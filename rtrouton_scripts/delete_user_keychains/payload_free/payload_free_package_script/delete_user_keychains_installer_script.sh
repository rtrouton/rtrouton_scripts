#!/bin/bash
 
# If any previous instances of the delete_user_keychains LaunchDaemon and script exist,
# unload the LaunchDaemon and remove the LaunchDaemon and script files
 
if [[ -f "/Library/LaunchDaemons/com.github.delete_user_keychains.plist" ]]; then
   /bin/launchctl unload "/Library/LaunchDaemons/com.github.delete_user_keychains.plist"
   /bin/rm "/Library/LaunchDaemons/com.github.delete_user_keychains.plist"
fi
 
if [[ -f "/Library/Scripts/delete_user_keychains.sh" ]]; then
   /bin/rm "/Library/Scripts/delete_user_keychains.sh"
fi
 
# Create the delete_user_keychains LaunchDaemon by using cat input redirection
# to write the XML contained below to a new file.
#
# The LaunchDaemon will run at load.
 
/bin/cat > "/tmp/com.github.delete_user_keychains.plist" << 'delete_user_keychains_launchdaemon'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.delete_user_keychains</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/Library/Scripts/delete_user_keychains.sh</string>
	</array>
	<key>QueueDirectories</key>
	<array/>
	<key>RunAtLoad</key>
	<true/>
	<key>WatchPaths</key>
	<array/>
</dict>
</plist>
delete_user_keychains_launchdaemon
 
# Create the delete_user_keychains script by using cat input redirection
# to write the shell script contained below to a new file.
 
/bin/cat > "/tmp/delete_user_keychains.sh" << 'delete_user_keychains_script'
#!/bin/bash

log_location="/var/log/system.log"
  
# This script checks the existing user folders in /Users
# for the presence of the Library/Keychains directory.
#
# If the Keychains directory is found, all contents inside
# removed.

# Function to provide logging of the script's actions to
# the log file defined by the log_location variable

ScriptLogging(){

    DATE=`date +%Y-%m-%d\ %H:%M:%S`
    LOG="$log_location"
    
    echo "$DATE" " $1" >> $LOG
}

 for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ]; then
      if [ -d "${USER_HOME}"/Library/Keychains ]; then
         ScriptLogging "Removing keychains from $USER_HOME/Library/Keychains on this Mac."
        /bin/rm -rf "${USER_HOME}"/Library/Keychains/*
      fi
    fi
  done

exit 0
delete_user_keychains_script
 
# Once the LaunchDaemon file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchDaemon into 
# place in /Library/LaunchDaemons.
 
/usr/sbin/chown root:wheel "/tmp/com.github.delete_user_keychains.plist"
/bin/chmod 755 "/tmp/com.github.delete_user_keychains.plist"
/bin/chmod a-x "/tmp/com.github.delete_user_keychains.plist"
/bin/mv "/tmp/com.github.delete_user_keychains.plist" "/Library/LaunchDaemons/com.github.delete_user_keychains.plist"
 
# Once the script file has been created, fix the permissions
# so that the file is owned by root:wheel and set to be executable
 
/usr/sbin/chown root:wheel "/tmp/delete_user_keychains.sh"
/bin/chmod 755 "/tmp/delete_user_keychains.sh"
/bin/chmod a+x "/tmp/delete_user_keychains.sh"

# After the permissions have been updated, move the script into
# the place that it will be executed from.

/bin/mv "/tmp/delete_user_keychains.sh" "/Library/Scripts/delete_user_keychains.sh"

# Checks to see if any user accounts are currently logged into the console (AKA logged into the GUI via the OS loginwindow)

logged_in_users=`/usr/bin/who | grep console`

# If nobody is logged in, load the LaunchDaemon to begin the script's execution.
# Otherwise, the LaunchDaemon will load during the Mac's next restart.

if [[ "$logged_in_users" == "" ]]; then
  if [[ -f "/Library/LaunchDaemons/com.github.delete_user_keychains.plist" ]]; then 
   /bin/launchctl load -w "/Library/LaunchDaemons/com.github.delete_user_keychains.plist" 
  fi 
fi

exit 0