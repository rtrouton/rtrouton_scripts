#!/bin/sh

#
# Using diskutil list to check for 
# disk partitions reporting as 
# "Microsoft Basic Data"
#

BOOTCAMP_DETECT=$( /usr/sbin/diskutil list disk0 | grep -c "Microsoft Basic Data" )

#
# If Microsoft Basic Data partition is
# reported by diskutil, script reports
# "Yes". If no Microsoft Basic Data partition
# is reported by diskutil, script reports "No".
# 

if [[ "${BOOTCAMP_DETECT}" == "1" ]]; then
      result=Yes
   else
      result=No
fi
echo "<result>$result</result>"

exit 0
