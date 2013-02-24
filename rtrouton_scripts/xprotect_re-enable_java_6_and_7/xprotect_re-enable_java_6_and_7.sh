#!/bin/sh

# This script will check the current Java 6 and Java 7 browser plug-in
# versions and compare them against the minimum version allowed by
# Apple's XProtect malware protection. If the minimum Java version 
# allowed by XProtect does not allow the current version of the Java
# browser plug-in on the Mac, the script will alter the Mac's 
# /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist 
# file to set the minimum version allowed to match the current version
# of the Mac's Java browser plug-in. This allows the Mac's current Java
# browser plug-in to run in Safari without being blocked.


osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

javaVendor=`/usr/bin/defaults read /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin/Contents/Info CFBundleIdentifier`

CURRENT_JAVA_6_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaVM:JVMVersion" "$3/Library/Java/Home/bundle/Info.plist"`
XPROTECT_JAVA_6_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaWebComponentVersionMinimum" "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"`

CURRENT_JAVA_7_BUILD=`/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "$3/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist"`
XPROTECT_JAVA_7_BUILD=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.oracle.java.JavaAppletPlugin:MinimumPlugInBundleVersion" "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"`



#
# Check to see if Xprotect is blocking Apple's Java 6 browser plug-in and re-enable the plug-in if needed.
# Changes in this section are from Cengage Learning's re-enable_java_6 script: https://github.com/cengage
#

if [[ -e "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist" ]]; then
	
	if [ ${CURRENT_JAVA_6_BUILD} != ${XPROTECT_JAVA_6_BUILD} ]; then

	    logger "Current Java 6 build (${CURRENT_JAVA_6_BUILD}) does not match the minimum build required by Xprotect (${XPROTECT_JAVA_6_BUILD}). Setting current version as the minimum build."
		/usr/bin/defaults write "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist" JavaWebComponentVersionMinimum -string "$CURRENT_JAVA_6_BUILD"
		/usr/bin/plutil -convert xml1 "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"
		/bin/chmod a+r "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"
	else
		logger "Current JVM build is ${CURRENT_JAVA_6_BUILD} and Xprotect minimum build is ${XPROTECT_JAVA_6_BUILD}, nothing to do here."
	fi


#
# Script checks to see if the Mac is running Mac OS X 10.7.x or higher. If it is, the 
# script checks to see if the Oracle Java browser plug-in is installed. If the Oracle 
# Java browser plug-in is installed and Xprotect is blocking the currently installed 
# version of Oracle's Java 7 browser plug-in, the script will re-enable the Java 7 
# browser plug-in.
# 
   
    if [[ ${osvers} -ge 7 ]]; then
      if [ "$javaVendor" = "com.oracle.java.JavaAppletPlugin" ]; then 
	 	if [ ${CURRENT_JAVA_7_BUILD} != ${XPROTECT_JAVA_7_BUILD} ]; then

	     	logger "Current Java 7 build (${CURRENT_JAVA_7_BUILD}) does not match the minimum build required by Xprotect (${XPROTECT_JAVA_7_BUILD}). Setting current version as the minimum build."
			/usr/libexec/PlistBuddy -c "Set :PlugInBlacklist:10:com.oracle.java.JavaAppletPlugin:MinimumPlugInBundleVersion $CURRENT_JAVA_7_BUILD" "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"
			/usr/bin/plutil -convert xml1 "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"
			/bin/chmod a+r "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"
	    else
			logger "Current Oracle Java version is ${CURRENT_JAVA_7_BUILD} and Xprotect minimum version is ${XPROTECT_JAVA_7_BUILD}, nothing to do here."
		fi	
	  fi
    fi
fi
exit 0