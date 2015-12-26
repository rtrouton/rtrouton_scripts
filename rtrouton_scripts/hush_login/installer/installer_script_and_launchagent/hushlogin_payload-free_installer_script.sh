#!/bin/bash
 
# If any previous instances of the hushlogin LaunchAgent and script exist,
# unload the LaunchAgent and remove the LaunchAgent and script files
 
if [[ -f "/Library/LaunchAgents/com.github.hush_login.plist" ]]; then
   /bin/launchctl unload "/Library/LaunchAgents/com.github.hush_login.plist"
   /bin/rm "/Library/LaunchAgents/com.github.hush_login.plist"
fi
 
if [[ -f "/Library/Scripts/hush_login.sh" ]]; then
   /bin/rm "/Library/Scripts/hush_login.sh"
fi
 
# Create the hush_login LaunchAgent by using cat input redirection
# to write the XML contained below to a new file.
#
# The LaunchAgent will run at load and every ten minutes thereafter.
 
/bin/cat > "/tmp/com.github.hush_login.plist" << 'HUSH_LOGIN_LAUNCHAGENT'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>com.github.hush_login</string>
	<key>ProgramArguments</key>
	<array>
		<string>sh</string>
		<string>/Library/Scripts/hush_login.sh</string>
	</array>
	<key>RunAtLoad</key>
	<true/>
</dict>
</plist>
HUSH_LOGIN_LAUNCHAGENT
 
# Create the hush_login script by using cat input redirection
# to write the shell script contained below to a new file.
 
/bin/cat > "/tmp/hush_login.sh" << 'HUSH_LOGIN_SCRIPT'
#!/bin/bash

# Disable the display of the Message of the Day (motd) 
# banner, which is  normally shown when opening a new 
# Terminal window, by adding a .hushlogin file to the
# logged-in user's home folder.

if [[ ! -f "$HOME/.hushlogin" ]]; then
   /usr/bin/touch "$HOME/.hushlogin"
fi
HUSH_LOGIN_SCRIPT
 
# Once the LaunchAgent file has been created, fix the permissions
# so that the file is owned by root:wheel and set to not be executable
# After the permissions have been updated, move the LaunchAgent into 
# place in /Library/LaunchAgents.
 
/usr/sbin/chown root:wheel "/tmp/com.github.hush_login.plist"
/bin/chmod 755 "/tmp/com.github.hush_login.plist"
/bin/chmod a-x "/tmp/com.github.hush_login.plist"
/bin/mv "/tmp/com.github.hush_login.plist" "/Library/LaunchAgents/com.github.hush_login.plist"
 
# Once the script file has been created, fix the permissions
# so that the file is owned by root:wheel and set to be executable
# After the permissions have been updated, move the script into the
# place that it will be executed from.
 
/usr/sbin/chown root:wheel "/tmp/hush_login.sh"
/bin/chmod 755 "/tmp/hush_login.sh"
/bin/chmod a+x "/tmp/hush_login.sh"
/bin/mv "/tmp/hush_login.sh" "/Library/Scripts/hush_login.sh"

exit 0