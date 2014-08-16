This script will download a disk image containing the latest version of Java 7 from Oracle and install Java 7 using the installer package stored inside the downloaded disk image. 

How the script works:

1. Uses curl to download a disk image containing the latest Java 7 installer from Oracle's web site

2. Renames the downloaded disk image to java_seven.dmg and stores it in /tmp

3. Mounts the disk image silently in /tmp. The mounted disk image will not be visible to any logged-in user.

4. Installs the latest Java 7 using the installer package stored on the disk image

5. After installation, unmounts the disk image and removes it from the Mac in question.


This script is also available as a payload-free installer package, stored as a .zip file in the payload_free_installer directory.

