#!/bin/sh

# Checks for Sophos Antivirus uninstaller package.
# If present, uninstall process is run

if [ -d "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
     /usr/sbin/installer -pkg "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target /
elif [ -d "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
     /usr/sbin/installer -pkg "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target /    
else
   echo "Sophos Antivirus Uninstaller Not Present"
fi

# Stops the Sophos menu bar process. Sophos icon will disappear.

killall SophosUIServer


# Make an SMB mount directory, after checking for and removing any leftover instances from a broken install

if [ -d /private/tmp/sophos_mount ]; then
	rm -rf /private/tmp/sophos_mount
	mkdir /private/tmp/sophos_mount
	logger "Sophos SMB mount directory created after removing old directory"
else
	mkdir /private/tmp/sophos_mount
	logger "Sophos SMB mount directory created"
fi


# Make a working directory, after checking for and removing any leftover instances from a broken install

if [ -d /private/tmp/sophos_install ]; then
	rm -rf /private/tmp/sophos_install
	mkdir /private/tmp/sophos_install
	logger "Sophos install temp directory created after removing old directory"
else
	mkdir /private/tmp/sophos_install
	logger "Sophos install temp directory created"
fi

# Mount the Sophos client installs share to /private/tmp/sophos_mount
# To make this script work, you will need to edit the mount_smbfs command
# below with the appropriate login information for your environment

mount_smbfs -o nobrowse //'DOMAIN;username:password'@server.name.here/Client_Installs /private/tmp/sophos_mount

# Zips the contents of the ESCOSX directory from 
# the Client_Installs share and stores it
# as /private/tmp/sophos/sophos.zip

ditto -c -k -X /private/tmp/sophos_mount/ESCOSX /private/tmp/sophos_install/sophos.zip

# Unmount the Client_Installs share and remove the SMB mount directory

umount /private/tmp/sophos_mount
rm -rf /private/tmp/sophos_mount

# Decompress the zip file 

cd /private/tmp/sophos_install/
unzip sophos.zip

# Install. Normally, installer requires sudo, but the jamf binary runs with admin rights, and using sudo here breaks the script.

if [ -d /private/tmp/sophos_install/sophos]; then
   logger "Installing Sophos"
   installer -dumplog -verbose -pkg /private/tmp/sophos/sophos/Sophos\ Anti-Virus.mpkg -target /
   logger "Sophos installation process completed"
else
   echo "Sophos Antivirus Installer Not Present. Aborting Install."
fi
# Cleanup

cd /
rm -rf /private/tmp/sophos_install

exit 0
