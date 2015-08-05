#!/bin/bash

# Determine OS version

osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

# Oracle did not release their own JDK for Mac OS X 10.5.8 
# or earlier. Instead, Apple handled this and released their
# own JDKs for Java development on those versions of OS X.
# If an installed version of Java is detected on a Mac 
# running 10.5.8 or earlier, this script assumes its
# from Apple and runs java -version to provide the
# version number

if [[ ${osvers} -lt 6 ]]; then
  jdk_installed=`/usr/libexec/java_home 2>/dev/null`
     if [[ "$jdk_installed" == "" ]]; then
        result="Apple Java JDK Not Available"
     elif [[ "$jdk_installed" != "" ]]; then
        javaVersion=`/usr/bin/java -version 2>&1 | awk 'NR==1{ gsub(/"/,""); print $3 }'`
        result="$javaVersion"  
     fi
  echo "<result>$result</result>"
fi

# Apple installed Java by default on 10.6.x, but 
# began phasing it out in 10.7.x and later, so this
# section verifies if Apple's Java is installed. Once
# Apple's Java has been verified by checking java_home
# and the vendor, java -version is called to provide 
# the version number

if [[ ${osvers} -ge 6 ]]; then
   
   java_installed=`/usr/libexec/java_home 2>/dev/null`
   
   if [[ "$java_installed" == "" ]]; then
        result="Apple Java JDK Not Available"
   fi    

   if [[ "$java_installed" != "" ]]; then
   javaVendor=`defaults read $(/usr/libexec/java_home | sed 's/Home//g' | sed s'/.$//')/Info CFBundleIdentifier | grep -o "apple"`
   
      if [[ "$javaVendor" = "apple" ]]; then
      javaVersion=`/usr/bin/java -version 2>&1 | awk 'NR==1{ gsub(/"/,""); print $3 }'`
        result="$javaVersion"
      else
        result="Apple Java JDK Not Available"
      fi
    fi
   echo "<result>$result</result>"
fi