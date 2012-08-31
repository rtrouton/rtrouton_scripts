#!/bin/bash

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers} -lt 5 ]]; then
  echo "<result>Unaffected</result>"
fi

if [[ ${osvers} -ge 7 ]]; then
  echo "<result>Unaffected</result>"
fi
 
# Checks AD password interval on 10.5.x Macs

if [[ ${osvers} -eq 5 ]]; then
   passinterval=`/usr/libexec/PlistBuddy -c "Print ':AD Advanced Options:Password Change Interval'" /Library/Preferences/DirectoryService/ActiveDirectory.plist`
   if [ $passinterval -eq 0 ]; then
      result=Yes
   else
      result=No
   fi
   echo "<result>$result</result>"
fi

# Checks AD password interval on 10.6.x Macs

if [[ ${osvers} -eq 6 ]]; then
   passinterval=`/usr/libexec/PlistBuddy -c "Print ':AD Advanced Options:Password Change Interval'" /Library/Preferences/DirectoryService/ActiveDirectory.plist`
   if [ $passinterval -eq 0 ]; then
      result=Yes
   else
      result=No
   fi
   echo "<result>$result</result>"
fi
