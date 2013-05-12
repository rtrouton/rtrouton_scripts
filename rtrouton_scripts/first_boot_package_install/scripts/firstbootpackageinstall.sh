#!/bin/bash

install_dir=/Users/Shared/fb_installers
LOGGER="/usr/bin/logger"

# Delay the login window by unloading the com.apple.loginwindow
# LaunchDaemon in /System/Library/LaunchDaemons/

/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.loginwindow.plist


#
# If the installers directory is not found, the
# com.apple.loginwindow LaunchDaemon is loaded and
# this script and associated parts self-destruct
#

if [[ ! -d "$install_dir" ]]; then
 ${LOGGER} "Firstboot installer directory not present. Cleaning up."
 /bin/launchctl load /System/Library/LaunchDaemons/com.apple.loginwindow.plist
 /bin/rm -rf /Library/LaunchDaemons/com.company.firstbootpackageinstall.plist
 /bin/rm $0
fi

#
# If the installers directory is found, the
# script installs the packages found in 
# the subdirectories, using the numbered
# subdirectories to set the order of
# installation.
#

if [[ -d "$install_dir" ]]; then
 ${LOGGER} "$install_dir present on Mac"

  # Installing the packages found in 
  # the installers directory using
  # an array

  # Save current IFS state

   OLDIFS=$IFS

  # Change IFS to
  # create newline

   IFS=$'\n'
 
  # read all installer names into an array

  install=($(/usr/bin/find "$install_dir" -maxdepth 2 \( -iname \*\.pkg -o -iname \*\.mpkg \)))
 
  # restore IFS to previous state

  IFS=$OLDIFS
 
  # Get length of the array

  tLen=${#install[@]}
 
  # Use for loop to read all filenames
  # and install the corresponding installer
  # packages
  
  for (( i=0; i<${tLen}; i++ ));
  do
     ${LOGGER} "Installing "${install[$i]}" on this Mac."
     /usr/sbin/installer -dumplog -verbose -pkg "${install[$i]}" -target /
     ${LOGGER} "Finished installing "${install[$i]}" on this Mac."
  done

  # Remove the installers

   ${LOGGER} "Removing $install_dir from this Mac."
   /bin/rm -rf $install_dir
   
  # To accomodate packages needing 
  # a restart, the Mac is restarted
  # at this point.

  ${LOGGER} "Restarting Mac."
  /sbin/reboot

fi

