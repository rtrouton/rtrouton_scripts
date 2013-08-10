#!/bin/sh
#
# Preparation script for a customized OS X installer for use with VWware Fusion
# 
# What the script does, in more detail:
# 
# 1. Mounts the InstallESD.dmg using a shadow file, so the original DMG is left
#    unchanged.
# 2. minstallconfig.xml and PartitionInfo.plist are also copied, which is looked for by the installer environment's 
#    rc.* files that first load with the system. This allows us to never actually modify the 
#    BaseSystem.dmg and only drop in these extra files.
# 3. Additional installer packages can be added using First Boot Package Install.pkg, 
#    which is added to the OS X install by way of the OSInstall.collection file. The instructions
#    on how to use this package are documented here: 
#    http://derflounder.wordpress.com/2013/05/13/first-boot-package-install-pkg/
# 4. If desired, a second disk image in .iso format can be generated for use with VMware ESXi
#    servers running on Apple hardware. The .iso file will also be stored in the output directory.
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

create_bom() {
	/bin/cat > $SUPPORT_DIR/10_8_AP_bomlist << BOMLIST
.
./System
./System/Library
./System/Library/CoreServices
./System/Library/CoreServices/System Image Utility.app
./System/Library/CoreServices/System Image Utility.app/Contents
./System/Library/CoreServices/System Image Utility.app/Contents/Library
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Info.plist
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/MacOS
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/MacOS/AutoPartition
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/PkgInfo
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/AutoPartition.icns
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/English.lproj
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/English.lproj/Localizable.strings
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/English.lproj/MainMenu.nib
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/French.lproj
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/French.lproj/Localizable.strings
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/French.lproj/MainMenu.nib
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/German.lproj
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/German.lproj/Localizable.strings
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/German.lproj/MainMenu.nib
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/Japanese.lproj
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/Japanese.lproj/Localizable.strings
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/Resources/Japanese.lproj/MainMenu.nib
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/_CodeSignature
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/_CodeSignature/CodeResources
./System/Library/CoreServices/System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app/Contents/version.plist
BOMLIST
}

partition_info() {
	/bin/cat > $SUPPORT_DIR/PartitionInfo.plist << PARTITIONXML
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>confirmPartition</key>
	<false/>
	<key>countdownSeconds</key>
	<integer>5</integer>
	<key>numberOfPartitions</key>
	<integer>1</integer>
	<key>partitions</key>
	<array>
		<dict>
			<key>absoluteSize</key>
			<real>0.0</real>
			<key>fileSystem</key>
			<integer>2</integer>
			<key>locked</key>
			<false/>
			<key>minimumSize</key>
			<real>0.0</real>
			<key>percentSize</key>
			<real>100</real>
			<key>volumeName</key>
			<string>Macintosh HD</string>
		</dict>
	</array>
	<key>specifyTarget</key>
	<false/>
	<key>targetVolume</key>
	<string></string>
</dict>
</plist>
PARTITIONXML
}

# We need to copy over the AutoPartition.app from System Image Utility, and it needs to match the version of the Guest OS
# 10.7 systems need to get Server Admin Tools here:
# http://support.apple.com/kb/DL1596
# direct link: http://support.apple.com/downloads/DL1596/en_US/ServerAdminTools.dmg
AUTOPART_APP_IN_SIU="System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app"
OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')
if [ $DMG_OS_VERS_MAJOR -eq 8 ]; then
	if [ $OSX_VERS -eq 7 ]; then
		msg_status "To build Mountain Lion on Lion, we need to extract AutoPartition.app from within the 10.8 installer ESD."
		create_bom
		SIU_TMPDIR=$(/usr/bin/mktemp -d /tmp/siu-108.XXXX)
		msg_status "Expanding flat package.."
		pkgutil --verbose --expand "$MNT_ESD/Packages/Essentials.pkg" "$SIU_TMPDIR/expanded"

		msg_status "Generating BOM.."
		mkbom -s -i "$SUPPORT_DIR/10_8_AP_bomlist" "$SUPPORT_DIR/BOM"

		msg_status "Extracting AutoPartition.app using ditto.."
		ditto --bom "$SUPPORT_DIR/BOM" -x "$SIU_TMPDIR/expanded/Payload" "$SIU_TMPDIR/ditto"
		if [ ! -d "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}" ]; then
			mkdir "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}"
		fi

		msg_status "Copying out AutoPartition.app.."
		cp -R "$SIU_TMPDIR/ditto/System/Library/CoreServices/$AUTOPART_APP_IN_SIU" "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/"
		msg_status "Removing temporary extracted files.."
		rm -rf "$SIU_TMPDIR"
		rm "$SUPPORT_DIR/BOM"

		AUTOPART_TOOL="$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/AutoPartition.app"

	elif [ $OSX_VERS -eq 8 ]; then
		AUTOPART_TOOL="/System/Library/CoreServices/$AUTOPART_APP_IN_SIU"
		if [ ! -e "$AUTOPART_TOOL" ]; then
			msg_error "We're on Mountain Lion, and should have System Image Utility available at $AUTOPART_TOOL, but it's not available for some reason."
			exit 1
		fi
		cp -R "$AUTOPART_TOOL" "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/"
	fi
# on Lion, we first check if Server Admin Tools are already installed..
elif [ $DMG_OS_VERS_MAJOR -eq 7 ]; then
	msg_status "Building OS X 10.${DMG_OS_VERS_MAJOR}, so trying to locate System Image Utility from Server Admin Tools.."
	AUTOPART_TOOL="/Applications/Server/$AUTOPART_APP_IN_SIU"
	# TODO: Sanity-check that this is actually the right version of SIU
	if [ ! -d "$AUTOPART_TOOL" ]; then
		# then we check if _we_ installed them in support/AutoPartition-10.7
		AUTOPART_TOOL="$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/AutoPartition.app"
		if [ ! -d "$AUTOPART_TOOL" ]; then
			# Lion SAT download
			SAT_URL=http://support.apple.com/downloads/DL1596/en_US/ServerAdminTools.dmg
			
			msg_status "It doesn't seem to be installed."
			msg_status "Attempting download of the Server Admin Tools.."
			SAT_TMPDIR=$(/usr/bin/mktemp -d /tmp/server-admin-tools.XXXX)
			
			curl -L "$SAT_URL" -o "$SAT_TMPDIR/sat.dmg"
			if [ ! -f "$SAT_TMPDIR/sat.dmg" ]; then
				msg_error "Server Admin Tools failed to download. Stopping build process."
				exit 1
			fi
			
			msg_status "Attaching Server Admin Tools.."
			hdiutil attach "$SAT_TMPDIR/sat.dmg" -mountpoint "$SAT_TMPDIR/mnt"

			msg_status "Expanding package.."
			pkgutil --expand "$SAT_TMPDIR/mnt/ServerAdminTools.pkg" "$SAT_TMPDIR/expanded"
			hdiutil detach "$SAT_TMPDIR/mnt"
			mkdir "$SAT_TMPDIR/cpio-extract"

			msg_status "Extracting payload.."
			tar -xz -C "$SAT_TMPDIR/cpio-extract" -f "$SAT_TMPDIR/expanded/ServerAdminTools.pkg/Payload"
			if [ ! -d "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}" ]; then
				mkdir "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}"
			fi

			msg_status "Copying out AutoPartition.app"
			cp -R "$SAT_TMPDIR/cpio-extract/Applications/Server/$AUTOPART_APP_IN_SIU" "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/"

			rm -rf "$SAT_TMPDIR"
			# AUTOPART_TOOL="$SUPPORT_DIR/AutoPartition-${DMG_OS_VERS_MAJOR}/AutoPartition.app"
		else msg_status "Found AutoPartition.app at $AUTOPART_TOOL.."
		fi
	fi
elif [ $DMG_OS_VERS_MAJOR -lt 7 ]; then
	msg_error "This script does not support support building disk images for OS X versions prior to 10.7."
	exit 1
fi

# Add First Boot Package Install.pkg to the OS X installer

FIRSTBOOT_PKG="$SUPPORT_DIR/First Boot Package Install.pkg"

# Writing PartitionInfo.plist to the support directory

partition_info

# Add our auto-setup files: minstallconfig.xml and OSInstall.collection
msg_status "Adding automated components.."
mkdir "$MNT_ESD/Packages/Extras"
cp "$SUPPORT_DIR/minstallconfig.xml" "$MNT_ESD/Packages/Extras/"
cp "$SUPPORT_DIR/OSInstall.collection" "$MNT_ESD/Packages/"
cp "$SUPPORT_DIR/PartitionInfo.plist" "$MNT_ESD/Packages/Extras/"
cp -R "$AUTOPART_TOOL" "$MNT_ESD/Packages/Extras/AutoPartition.app"
cp -r "$FIRSTBOOT_PKG" "$MNT_ESD/Packages/"
rm -rf "$SUPPORT_DIR/tmp"

msg_status "Unmounting.."
hdiutil detach "$MNT_ESD"

msg_status "Converting to .dmg disk image.."
/usr/bin/hdiutil convert -format UDZO -o "$OUTPUT_DMG" -shadow "$SHADOW_FILE" "$ESD"

if [[ $ISO = 1 ]]; then
   OUTPUT_ISO="$OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.iso"
   msg_status "Converting to .iso disk image...."
   /usr/bin/hdiutil convert "$OUTPUT_DMG" -format UDTO -o "$OUTPUT_ISO"
   /bin/mv $OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.iso.cdr "$OUTPUT_ISO"
fi

rm "$SHADOW_FILE"
rm -rf "$MNT_ESD"
rm -rf "$SUPPORT_DIR/"AutoPartition-*
rm "$SUPPORT_DIR/PartitionInfo.plist"


if [ -f "$SUPPORT_DIR/10_8_AP_bomlist" ]; then
	rm "$SUPPORT_DIR/10_8_AP_bomlist"
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
