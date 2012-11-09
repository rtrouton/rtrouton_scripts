#!/bin/sh                           

# Checks for Sophos directory
# and creates it if needed.

if [ -d "/var/www/html/sophos" ]; then
     logger "Sophos Directory Found"
  else
     mkdir "/var/www/html/sophos"
     chown -R root:wheel "/var/www/html/sophos"
     logger "Sophos Directory Created"
fi

# Make an SMB mount directory, after checking for and removing
# any leftover instances from previous mounts

if [ -d /tmp/sophos_mount ]; then
        rm -rf /tmp/sophos_mount
        mkdir /tmp/sophos_mount
        logger "Sophos SMB mount directory created after removing old mount directory"
else
    	mkdir /tmp/sophos_mount
        logger "Sophos SMB mount directory created"
fi

# Mount the Sophos client installs share to /tmp/sophos_mount
# To make this script work, you will need to edit the mount command
# below with the appropriate login information for your environment

mount.cifs //server.name/Client_Installs /tmp/sophos_mount -o user=username,password=password,domain=DOMAIN

# Sanity check to see if the share mounted
# If share did not mount, script reports that
# the Sophos installer is not available and exits

if [ -d /tmp/sophos_mount/ESCOSX ]; then
   logger "Mount successful"
else
   logger "Sophos Antivirus Installer Not Present. Aborting Copy."
   umount /tmp/sophos_mount
   rm -rf /tmp/sophos_mount
   exit 0
fi

# If a previous version of the Sophos zip file is already
# in the backup directory, the previously copied zip file
# is removed.

if [ -f "/var/www/html/sophos/sophos.tgz" ]; then
      rm "/var/www/html/sophos/sophos.tgz"
      logger "Previous Sophos tar file removed"
fi

# Tars the contents of the ESCOSX directory from
# the Client_Installs share and stores it
# as /var/www/html/sophos/sophos.tgz

cd /tmp/sophos_mount

tar cvzf /var/www/html/sophos/sophos.tgz ESCOSX

if [ -f "/var/www/html/sophos/sophos.tgz" ]; then
      logger "New Sophos tar file created"
fi

# Unmount the Client_Installs share and remove the SMB mount directory

cd /

umount /tmp/sophos_mount
logger "Disconnecting from SMB share"

rm -rf /tmp/sophos_mount
logger "Mount directory removed"

exit 0