This script will download a disk image containing the latest Adobe Flash Player and install Flash Player using the installer package stored inside the downloaded disk image. 

How the script works:

1. Uses `curl` to download a disk image containing the latest Flash Player installer from Adobe's web site

2. Renames the downloaded disk image to flash.dmg and stores it in `/tmp`

2. Mounts the disk image silently in `/tmp`. Disk image will not be visible to any logged-in user.

3. Installs the latest Flash Player using the installer package stored on the disk image

4. After installation, unmounts the disk image and removes it from the Mac in question.


This script is also available as a payload-free installer package, stored as a .zip file in the **payload\_free_installer** directory.

