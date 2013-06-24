#!/bin/bash

# Original version of this script posted by 
# Michael Kuron <michael-lists@PHYSCIP.UNI-STUTTGART.DE>
# Posted to the MacEnterprise list on June 22, 2013:
# http://tinyurl.com/m8fp4ou
#
# This script works on Mac OS X 10.7.0 and higher
#

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers} -ge 7 ]]; then

 # Checks the current Java version and displays the results

 java -version
 
 # Set the JAVA_INSTALL_ON_DEMAND
 # environment variable. This variable
 # overrides the install check and forces
 # the softwareupdate tool to install Apple's
 # latest Java 6 update

 export JAVA_INSTALL_ON_DEMAND=1

 # Uses the softwareupdate tool to check
 # for and get the name of the latest Apple
 # Java update for 10.7.x and 10.8.x

 pkgname=$(softwareupdate --list | grep '*' | grep -i java | awk '{print $2}')

 # Installs the latest available Apple
 # Java update for 10.7.x and 10.8.x

 softwareupdate --install $pkgname

 # Checks the current Java version and displays the results
 java -version
else
 echo "Not supported on this version of Mac OS X"

fi
