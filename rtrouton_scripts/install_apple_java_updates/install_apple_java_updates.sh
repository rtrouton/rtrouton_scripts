#!/bin/sh

#
# Using the softwareupdate tool
# to detect if the Mac has
# Java for Mac OS X 10.6 Update 16
# as an available update.
#

JAVA_UPDATE_DETECT=$( softwareupdate -l | grep -o "JavaForMacOSX10.6-16.0" )

#
# If Java for Mac OS X 10.6 Update 16
# is an available update, script installs 
# the update. If Java for Mac OS X 10.6 Update 16 is
# not an available update, script reports that and
# exits.
# 

if [[ "${JAVA_UPDATE_DETECT}" = "JavaForMacOSX10.6-16.0" ]]; then
      logger "Installing Java for Mac OS X 10.6 Update 16"
      softwareupdate --install JavaForMacOSX10.6-16.0
   else
      logger "Java for Mac OS X 10.6 Update 16 not an available update. Exiting."
fi

exit 0
