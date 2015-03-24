#/bin/sh

# This script will add multiple servers to the Oracle Java Exception Site List. 
# If the servers are already in the whitelist, it will note that in the log, then exit.
# More servers can be added as needed.

# Enter as many servers as needed -- one per line with single quotes
SERVERS=('http://server.name.here'
'https://server.name.here'
'https://another.server.name.here'
'https://as.many.as.needed')

LOGGER="/usr/bin/logger"
WHITELIST=$HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites"
JAVA_PLUGIN=$(/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier)


if [[ ${JAVA_PLUGIN} != 'com.oracle.java.JavaAppletPlugin' ]]; then
	${LOGGER} "Oracle Java browser plug-in not installed"
	exit 1
else
	${LOGGER} "Oracle Java browser plug-in IS installed."
	if [[ ! -f "$WHITELIST" ]]; then
		${LOGGER} "Oracle Java Exception Site List not found. Creating one..."
		touch  "$WHITELIST"
 
		for i in "${SERVERS[@]}"
		do
			${LOGGER} "Adding exception for: $i..."
			echo $i >> "$WHITELIST"
		done
	else
		for i in "${SERVERS[@]}"
		do
			WHITELIST_CHECK=$(cat $HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites" | grep $i)
			if [[ -n ${WHITELIST_CHECK} ]];then
				${LOGGER} "Exception already exists..."
			else
				${LOGGER} "Adding exception for: $i..."
				echo "$i" >> "$WHITELIST"
			fi
		done
	fi
fi