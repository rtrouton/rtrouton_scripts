#!/bin/bash

# Determine OS version

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Oracle did not release their own JDK for Mac OS X 10.5.8 
# or earlier. Instead, Apple handled this and released their
# own JDKs for Java development on those versions of OS X.
# 
# If this script runs on a Mac running 10.5.8 or earlier, 
# this EA will always return the following value:
#
# Oracle Java JDK Not Available

if [[ ${osvers} -lt 6 ]]; then
  echo "<result>Oracle Java JDK Not Available</result>"
fi

# This section verifies if Oracle's Java JDK is installed. 
# Once the presence of Oracle's JDK has been verified by 
# checking java_home and the vendor information, java -version
# is called to provide the version number

if [[ ${osvers} -ge 6 ]]; then
   
   jdk_installed=`/usr/libexec/java_home 2>/dev/null`
   
   if [[ "$jdk_installed" == "" ]]; then
        result="Oracle Java JDK Not Available"
   fi    

   if [[ "$jdk_installed" != "" ]]; then
   javaJDKVendor=`defaults read $(/usr/libexec/java_home | sed 's/Home//g' | sed s'/.$//')/Info CFBundleIdentifier | grep -o "oracle"`
   
      if [[ "$javaJDKVendor" = "oracle" ]]; then
      javaJDKVersion=`/usr/bin/java -version 2>&1 | awk 'NR==1{ gsub(/"/,""); print $3 }'`
        result="$javaJDKVersion"
      else
        result="Oracle Java JDK Not Available"
      fi
    fi
   echo "<result>$result</result>"
fi