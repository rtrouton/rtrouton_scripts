#!/bin/bash

# This script is designed for use with virtual machines which
# need to resize their boot volumes. The script checks the boot
# volume using the diskutil info command and detects if the boot
# volume is using HFS+ or APFS for the boot volume's filesystem.
# 
# If the boot volume is using HFS+ for its filesystem, the 
# diskutil resize command is used to assign the boot volume
# all available free space.
#
# If the boot volume is using APFS for its filesystem, the
# diskutil info command is used again to get the appropriate
# APFS container ID. Once the container ID is available, the
# diskutil apfs resizeContainer command is used to assign the
# boot volume's host container all available free space.

ERROR=0

boot_filesystem_check=$(/usr/sbin/diskutil info / | awk '/Type \(Bundle\)/ {print $3}')

if [[ "$boot_filesystem_check" = "hfs" ]]; then
    
    # Use the diskutil resize command to assign
    # all available free space on the drive to 
    # the HFS+ boot volume.
    
    /usr/sbin/diskutil resizeVolume / R

elif [[ "$boot_filesystem_check" = "apfs" ]]; then

     # Get APFS container ID on boot drive

     apfs_container_id=$(/usr/sbin/diskutil info / | awk '/Part of Whole/ {print $4}')
     
    # Use the diskutil apfs resizeContainer to 
    # assign all available free space on the  
    # drive to the APFS boot volume.
     
     /usr/sbin/diskutil apfs resizeContainer /dev/"$apfs_container_id" 0

else

    echo "Filesystem detected: $boot_filesystem_check"
    echo "Unknown filesystem on boot drive."
    echo "Exiting with error."
    ERROR=1

fi

exit $ERROR