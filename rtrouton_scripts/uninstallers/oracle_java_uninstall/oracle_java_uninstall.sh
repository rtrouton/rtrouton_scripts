#!/bin/bash

# Checks for Oracle Java JRE and JDK installs and removes all
# identified installations.

installedJREs="/Library/Internet Plug-Ins"
installedJDKs="/Library/Java/JavaVirtualMachines"

# Check to see if /Library/Internet Plug-Ins is empty.

if [[ -n $(ls -A "$installedJREs") ]]; then

  # If it's not empty, check for installed JREs. If an installed JRE
  # is detected, check to see if it's from Oracle.

  if [[ -x "${installedJREs}/JavaAppletPlugin.plugin" ]]; then
    jreVendor=$(/usr/bin/defaults read "${installedJREs}/JavaAppletPlugin.plugin/Contents/Enabled.plist" CFBundleIdentifier | /usr/bin/grep -Eo "oracle")

    # If it's from Oracle, remove the Java installation.

    if [[ "$jreVendor" = "oracle" ]]; then
       rm -rf "${installedJREs}/JavaAppletPlugin.plugin"
    fi
  fi
fi

# Check to see if /Library/Java/JavaVirtualMachines is empty.

if [[ -n $(ls -A "$installedJDKs") ]]; then

  # If it's not empty, check for installed JDKs.
  
  for aJDKPath in "${installedJDKs}"/*; do

	# If an installed JDK is detected, check to see if it's from Oracle

	jdkVendor=$(/usr/bin/defaults read "${aJDKPath}/Contents/Info.plist" CFBundleIdentifier | /usr/bin/grep -Eo "oracle")
   
    # If it's from Oracle, remove the Java installation.
    
	if [[ "$jdkVendor" = "oracle" ]]; then
	   rm -rf "${aJDKPath}"
	fi
  done
fi

exit 0
