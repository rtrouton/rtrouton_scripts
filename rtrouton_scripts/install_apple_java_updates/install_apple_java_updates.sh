#!/bin/sh

#
# Using the softwareupdate tool
# to detect if the Mac has
# Java for Mac OS X 10.6 Update 12
# as an available update.
#

JAVA_UPDATE_DETECT=$( softwareupdate -l | grep -c "JavaForMacOSX10.6-12.0" )

#
# If Java for Mac OS X 10.6 Update 12
# is an available update, script installs 
# the update. If Java for Mac OS X 10.6 Update 12 is
# not an available update, script reports that and
# exits.
# 

if [[ "${JAVA_UPDATE_DETECT}" == "1" ]]; then
      logger "Installing Java for Mac OS X 10.6 Update 12"
      softwareupdate --install JavaForMacOSX10.6-12.0
   else
      logger "Java for Mac OS X 10.6 Update 12 not an available update. Exiting"
fi

exit 0

