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
# If an installed version of Java is detected on a Mac 
# running 10.5.8 or earlier, this EA will always return 
# "Apple" as the vendor.

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 6 ) ]]; then
  jdk_installed=`/usr/libexec/java_home 2>/dev/null`
     if [[ "$jdk_installed" == "" ]]; then
        result="No Java JDK Available"
     else
        result="Apple"  
     fi
  echo "<result>$result</result>"
fi

# This section verifies if a Java JDK is installed. 
# Once the presence of an installed JDK has been 
# verified by checking java_home, the JDK is checked
# for the vendor information and will return one of
# the following values:
#
# Apple
# Oracle

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 7 ) ]]; then
   
   jdk_installed=`/usr/libexec/java_home 2>/dev/null`
   
   if [[ "$jdk_installed" == "" ]]; then
        result="No Java JDK Available"
   fi    

   if [[ "$jdk_installed" != "" ]]; then
   javaJDKVendor=`defaults read $(/usr/libexec/java_home | sed 's/Home//g' | sed s'/.$//')/Info CFBundleIdentifier | grep -o "apple\|oracle"`
   
      if [[ "$javaJDKVendor" = "oracle" ]]; then
        result="Oracle"
      elif [[ "$javaJDKVendor" = "apple" ]]; then
        result="Apple"
      fi
    fi
   echo "<result>$result</result>"
fi