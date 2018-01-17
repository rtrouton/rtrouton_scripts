This script will download a disk image containing the latest version of the Java 9 Java Development Kit (JDK) from Oracle and installs the JDK using the installer package stored inside the downloaded disk image.

By default, the script will install the Java 9 JDK CPU release. The difference between CPU and PSU releases is as follows:

* Critical Patch Update (CPU): contains both fixes to security vulnerabilities and critical bug fixes.
* Patch Set Update (PSU): contains all the fixes in the corresponding CPU, plus additional fixes to non-critical problems. 

For more details on the differences between CPU and PSU updates, please see the link below:

[http://www.oracle.com/technetwork/java/javase/cpu-psu-explained-2331472.html](http://www.oracle.com/technetwork/java/javase/cpu-psu-explained-2331472.html)



How the script works:

1. Uses `curl` to download a disk image containing the latest Java 9 JDK installer from Oracle's web site

2. Renames the downloaded disk image to `java_nine_jdk.dmg` and stores it in `/tmp`

3. Mounts the disk image silently in `/tmp`. The mounted disk image will not be visible to any logged-in user.

4. Installs the latest Java 9 JDK using the installer package stored inside the disk image. 

5. After installation, unmounts the disk image and removes it from the Mac in question.


This script is also available as two separate payload-free installer packages, compressed and stored as **.zip** files in the `payload_free_package` directory:

`payload_free_package/install_latest_oracle_java_jdk_9_cpu_version` - Installs the latest Oracle Java JDK 9 CPU version

`payload_free_package/install_latest_oracle_java_jdk_9_psu_version` - Installs the latest Oracle Java JDK 9 PSU version
