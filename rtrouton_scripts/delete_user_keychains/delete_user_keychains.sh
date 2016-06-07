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