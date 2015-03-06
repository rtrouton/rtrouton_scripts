This script will download a disk image containing the latest version of Java 7 from Oracle and install Java 7 using the installer package stored inside the downloaded disk image. 

------

This script has been retired and should no longer be used to install Java 7. It uses Java 7's update feed to install the latest Java and Oracle has recently updated the feed to begin providing Java 8 to Java 7 users. For more information, see the link below:

http://www.oracle.com/technetwork/java/javase/documentation/autoupdatejre7tojre8-2389085.html

------

How the script works:

1. Uses curl to download a disk image containing the latest Java 7 installer from Oracle's web site

2. Renames the downloaded disk image to java_seven.dmg and stores it in /tmp

3. Mounts the disk image silently in /tmp. The mounted disk image will not be visible to any logged-in user.

4. Installs the latest Java 7 using the installer package stored on the disk image

5. After installation, unmounts the disk image and removes it from the Mac in question.


This script is also available as a payload-free installer package, stored as a .zip file in the payload_free_installer directory.

Accompanying blog post: http://derflounder.wordpress.com/2014/08/16/automating-oracle-java-7-updates/
