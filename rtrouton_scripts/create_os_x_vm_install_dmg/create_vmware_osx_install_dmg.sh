#!/bin/sh
#
# Preparation script for a customized OS X installer for use with VWware Fusion and ESXi
# 
# What the script does, in more detail:
# 
# 1. Mounts the InstallESD.dmg using a shadow file, so the original DMG is left
#    unchanged.
# 2. minstallconfig.xml is also copied, which is looked for by the installer environment's 
#    rc.* files that first load with the system. This allows us to never actually modify the 
#    BaseSystem.dmg and only drop in these extra files.
# 3. Additional installer packages can be added using First Boot Package Install.pkg, 
#    which is added to the OS X install by way of the OSInstall.collection file. The instructions
#    on how to use this package are documented here: 
#    https://github.com/rtrouton/First-Boot-Package-Install
# 4. If desired, a second disk image in .iso format can be generated for use with VMware ESXi
#    servers running on Apple hardware. 
#
# Original script written by Tim Sutton:
# https://github.com/timsutton/osx-vm-templates/tree/master/prepare_iso
#
# Thanks: (brought over from Tim's original script)
# Idea and much of the implementation thanks to Pepijn Bruienne, who's also provided
# some process notes here: https://gist.github.com/4542016. The sample minstallconfig.xml,
# use of OSInstall.collection and readme documentation provided with Greg Neagle's
# createOSXInstallPkg tool also proved very helpful. (http://code.google.com/p/munki/wiki/InstallingOSX)
# User creation via package install method also credited to Greg, and made easy with Per
# Olofsson's CreateUserPkg (http://magervalp.github.io/CreateUserPkg)

usage() {
	cat <<EOF
Usage:
$(basename "$0") "/path/to/InstallESD.dmg" /path/to/output/directory
$(basename "$0") "/path/to/Install OS X Mavericks / Mountain Lion / Lion.app" /path/to/output/directory

Description:
Converts a 10.7/10.8/10.9 installer image to a new image that contains components
used to perform an automated installation. The new image will be named
'OSX_InstallESD_[osversion].dmg.'

EOF
}

msg_status() {
	echo "\033[0;32m-- $1\033[0m"
}
msg_error() {
	echo "\033[0;31m-- $1\033[0m"
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

if [ $(id -u) -ne 0 ]; then
	msg_error "This script must be run as root, as it saves a disk image with ownerships enabled."
	exit 1
fi	

ESD="$1"
if [ ! -e "$ESD" ]; then
	msg_error "Input installer image $ESD could not be found! Exiting.."
	exit 1
fi

if [ -d "$ESD" ]; then
	# we might be an install .app
	if [ -e "$ESD/Contents/SharedSupport/InstallESD.dmg" ]; then
		ESD="$ESD/Contents/SharedSupport/InstallESD.dmg"
	else
		msg_error "Can't locate an InstallESD.dmg in this source location $ESD!"
	fi
fi

SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"
DEFINITION_DIR="$(cd $SCRIPT_DIR/..; pwd)"

if [ "$2" == "" ]; then
    msg_error "Currently an explicit output directory is required as the second argument."
	exit 1
else
	OUT_DIR="$2"
fi

if [ ! -d "$OUT_DIR" ]; then
	msg_status "Destination dir $OUT_DIR doesn't exist, creating.."
	mkdir -p "$OUT_DIR"
fi

if [ -e "$ESD.shadow" ]; then
	msg_status "Removing old shadow file.."
	rm "$ESD.shadow"
fi

# Script will prompt user if they want an additional image in .iso
# format for use with a VMware ESXi server.

echo "Do you also want an ISO disk image for use with VMware ESXi?"
select yn in "Yes" "No"; do
	case $yn in
		Yes) ISO=1; break;;
		No ) msg_error "ISO disk image will not be created. Proceeding.."; break;;
	esac
done

MNT_ESD=$(/usr/bin/mktemp -d /tmp/vmware-osx-esd.XXXX)
SHADOW_FILE=$(/usr/bin/mktemp /tmp/vmware-osx-shadow.XXXX)
rm "$SHADOW_FILE"
msg_status "Attaching input OS X installer image with shadow file.."
hdiutil attach "$ESD" -mountpoint "$MNT_ESD" -shadow "$SHADOW_FILE" -nobrowse -owners on 
if [ $? -ne 0 ]; then
	[ ! -e "$ESD" ] && msg_error "Could not find $ESD in $(pwd)"
	msg_error "Could not mount $ESD on $MNT_ESD"
	exit 1
fi

msg_status "Mounting BaseSystem.."
 BASE_SYSTEM_DMG="$MNT_ESD/BaseSystem.dmg"
 MNT_BASE_SYSTEM=$(/usr/bin/mktemp -d /tmp/vmware-osx-basesystem.XXXX)
 [ ! -e "$BASE_SYSTEM_DMG" ] && msg_error "Could not find BaseSystem.dmg in $MNT_ESD"
 hdiutil attach "$BASE_SYSTEM_DMG" -mountpoint "$MNT_BASE_SYSTEM" -nobrowse -owners on
 if [ $? -ne 0 ]; then
 	msg_error "Could not mount $BASE_SYSTEM_DMG on $MNT_BASE_SYSTEM"
 	exit 1
fi

SYSVER_PLIST_PATH="$MNT_BASE_SYSTEM/System/Library/CoreServices/SystemVersion.plist"


DMG_OS_VERS=$(/usr/libexec/PlistBuddy -c 'Print :ProductVersion' "$SYSVER_PLIST_PATH")
DMG_OS_VERS_MAJOR=$(echo $DMG_OS_VERS | awk -F "." '{print $2}')
DMG_OS_VERS_MINOR=$(echo $DMG_OS_VERS | awk -F "." '{print $3}')
DMG_OS_BUILD=$(/usr/libexec/PlistBuddy -c 'Print :ProductBuildVersion' "$SYSVER_PLIST_PATH")
msg_status "OS X version detected: 10.$DMG_OS_VERS_MAJOR.$DMG_OS_VERS_MINOR, build $DMG_OS_BUILD"

OUTPUT_DMG="$OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.dmg"
if [ -e "$OUTPUT_DMG" ]; then
	msg_error "Output file $OUTPUT_DMG already exists! We're not going to overwrite it, exiting.."
# 	hdiutil detach "$MNT_ESD"
    hdiutil detach -force "$MNT_ESD"
	exit 1
fi

SUPPORT_DIR="$SCRIPT_DIR/support"

# Add First Boot Package Install.pkg to the OS X installer

FIRSTBOOT_PKG="$SUPPORT_DIR/First Boot Package Install.pkg"

# We'd previously mounted this to check versions
hdiutil detach "$MNT_BASE_SYSTEM"

BASE_SYSTEM_DMG_RW="$(/usr/bin/mktemp /tmp/vmware-osx-basesystem-rw.XXXX).dmg"

msg_status "Converting BaseSystem.dmg to a read-write DMG located at $BASE_SYSTEM_DMG_RW.."

# hdiutil convert -o will actually append .dmg to the filename if it has no extn
hdiutil convert -format UDRW -o "$BASE_SYSTEM_DMG_RW" "$BASE_SYSTEM_DMG"

if [[ $DMG_OS_VERS_MAJOR -ge 9 ]]; then
   msg_status "Growing new BaseSystem.."
   hdiutil resize -size 6G "$BASE_SYSTEM_DMG_RW"
fi

msg_status "Mounting new BaseSystem.."
hdiutil attach "$BASE_SYSTEM_DMG_RW" -mountpoint "$MNT_BASE_SYSTEM" -nobrowse -owners on

if [[ $DMG_OS_VERS_MAJOR -ge 9 ]]; then
  rm "$MNT_BASE_SYSTEM/System/Installation/Packages"
  msg_status "Moving 'Packages' directory from the ESD to BaseSystem.."
  mv -v "$MNT_ESD/Packages" "$MNT_BASE_SYSTEM/System/Installation/"
   	PACKAGES_DIR="$MNT_BASE_SYSTEM/System/Installation/Packages"
else
  	PACKAGES_DIR="$MNT_ESD/Packages"
fi

# Adding a custom rc.cdrom.local that will automatically erase the VM's
# boot drive. Also adding our auto-setup files: minstallconfig.xml and 
# OSInstall.collection

msg_status "Adding automated components.."
CDROM_LOCAL="$MNT_BASE_SYSTEM/private/etc/rc.cdrom.local"
echo "diskutil eraseDisk jhfs+ \"Macintosh HD\" GPTFormat disk0" > "$CDROM_LOCAL"
chmod a+x "$CDROM_LOCAL"
mkdir "$PACKAGES_DIR/Extras"
cp "$SUPPORT_DIR/minstallconfig.xml" "$PACKAGES_DIR/Extras/"
cp "$SUPPORT_DIR/OSInstall.collection" "$PACKAGES_DIR/"
#cp "$SUPPORT_DIR/PartitionInfo.plist" "$PACKAGES_DIR/Extras/"
#cp -R "$AUTOPART_TOOL" "$PACKAGES_DIR/Extras/AutoPartition.app"
cp -r "$FIRSTBOOT_PKG" "$PACKAGES_DIR/"
rm -rf "$SUPPORT_DIR/tmp"

msg_status "Unmounting BaseSystem.."
hdiutil detach "$MNT_BASE_SYSTEM"

if [ $DMG_OS_VERS_MAJOR -lt 9 ]; then
	msg_status "Pre-Mavericks we save back the modified BaseSystem to the root of the ESD."
	rm "$MNT_ESD/BaseSystem.dmg"
# 	msg_status "Removing original BaseSystem.dmg.."
# 	rm "$MNT_ESD/BaseSystem.dmg"
    hdiutil convert -format UDZO -o "$MNT_ESD/BaseSystem.dmg" "$BASE_SYSTEM_DMG_RW"
fi

msg_status "Unmounting.."
hdiutil detach "$MNT_ESD"

msg_status "Converting to .dmg disk image.."

if [ $DMG_OS_VERS_MAJOR -ge 9 ]; then
	msg_status "On Mavericks the entire modified BaseSystem is our output dmg."
	hdiutil convert -format UDZO -o "$OUTPUT_DMG" "$BASE_SYSTEM_DMG_RW"
else
	msg_status "Pre-Mavericks we're modifying the original ESD file."
	hdiutil convert -format UDZO -o "$OUTPUT_DMG" -shadow "$SHADOW_FILE" "$ESD"
fi

rm -rf "$MNT_ESD" "$SHADOW_FILE"

if [[ $ISO = 1 ]]; then
   OUTPUT_ISO="$OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.iso"
   msg_status "Converting to .iso disk image...."
   /usr/bin/hdiutil convert "$OUTPUT_DMG" -format UDTO -o "$OUTPUT_ISO"
   /bin/mv $OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.iso.cdr "$OUTPUT_ISO"
fi

if [ -n "$SUDO_UID" ] && [ -n "$SUDO_GID" ]; then
	msg_status "Fixing permissions.."
	chown -R $SUDO_UID:$SUDO_GID "$OUT_DIR"
fi

msg_status "Checksumming .dmg disk image.."
MD5=$(md5 -q "$OUTPUT_DMG")
msg_status "MD5: $MD5"
msg_status "Built .dmg disk image is located at $OUTPUT_DMG."

if [ -f "$OUTPUT_ISO" ]; then
  msg_status "Checksumming .iso disk image.."
  MD5=$(md5 -q "$OUTPUT_ISO")
  msg_status "MD5: $MD5"
  msg_status "Built .iso disk image is located at $OUTPUT_ISO."
fi

msg_status "Build process finished."