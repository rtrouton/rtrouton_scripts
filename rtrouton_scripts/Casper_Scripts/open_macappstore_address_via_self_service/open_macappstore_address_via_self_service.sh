#!/bin/bash

# This script is designed to open a specified application's page on the Mac App Store 
# using the logged-in user's privileges, even if the script is being run as root.

LaunchCtlMethod(){

# This function does an OS version check, to make sure it is using the correct method 
# with the launchctl tool for the OS in question.
#
# For Macs running OS X 10.9.x and earlier, the launchctl's bsexec function was used for this purpose. 
# bsexec allows you to start a process like a tool, script or application in a specific context. 
# One way to get the correct context for the logged-in user is to identify the process identifier (PID) 
# for the loginwindow process associated with the logged-in user.
#
# For Macs running OS X 10.10.x and later, launchctl's asuser function was used for this purpose. 
# The asuser function is designed to take the place of the bsexec function, in the context of 
# starting processes in the context of a specific user account. This makes it easier, as you now 
# just need to figure out the username and do not have to figure out the PID of the user’s loginwindow process.
#
# For more information, see the links below:
# https://derflounder.wordpress.com/2016/03/25/running-processes-in-os-x-as-the-logged-in-user-from-outside-the-users-account/
# https://babodee.wordpress.com/2016/04/09/launchctl-2-0-syntax/

osvers_major=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')

# Identify the username of the logged-in user
logged_in_user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 10 ]]; then

# The launchctl verb for the indicated OS version

launchctl_verb=bsexec

# Identify the loginwindow PID of the logged-in user
logged_in_user_id_method=$(ps auxww | grep "/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow" | grep "$logged_in_user" | grep -v "grep" | awk '{print $2}')

fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 10 ]]; then

# The launchctl verb for the indicated OS version

launchctl_verb=asuser

# Identify the loginwindow PID of the logged-in user
logged_in_user_id_method=`id -u "$logged_in_user"`

fi

}

LaunchCtlMethod

# For the Mac App Store application page, get the URL using the following method:
#
# 1. Open the Mac App Store
# 2. Clicking the disclosure triangle next to the app's price
# 3. Select "Copy link"
#
# After clicking the "Copy link" option, the URL for that Mac App Store page
# is copied to the clipboard and can be pasted where needed.
#
# For more information, please see the following Apple developer documentation:
#
# Technical Q&A QA1633: Creating easy-to-read short links to the App Store for your apps and company
# https://developer.apple.com/library/content/qa/qa1633/_index.html

# This script uses Casper’s Parameter 4 ($4) value for the Mac App Store address, which allows 
# the script to be used by multiple policies to open the policy’s desired page on the Mac App Store.
# 
# For the Parameter 4 ($4) value, use the URL for the Mac App Store page. It will be automatically translated to use the
# correct macappstore:// address
#
# For example, to access the Slack application page on the Mac App Store, enter the following URL:
# 
# https://itunes.apple.com/us/app/slack/id803453959?mt=12
#
# The script will translate it to the following URL, which will trigger the Mac App Store application
# to open the URL instead of the user's default web browser:
#
# macappstore://itunes.apple.com/us/app/slack/id803453959?mt=12

mas_address="$4"

macappstore_app_page=`echo "$mas_address" | sed 's/https/macappstore/g'`

# Use the launchctl tool to open the specified application page on the Mac App Store,
# using the logged-in user's account privileges.

/bin/launchctl "$launchctl_verb" "$logged_in_user_id_method" /usr/bin/open "$macappstore_app_page"
