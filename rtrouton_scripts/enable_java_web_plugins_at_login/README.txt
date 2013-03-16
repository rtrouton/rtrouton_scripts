Enable Java Web Plug-Ins at Login - Uses a script named enable_web_java_plugin.sh that's put into /Library/Scripts and a LaunchAgent named com.company.enable_web_java_plugin.plist that's put into /Library/LaunchAgents. 

The script will perform a couple of tasks:

1. Set the "com.apple.WebKit.JavaPlugInLastUsedTimestamp" plist key in ~/Library/Preferences/.GlobalPreferences.plist

2. Enable the "Enable applet plug-in and Web Start Applications" setting in the Java Preferences application.

The LaunchAgent runs the script on login to any user account with the logging-in user's privileges and permissions. That allows Java applets to be run inside web browsers. 