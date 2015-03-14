This script will download a disk image containing the latest version of Java 8 from Oracle and install Java 8 using the installer package stored inside the downloaded disk image. 

How the script works:

1. Uses curl to download a disk image containing the latest Java 8 installer from Oracle's web site

2. Renames the downloaded disk image to java_eight.dmg and stores it in /tmp

3. Mounts the disk image silently in /tmp. The mounted disk image will not be visible to any logged-in user.

4. Installs the latest Java 8 using the installer package stored inside the disk image. 

Note: This installer may be stored inside an install application on the disk image, or there may be an installer package available at the root of the mounted disk image. 

5. After installation, unmounts the disk image and removes it from the Mac in question.


This script is also available as a payload-free installer package, stored as a .zip file in the payload_free_installer directory.

Accompanying blog post: http://derflounder.wordpress.com/2014/08/17/automating-oracle-java-8-updates/
