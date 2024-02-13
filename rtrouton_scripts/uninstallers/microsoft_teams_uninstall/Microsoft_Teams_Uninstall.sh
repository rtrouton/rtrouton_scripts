#!/bin/bash

# Uninstalls Microsoft Teams

# kill all running processes
PROCESSES=$(/bin/ps ax | /usr/bin/grep "[/]Applications/Microsoft Teams" | /usr/bin/awk '{ print $1 }')
for PROCESS_ID in ${PROCESSES}; do
	kill -9 "$PROCESS_ID"
done

# remove the global stuff
/bin/rm -rf "/Applications/Microsoft Teams"*.app
		
# remove the user-specific stuff	
LOCAL_USERS=$(/usr/bin/dscl . -list /Users | /usr/bin/grep -v "^_")

for USERNAME in $LOCAL_USERS; do	

	# get path to user's home directory
	USER_HOME=$(/usr/bin/dscl . -read /Users/$USERNAME NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g')

	if [[ -d "$USER_HOME" && "$USER_HOME" != "/var/empty" ]]; then
		
		# Removing Teams files and directories
		
		/usr/bin/sudo -u $USERNAME /usr/bin/defaults delete com.microsoft.teams
		/usr/bin/sudo -u $USERNAME /usr/bin/defaults delete com.microsoft.teams2
		
		/bin/rm -rf "$USER_HOME/Library/Application Support/Microsoft/Teams" \
					"$USER_HOME/Library/Application Support/Electron Helper" \
					"$USER_HOME/Library/Application Support/com.microsoft.teams" \
					"$USER_HOME/Library/Saved Application State/com.microsoft.teams.savedState" \
					"$USER_HOME/Library/Saved Application State/com.microsoft.teams2.savedState" \
					"$USER_HOME/Library/Cookies/com.microsoft.teams.*" \
					"$USER_HOME/Library/Caches/com.microsoft.teams" \
					"$USER_HOME/Library/Caches/com.microsoft.teams.shipit" \
					"$USER_HOME/Library/Containers/com.microsoft.teams2" \
					"$USER_HOME/Library/Containers/com.microsoft.teams2.notificationcenter" \
					"$USER_HOME/Library/Group Containers/UBF8T346G9.com.microsoft.teams" \
					"$USER_HOME/Library/Preferences/ByHost/com.microsoft.teams.Shipit.plist" \
					"$USER_HOME/Library/Preferences/com.microsoft.teams.plist" \
					"$USER_HOME/Library/Preferences/com.microsoft.teams2.plist"
					
		# remove the Microsoft folder from Application Support if empty		
		if [[ -z "$(/bin/ls -A ${USER_HOME}/Library/Application\ Support/Microsoft 2>/dev/null | /usr/bin/grep -v .DS_Store)" ]]; then
			/bin/rm -rf "$USER_HOME/Library/Application Support/Microsoft"
		fi
	fi
done

			
# forget the packages
PKGS=$(/usr/sbin/pkgutil --pkgs | /usr/bin/grep "com.microsoft.teams")
for PKG in ${PKGS}; do
	/usr/sbin/pkgutil --forget "$PKG" >/dev/null 2>&1
done

exit 0