Script does an automated uninstall and install of Sophos AntiVirus. Script assumes the following:

1. That Sophos is being managed by Sophos's Enterprise Console.
2. The Sophos client installers Are available as a compressed tar file from a web server.

The install process will first check to see if Sophos is installed on a system and uninstall it if found. After that, it will copy the latest Sophos installer down, using the information in the script to download a compressed tar file using curl, then install Sophos.