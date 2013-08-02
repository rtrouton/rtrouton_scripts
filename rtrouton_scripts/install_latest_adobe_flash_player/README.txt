This script will download the latest Adobe Flash Player and install Flash Player using the installer package inside "Install Adobe Flash Player.app". 

NOTE: One thing to be aware of is that installing Flash Player this way will not install the Adobe Flash Updater.

How the script works:

1. Uses curl to download a disk image named "install_flash_player_11_osx.dmg" (no quotes) from Adobe's web site

2. Mounts the disk image silently in /Volumes. Disk image will not be visible to any logged-in user.

3. Installs the latest Flash Player using the installer package stored on the disk image

4. After installation, unmounts the disk image and removes it from the Mac in question.

