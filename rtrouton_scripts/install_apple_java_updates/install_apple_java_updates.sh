#!/bin/sh

#
# Using the softwareupdate tool
# to detect if the Mac has
# Java for Mac OS X 10.6 Update 15
# as an available update.
#

JAVA_UPDATE_DETECT=$( softwareupdate -l | grep -o "JavaForMacOSX10.6-15.0" )

#
# If Java for Mac OS X 10.6 Update 15
# is an available update, script installs 
# the update. If Java for Mac OS X 10.6 Update 15 is
# not an available update, script reports that and
# exits.
# 

if [[ "${JAVA_UPDATE_DETECT}" = "JavaForMacOSX10.6-15.0" ]]; then
      logger "Installing Java for Mac OS X 10.6 Update 15"
      softwareupdate --install JavaForMacOSX10.6-15.0
   else
      logger "Java for Mac OS X 10.6 Update 15 not an available update. Exiting."
fi

exit 0