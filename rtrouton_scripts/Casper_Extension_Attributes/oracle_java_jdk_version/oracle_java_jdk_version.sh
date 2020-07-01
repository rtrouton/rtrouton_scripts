#!/bin/bash

# Determine OS version
# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Oracle did not release their own JDK for Mac OS X 10.5.8 
# or earlier. Instead, Apple handled this and released their
# own JDKs for Java development on those versions of OS X.
# 
# If this script runs on a Mac running 10.5.8 or earlier, 
# this EA will always return the following value:
#
# Oracle Java JDK Not Available

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 6 ) ]]; then
  echo "<result>Oracle Java JDK Not Available</result>"
fi

# This section verifies if Oracle's Java JDK is installed. 
# Once the presence of Oracle's JDK has been verified by 
# checking java_home and the vendor information, java -version
# is called to provide the version number

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 6 ) ]]; then
   
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