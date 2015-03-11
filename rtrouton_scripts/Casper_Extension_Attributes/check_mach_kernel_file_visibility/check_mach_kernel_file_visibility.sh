#!/bin/bash

# This Extension Attribute checks to see 
# if the /mach_kernel file is visible.
# The /mach_kernel file should be not visible
# when viewed from the Finder.
#
# EA adapted from script by Tim Sutton.
# Link: http://macops.ca/security-updates-leaving-mach_kernel-visible/
#
# Script will display the following results:
# If the /mach_kernel file exists and is not hidden - Visible
# If the /mach_kernel file exists and is hidden - Hidden
# If the /mach_kernel file does not exist - /mach_kernel not present on OS X xx.xx.xx

# Check for the OS version number

os_version=$(sw_vers -productVersion)

if [ ! -e /mach_kernel ]; then
    result="/mach_kernel not present on OS X $os_version"
fi

if [ -e /mach_kernel ]; then
  if ! /bin/ls -lO /mach_kernel | grep hidden > /dev/null; then
    result=Visible
  else
    result=Hidden
  fi
fi

echo "<result>$result</result>"

exit 0