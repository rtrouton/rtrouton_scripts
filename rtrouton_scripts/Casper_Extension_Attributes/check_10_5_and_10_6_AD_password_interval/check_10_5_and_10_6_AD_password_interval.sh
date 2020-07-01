#!/bin/bash

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 5 ) ]]; then
  echo "<result>Unaffected</result>"
fi

if [[ ${osvers} -ge 7 ]]; then
  echo "<result>Unaffected</result>"
fi
 
# Checks AD password interval on 10.5.x Macs

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 5 ) ]]; then
   passinterval=`/usr/libexec/PlistBuddy -c "Print ':AD Advanced Options:Password Change Interval'" /Library/Preferences/DirectoryService/ActiveDirectory.plist`
   if [ $passinterval -eq 0 ]; then
      result=Yes
   else
      result=No
   fi
   echo "<result>$result</result>"
fi

# Checks AD password interval on 10.6.x Macs

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 6 ) ]]; then
   passinterval=`/usr/libexec/PlistBuddy -c "Print ':AD Advanced Options:Password Change Interval'" /Library/Preferences/DirectoryService/ActiveDirectory.plist`
   if [ $passinterval -eq 0 ]; then
      result=Yes
   else
      result=No
   fi
   echo "<result>$result</result>"
fi
