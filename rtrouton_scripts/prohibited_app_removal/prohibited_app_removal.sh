#!/bin/bash

# This script is designed to remove specified prohibited applications and files.

#
## Editable locations and settings
## Applications and files to be removed:
#
# Enter the list of applications and files to be removed, using their complete filepath.
# For example, if an app named Prohibited App.app is stored in /Applications, it should
# be listed as follows:
#
# /Applications/Prohibited App.app
#
# All listed applications and files should go between the two APPREMOVE lines. 
# The list should look similar to the one shown below:
#
# read -r -d '' applist <<APPREMOVE
#/Applications/BBEdit.app
#/Applications/Cyberduck.app
#/Applications/Firefox.app
#/Applications/GitHub Desktop.app
#/Applications/Microsoft Teams (work or school).app
# APPREMOVE
#

read -r -d '' applist <<APPREMOVE

APPREMOVE

# Define log location

log_location="/var/log/prohibited_software_removal.log"

# Set message which will be displayed to the user if prohibited software
# is found and removed.

user_message_title="Prohibited Software Removed"
user_message_dialog="Prohibited software was found and removed from your Mac. Please see $log_location for details."

# -------------------------------------------------------------------------------------- #
## No editing required below here

# Set exit code

exitCode=0

# Set appfound variable value to zero

appfound=0

# Define ScriptLogging behavior

ScriptLogging(){

    DATE=$(date +%Y-%m-%d\ %H:%M:%S)
    LOG="$log_location"    
    echo "$DATE" " $1" >> $LOG
}

# Detect logged-in account and the associated user home directory
currentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
userHome=$(/usr/bin/dscl . -read "/Users/$currentUser" NFSHomeDirectory | /usr/bin/sed 's/^[^\/]*//g')


# Create log file if not present

if [[ ! -f "$log_location" ]]; then
   touch "$log_location"
fi

# Check the list of the prohibited software and perform the following actions:
#
# 1. Log that a prohibited application was found and that it will be moved to the logged-in user's Trash.
# 2. Move any matching applications to the logged-in user's Trash.
# 3. Change ownership of the moved application to the logged-in user so that the user can empty the Trash
#    without permission errors.
# 4. Verify that the application was moved to the logged-in user's Trash. If not present, log an error.
# 5. Log that it was moved to the logged-in user's Trash.
# 6. If one or more prohibited applications are found, message is displayed to the logged-in user notifying
#    the user that prohibited software was removed and providing the location of the log file.

while read -r appfilepath; do

 # Convert filepath to only display the application or file name
 appname="${appfilepath##*/}"

 if [[ -x "${appfilepath}" ]]; then
    appfound=1
    echo "$appfilepath found. Moving $appname to the Trash of the logged-in user: $currentUser."
    ScriptLogging "$appfilepath found. Moving $appname to the Trash of the logged-in user: $currentUser."
    /bin/mv "${appfilepath}" "${userHome}"/.Trash/"${appname}"
    /usr/sbin/chown -R "$currentUser" "${userHome}"/.Trash/"${appname}"
    if [[ -e "${userHome}"/.Trash/"${appname}" ]]; then
        ScriptLogging "$appname moved to $userHome/.Trash/$appname."
    else
        ScriptLogging "ERROR: $appname not found in the Trash of the logged-in user: $currentUser."
        exitCode=1
    fi  
 fi
done <<< "${applist}"

if [[ "$appfound" = 1 ]]; then
   /usr/bin/osascript -e 'display alert "'"$user_message_title"'" message "'"$user_message_dialog"'"'
fi

exit "$exitCode"