#!/bin/bash

# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ) ]]; then
  echo "Gatekeeper Not Available For This Version Of Mac OS X"
else
 
# Checks Gatekeeper status on Macs
# running 10.7.x or higher

    gatekeeper_status=`spctl --status | awk '/assessments/ {print $2}'`
   if [ $gatekeeper_status = "disabled" ]; then
      result=Disabled
   else
      result=Active
   fi
   echo $result
fi