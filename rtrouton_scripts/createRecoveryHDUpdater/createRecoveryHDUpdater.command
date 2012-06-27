#!/bin/bash

#this script will make a disk image with the tools needed to update your Recovery HD with the newest OS X Lion release
# Author: Joel Bruner (aka brunerd)

#Required components:
#Lion Recovery Update v1.0 - http://support.apple.com/downloads/DL1464/en_US/RecoveryHDUpdate.dmg
#"Install Mac OS X Lion.app" - App Store

###########################
# RecoveryHD Updater.command
###########################

#this script that will be saved to the disk image that is created
RecoveryHDUpdaterScript='#!/bin/bash
clear;
MYPATH="$(dirname "$0")"

#get destination drive
if [ "$1" == "" ]; then
echo -n "Please drag in DESTINATION disk for Recovery HD partition and press Enter: "
while [ -z "$DEST" ]; do
read DEST
done
if [ ! -d "$DEST" ]; then echo "$DEST not found"; exit; fi 
else
DEST="$1"
fi

#create Recovery partition
sudo "$MYPATH"/bin/dmtest ensureRecoveryPartition "$DEST" "$MYPATH"/etc/BaseSystem.dmg 0 0 "$MYPATH"/etc/BaseSystem.chunklist
'
######
# END
######

###########################
# VARIABLES
###########################

#IMAGETEMP is the pathname for the disk image being built, will the OS and Build appended to the name later
IMAGETEMP="/tmp/Recovery HD Updater"

#temp folder for package expansion
RECOVERY_EXPANDED="/tmp/RecoveryHDUpdate"

#Mounted disk image paths 
ESDPATH="/Volumes/Mac OS X Install ESD"
RECOVERYPATH="/Volumes/Mac OS X Lion Recovery HD Update"

#############
# MAIN SCRIPT
#############
clear;
#get Recovery Update dmg path
if [ "$1" == "" ]; then
echo -n "Please drag in RecoveryHDUpdate.dmg and press enter: "
while [ -z "$RECOVERYHDUPDATE" ]; do
read RECOVERYHDUPDATE
done
if [ ! -f "$RECOVERYHDUPDATE" ]; then echo "$RECOVERYHDUPDATE not found"; exit; fi 
else
RECOVERYHDUPDATE="$1"
fi

#get Lion Installer path
if [ "$2" == "" ]; then
echo -n "Please drag in \"Install Mac OS X Lion.app\" and press enter: "
while [ -z "$LION" ]; do
read LION
done
if [ ! -d "$LION" ]; then echo "$LION not found"; exit; fi 
else
LION="$2"
fi

#get destination path for disk image to be created at
if [ "$3" == "" ]; then
echo -n "Please drag in Destination folder for disk image: "
while [ -z "$DEST" ]; do
read DEST
done
if [ ! -d "$DEST" ]; then echo "$DEST is not a valid path"; exit; fi 
else
DEST="$3"
fi

#mount Recovery Update image
hdiutil attach "$RECOVERYHDUPDATE"

#expand packge inside to temp folder (contains dmtest)
pkgutil --expand "$RECOVERYPATH"/RecoveryHDUpdate.pkg "$RECOVERY_EXPANDED"

#if we were using what's inside the chunklist and recovery inside the update we would mount this
#RecoveryHDMeta="/Volumes/Recovery HD Update"
#hdiutil attach "$RECOVERY_EXPANDED"/RecoveryHDUpdate.pkg/RecoveryHDMeta.dmg

#open Lion install ESD image for the newest files
hdiutil attach "$LION"/Contents/SharedSupport/InstallESD.dmg

#get OS version from Lion Installer ESD
OSVER=$(defaults read "$ESDPATH"/System/Library/CoreServices/SystemVersion ProductUserVisibleVersion)
OSBUILD=$(defaults read "$ESDPATH"/System/Library/CoreServices/SystemVersion ProductBuildVersion)

#append info to path so disk image volume name is informative and useful
IMAGETEMP="$IMAGETEMP $OSVER $OSBUILD"

#make work the folder
mkdir -p "$IMAGETEMP"/etc/
mkdir "$IMAGETEMP"/bin/

#copy dmtest to IMAGETEMP
if [ -f "$RECOVERY_EXPANDED"/RecoveryHDUpdate.pkg/Scripts/Tools/dmtest ]; then
cp "$RECOVERY_EXPANDED"/RecoveryHDUpdate.pkg/Scripts/Tools/dmtest "$IMAGETEMP"/bin/
else
echo "$RECOVERY_EXPANDED/RecoveryHDUpdate.pkg/Scripts/Tools/dmtest not found, exiting"
exit 1
fi

#copy the BaseSystem dmg and chunklist to destination/etc
if [ -f "$ESDPATH"/BaseSystem.chunklist -o -f "$ESDPATH"/BaseSystem.dmg  ]; then
cp "$ESDPATH"/BaseSystem.chunklist "$ESDPATH"/BaseSystem.dmg "$IMAGETEMP"/etc/
#unhide BaseSystem
chflags -R nohidden "$IMAGETEMP"
else
echo "$ESDPATH/BaseSystem* not found, exiting"
fi

#put script in folder root
echo "$RecoveryHDUpdaterScript" > "$IMAGETEMP"/"RecoveryHD Updater.command"
#set permissions
chmod ugo+x "$IMAGETEMP"/"RecoveryHD Updater.command"

#create disk image from folder
hdiutil create -srcfolder "$IMAGETEMP" "$DEST"/RecoveryHDUpdater_$OSVER_$OSBUILD.dmg
if [ $? -eq 0 ]; then
echo "Success! Created: $DEST/RecoveryHDUpdater_$OSVER_$OSBUILD.dmg"
echo "Now opening "$DEST"/RecoveryHDUpdater_$OSVER_$OSBUILD.dmg"
hdiutil attach "$DEST"/RecoveryHDUpdater_$OSVER_$OSBUILD.dmg
else
echo "Disk Image failed"
fi

echo "Cleaning Up"
#delete temp folders
rm -rf "$IMAGETEMP" "$RECOVERY_EXPANDED"

#eject the volumes
hdiutil eject "$RECOVERYPATH"
hdiutil eject "$ESDPATH"

echo "Done."

exit