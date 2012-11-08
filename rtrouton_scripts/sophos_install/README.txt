Script does an automated uninstall and install of Sophos AntiVirus. Script assumes the following:

1. That Sophos is being managed by Sophos's Enterprise Console.
2. The Sophos client installers are stored on an SMB share named "Client_Installs", where the Mac installer and all needed config files are in "Client_Installs/ESCOSX"

The install process will first check to see if Sophos is installed on a system and uninstall it if found. After that, it will copy the latest Sophos installer down, using the information in the script to mount the correct SMB share, then install Sophos.

NOTE: This script may have issues with Kerberos, since it may be trying to log into an SMB share using different credentials than the logged-in user.