Script automates the download and storage of the Sophos Mac installer onto a Linux web server. The download process was designed for RHEL 6.0.

How it works: Script will mount an SMB share from the Sophos Enterprise console, verify that the mount is good, then tar a copy of the current Mac Sophos installer to /var/www/html/sophos.  

Script assumes the following:

1. That Sophos is being managed by Sophos's Enterprise Console.
2. The Sophos client installers are stored on an SMB share named "Client_Installs", where the Mac installer and all needed config files are in "Client_Installs/ESCOSX"



NOTE: This script may have issues with Kerberos, since it may be trying to log into an SMB share using different credentials than the logged-in user.