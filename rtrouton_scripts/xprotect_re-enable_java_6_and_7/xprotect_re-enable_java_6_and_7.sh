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

javaVendor=`/usr/bin/defaults read "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info" CFBundleIdentifier`

CURRENT_JAVA_6_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaVM:JVMVersion" "/Library/Java/Home/bundle/Info.plist"`
XPROTECT_JAVA_6_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaWebComponentVersionMinimum" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist`

CURRENT_JAVA_6_JavaAppletPlugin=`/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist"`
XPROTECT_JAVA_6_JavaAppletPlugin=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.apple.java.JavaAppletPlugin:MinimumPlugInBundleVersion" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist`

CURRENT_JAVA_6_JavaPlugin2_NPAPI=`/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist"`
XPROTECT_JAVA_6_JavaPlugin2_NPAPI=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.apple.java.JavaPlugin2_NPAPI:MinimumPlugInBundleVersion" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist`

CURRENT_JAVA_7_BUILD=`/usr/libexec/PlistBuddy -c "print :CFBundleVersion" "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Info.plist"`
XPROTECT_JAVA_7_BUILD=`/usr/libexec/PlistBuddy -c "print :PlugInBlacklist:10:com.oracle.java.JavaAppletPlugin:MinimumPlugInBundleVersion" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist`



#
# Check to see if Xprotect is blocking Apple's Java 6 browser plug-in and re-enable the plug-in if needed.
# Some changes in this section are from Pepijn Bruienne's re-enable_java_6 script: https://github.com/bruienne
#

if [[ -e /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist ]]; then
	
	if [[ ${CURRENT_JAVA_6_BUILD} != ${XPROTECT_JAVA_6_BUILD} ]]; then

	 	  /usr/bin/logger "Current Java 6 build (${CURRENT_JAVA_6_BUILD}) does not match the minimum build required by Xprotect (${XPROTECT_JAVA_6_BUILD}). Setting current version as the minimum build."
	 	  /usr/bin/defaults write /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta JavaWebComponentVersionMinimum -string "$CURRENT_JAVA_6_BUILD"
	 	  /usr/bin/plutil -convert xml1 /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /bin/chmod a+r /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	else
	 	  /usr/bin/logger "Current Java 6 version is ${CURRENT_JAVA_6_BUILD} and Xprotect minimum build is ${XPROTECT_JAVA_6_BUILD}, nothing to do here."
	fi

      # If the Java vendor is reported as "com.apple.java.JavaAppletPlugin",
      # the Apple Java browser plug-in is running on Mac OS X 10.6.x or was 
      # installed on 10.7.x or later by Java for OS X 2012-005 or earlier.
      # Installing Java for OS X 2012-006 and later automatically removes
      # the Apple Java browser plug-in.


      if [[ "$javaVendor" = "com.apple.java.JavaAppletPlugin" ]]; then 
	 	if [[ ${CURRENT_JAVA_6_JavaAppletPlugin} != ${XPROTECT_JAVA_6_JavaAppletPlugin} ]]; then

	 	  /usr/bin/logger "Current Java 6 browser plug-in (${CURRENT_JAVA_6_JavaAppletPlugin}) does not match the minimum build required by Xprotect (${XPROTECT_JAVA_6_JavaAppletPlugin}). Setting current version as the minimum build."
	 	  /usr/libexec/PlistBuddy -c "Set :PlugInBlacklist:10:com.apple.java.JavaAppletPlugin:MinimumPlugInBundleVersion $CURRENT_JAVA_6_JavaAppletPlugin" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /usr/bin/plutil -convert xml1 /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /bin/chmod a+r /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	    else
	 	  /usr/bin/logger "Current Apple Java browser plug-in version is ${CURRENT_JAVA_6_JavaAppletPlugin} and Xprotect minimum version is ${XPROTECT_JAVA_6_JavaAppletPlugin}, nothing to do here."
		fi	

      fi
   
      # If the Java vendor is reported as "com.apple.java.JavaPlugin2_NPAPI",
      # the Apple Java plug-in was re-enabled using the procedure in the 
      # following Apple KBase article: http://support.apple.com/kb/HT5559

      if [[ "$javaVendor" = "com.apple.java.JavaPlugin2_NPAPI" ]]; then 
	 	if [[ ${CURRENT_JAVA_6_JavaPlugin2_NPAPI} != ${XPROTECT_JAVA_6_JavaPlugin2_NPAPI} ]]; then

	 	  /usr/bin/logger "Current Java 6 browser plug-in (${CURRENT_JAVA_6_JavaPlugin2_NPAPI}) does not match the minimum build required by Xprotect (${XPROTECT_JAVA_6_JavaPlugin2_NPAPI}). Setting current version as the minimum build."
	 	  /usr/libexec/PlistBuddy -c "Set :PlugInBlacklist:10:com.apple.java.JavaPlugin2_NPAPI:MinimumPlugInBundleVersion $CURRENT_JAVA_6_JavaPlugin2_NPAPI" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /usr/bin/plutil -convert xml1 /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /bin/chmod a+r /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	    else
	 	  /usr/bin/logger "Current Apple Java browser plug-in version is ${CURRENT_JAVA_6_JavaPlugin2_NPAPI} and Xprotect minimum version is ${XPROTECT_JAVA_6_JavaPlugin2_NPAPI}, nothing to do here."
		fi	

      fi


#
# Script checks to see if the Mac is running Mac OS X 10.7.x or higher. If it is, the 
# script checks to see if the Oracle Java browser plug-in is installed. If the Oracle 
# Java browser plug-in is installed and Xprotect is blocking the currently installed 
# version of Oracle's Java 7 browser plug-in, the script will re-enable the Java 7 
# browser plug-in.
# 
   
    if [[ ${osvers} -ge 7 ]]; then
      if [[ "$javaVendor" = "com.oracle.java.JavaAppletPlugin" ]]; then 
	 	if [[ ${CURRENT_JAVA_7_BUILD} != ${XPROTECT_JAVA_7_BUILD} ]]; then

	 	  /usr/bin/logger "Current Java 7 build (${CURRENT_JAVA_7_BUILD}) does not match the minimum build required by Xprotect (${XPROTECT_JAVA_7_BUILD}). Setting current version as the minimum build."
	 	  /usr/libexec/PlistBuddy -c "Set :PlugInBlacklist:10:com.oracle.java.JavaAppletPlugin:MinimumPlugInBundleVersion $CURRENT_JAVA_7_BUILD" /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /usr/bin/plutil -convert xml1 /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	 	  /bin/chmod a+r /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist
	    else
	 	  /usr/bin/logger "Current Oracle Java version is ${CURRENT_JAVA_7_BUILD} and Xprotect minimum version is ${XPROTECT_JAVA_7_BUILD}, nothing to do here."
		fi	
	  fi
    fi
fi
exit 0
