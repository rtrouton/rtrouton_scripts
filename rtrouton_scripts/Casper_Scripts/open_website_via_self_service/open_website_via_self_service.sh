#!/bin/bash

# This script is designed to open a specified website, with the following conditions:
# 
# A. Opening the website using the logged-in user's privileges, even if the script is being run as root
# B. Website is accessed using the logged-in user's default web browser 

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

website=$4

# Use the launchctl tool to open the specified website, using the logged-in user's account privileges
# and the user's default browser.

/bin/launchctl "$launchctl_verb" "$logged_in_user_id_method" /usr/bin/open "$website"