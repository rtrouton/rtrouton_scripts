#!/bin/bash

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers} -lt 7 ]]; then
  echo "<result>Gatekeeper Not Available For This Version Of Mac OS X</result>"
fi

if [[ ${osvers} -ge 9 ]]; then
  echo "<result>Future Not Known Yet. Revise Me In Mid-2013</result>"
fi
 
# Checks Gatekeeper status on 10.7.x Macs

if [[ ${osvers} -eq 7 ]]; then
    gatekeeper_status=`spctl --status | grep "assessments" | cut -c13-`
   if [ $gatekeeper_status = "disabled" ]; then
      result=Disabled
   else
      result=Active
   fi
   echo "<result>$result</result>"
fi

# Checks Gatekeeper status on 10.8.x Macs

if [[ ${osvers} -eq 8 ]]; then
    gatekeeper_status=`spctl --status | grep "assessments" | cut -c13-`
   if [ $gatekeeper_status = "disabled" ]; then
      result=Disabled
   else
      result=Active
   fi
  echo "<result>$result</result>"
fi
