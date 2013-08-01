#!/bin/sh
#
# Preparation script for a customized OS X installer for use with VWware Fusion
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
#    http://derflounder.wordpress.com/2013/05/13/first-boot-package-install-pkg/
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
$(basename "$0") "/path/to/Install OS X [Mountain] Lion.app" /path/to/output/directory

Description:
Converts a 10.7/10.8 installer image to a new image that contains components
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
DMG_OS_VERS=$(/usr/libexec/PlistBuddy -c 'Print :ProductVersion' "$MNT_ESD/System/Library/CoreServices/SystemVersion.plist")
DMG_OS_VERS_MAJOR=$(echo $DMG_OS_VERS | awk -F "." '{print $2}')
DMG_OS_BUILD=$(/usr/libexec/PlistBuddy -c 'Print :ProductBuildVersion' "$MNT_ESD/System/Library/CoreServices/SystemVersion.plist")
OUTPUT_DMG="$OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.dmg"
if [ -e "$OUTPUT_DMG" ]; then
	msg_error "Output file $OUTPUT_DMG already exists! We're not going to overwrite it, exiting.."
	hdiutil detach "$MNT_ESD"
	exit 1
fi

SUPPORT_DIR="$SCRIPT_DIR/support"

# Add First Boot Package Install.pkg to the OS X installer

FIRSTBOOT_PKG="$SUPPORT_DIR/First Boot Package Install.pkg"

# Add our auto-setup files: minstallconfig.xml and OSInstall.collection
msg_status "Adding automated components.."
mkdir "$MNT_ESD/Packages/Extras"
cp "$SUPPORT_DIR/minstallconfig.xml" "$MNT_ESD/Packages/Extras/"
cp "$SUPPORT_DIR/OSInstall.collection" "$MNT_ESD/Packages/"
cp -r "$FIRSTBOOT_PKG" "$MNT_ESD/Packages/"
rm -rf "$SUPPORT_DIR/tmp"

msg_status "Unmounting.."
hdiutil detach "$MNT_ESD"

msg_status "Converting to final output file.."
hdiutil convert -format UDZO -o "$OUTPUT_DMG" -shadow "$SHADOW_FILE" "$ESD"
rm "$SHADOW_FILE"
rm -rf "$MNT_ESD"

if [ -n "$SUDO_UID" ] && [ -n "$SUDO_GID" ]; then
	msg_status "Fixing permissions.."
	chown -R $SUDO_UID:$SUDO_GID "$OUT_DIR"
fi

if [ -n "$DEFAULT_ISO_DIR" ]; then
	msg_status "Setting ISO file in definition "$DEFINITION_FILE".."
	ISO_FILE=$(basename "$OUTPUT_DMG")
	# Explicitly use -e in order to use double quotes around sed command
	sed -i -e "s/%OSX_ISO%/${ISO_FILE}/" "$DEFINITION_FILE"
fi

msg_status "Checksumming output image.."
MD5=$(md5 -q "$OUTPUT_DMG")
msg_status "MD5: $MD5"

msg_status "Done. Built image is located at $OUTPUT_DMG. Add this iso and its checksum to your template."
