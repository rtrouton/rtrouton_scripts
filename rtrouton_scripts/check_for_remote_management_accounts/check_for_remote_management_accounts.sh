#!/bin/sh

# Determines if the Remote Management settings are set
# for "All Users" or for "Only these users:" in System
# Preferences' Sharing preference pane

ARD_ALL_LOCAL=`/usr/bin/defaults read /Library/Preferences/com.apple.RemoteManagement ARD_AllLocalUsers`

# Lists all local user accounts on the Mac with a UID 
# of greater or equal to 500 and less than 1024. This 
# should exclude all system accounts and network accounts
# 
# List is displayed if the "All Users" setting is 
# set in the Remote Management settings.

ALL_ID500_PLUS_LOCAL_USERS=`/usr/bin/dscl . list /Users UniqueID | awk '$2 >= 500 && $2 < 1024 { print $1; }'`

# Lists all user accounts on the Mac that have been given
# explicit Remote Management rights. List is displayed if 
# the "Only these users:" setting is set in the Remote 
# Management settings.

REMOTE_MANAGEMENT_ENABLED_USERS=`/usr/bin/dscl . list /Users naprivs | awk '{print $1}'`


if [ "$ARD_ALL_LOCAL" = "1" ]; then
        result=$ALL_ID500_PLUS_LOCAL_USERS
elif [ "$ARD_ALL_LOCAL" = "0" ]; then
        result=$REMOTE_MANAGEMENT_ENABLED_USERS
fi

# Displays list of accounts that have 
# been given Remote Management rights

echo $result