#!/bin/sh

#
# Adding $3 positional markers, to better support 
# running this script as a payload-free package.
#

# Checks for backup directory for Java 7 plug-in
# and creates it if needed.

if [ -d "$3/Library/Internet Plug-Ins (Disabled)" ]; then
     echo "Backup Directory Found"
  else
     mkdir "$3/Library/Internet Plug-Ins (Disabled)"
     chown -R root:wheel "$3/Library/Internet Plug-Ins (Disabled)"
fi

# If a previous version of the Java 7 plug-in is already 
# in the backup directory, the previously backed up Java 7 
# plug-in is removed.

if [ -d "$3/Library/Internet Plug-Ins (Disabled)/JavaAppletPlugin.plugin" ]; then
      rm -rf "$3/Library/Internet Plug-Ins (Disabled)/JavaAppletPlugin.plugin"
fi

# Moves current Java 7 plug-in to the backup directory

if [ -d "$3/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" ]; then
     mv "$3/Library/Internet Plug-Ins/JavaAppletPlugin.plugin" "$3/Library/Internet Plug-Ins (Disabled)/JavaAppletPlugin.plugin"
fi

# Create symlink to the Apple Java 6 plug-in in
# /Library/Internet Plug-Ins 

ln -sf "$3/System/Library/Java/Support/Deploy.bundle/Contents/Resources/JavaPlugin2_NPAPI.plugin" "$3/Library/Internet Plug-Ins/JavaAppletPlugin.plugin"

# Re-enable Java SE 6 Web Start, which allows Java 
# applets to run in web browsers

ln -sf "$3/System/Library/Frameworks/JavaVM.framework/Commands/javaws" "$3/usr/bin/javaws"

#
# Check to see if Xprotect is blocking our current JVM build and reenable if it is
# Changes in this section are from Pepijn Bruienne's fork of this script: https://github.com/bruienne
#

if [[ -e "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist" ]]; then

	CURRENT_JAVA_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaVM:JVMVersion" "$3/Library/Java/Home/bundle/Info.plist"`
	XPROTECT_JAVA_BUILD=`/usr/libexec/PlistBuddy -c "print :JavaWebComponentVersionMinimum" "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist"`

	if [ ${CURRENT_JAVA_BUILD: -3} -lt ${XPROTECT_JAVA_BUILD: -3} ]; then

	     logger "Current JavaVM build (${CURRENT_JAVA_BUILD: -3}) is less than the minimum build required by Xprotect (${XPROTECT_JAVA_BUILD: -3}), reenabling."
		defaults write "$3/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist" JavaWebComponentVersionMinimum -string "$CURRENT_JAVA_BUILD"
	else
		logger "Current JVM build is ${CURRENT_JAVA_BUILD: -3} and Xprotect minimum build is ${XPROTECT_JAVA_BUILD: -3}, nothing to do here."
	fi
else
	logger "Xprotect not found, skipping."
fi

exit 0
