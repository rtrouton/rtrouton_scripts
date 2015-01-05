#!/bin/sh

# This script will add two servers to the Oracle Java Exception Site List. 
# If the servers are already in the whitelist, it will note that in the log, then exit.
# More servers can be added as needed. The existing server entries can also be set to be
# empty (i.e. SERVER2='') as the script will do a check to see if either SERVER value
# is set to be null.

# Server1's address
SERVER1='http://server.name.here'

# Server2's address
SERVER2='https://server.name.here'

LOGGER="/usr/bin/logger"
WHITELIST=$HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites"
SERVER1_WHITELIST_CHECK=`cat $HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites" | grep $SERVER1`
SERVER2_WHITELIST_CHECK=`cat $HOME"/Library/Application Support/Oracle/Java/Deployment/security/exception.sites" | grep $SERVER2`

JAVA_PLUGIN=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

if [[ ${JAVA_PLUGIN} != 'com.oracle.java.JavaAppletPlugin' ]]; then
   ${LOGGER} "Oracle Java browser plug-in not installed"
   exit 0
fi

if [[ ${JAVA_PLUGIN} = 'com.oracle.java.JavaAppletPlugin' ]]; then
 ${LOGGER} "Oracle Java browser plug-in is installed. Checking for Exception Site List."
 if [[ ! -f "$WHITELIST" ]]; then
   ${LOGGER} "Oracle Java Exception Site List not found. Creating Exception Site List."

   # Create exception.sites file
   touch  "$WHITELIST"

   # Add needed server(s) to exception.sites file
   if [[ -n ${SERVER1} ]]; then 
     /bin/echo "$SERVER1" >> "$WHITELIST"
   fi
   if [[ -n ${SERVER2} ]]; then
     /bin/echo "$SERVER2" >> "$WHITELIST"
   fi
   exit 0
 fi

 if [[ -f "$WHITELIST" ]]; then
   ${LOGGER} "Oracle Java Exception Site List Found."

  if [[ -n ${SERVER1_WHITELIST_CHECK} ]]; then

    # Server1 settings are present
	${LOGGER} "${SERVER1_WHITELIST_CHECK} is part of the Oracle Java Exception Site List. Nothing to do here."
    else	    
	# Add Server1 to exception.sites file
    if [[ -n ${SERVER1} ]]; then 
      /bin/echo "$SERVER1" >> "$WHITELIST"
      ${LOGGER} "$SERVER1 has been added to the Oracle Java Exception Site List."
    fi
  fi
  if [[ -n ${SERVER2_WHITELIST_CHECK} ]]; then

    # Server2 settings are present
	${LOGGER} "${SERVER2_WHITELIST_CHECK} is part of the Oracle Java Exception Site List. Nothing to do here."
    else	    
	# Add Server2 to exception.sites file
    if [[ -n ${SERVER2} ]]; then 
      /bin/echo "$SERVER2" >> "$WHITELIST"
      ${LOGGER} "$SERVER2 has been added to the Oracle Java Exception Site List."
    fi  
   fi
 fi
fi
exit 0
