This script will download and install the Xcode command line tools on Macs running 10.7.x and higher. 

How the script works:

On 10.9.x and later:

1. Creates a placeholder file in /tmp. This file's existence is checked by the softwareupdate tool before allowing the installation of the Xcode command line tools.

2. Runs the softwareupdate tool and checks for the latest version of the Xcode command line tools for the OS in question.

3. Uses the softwareupdate tool to install the latest version of the Xcode command line tools for the OS in question.

4. Removes the placeholder file stored in /tmp.


On 10.7.x and 10.8.x:

1. Uses curl to download a disk image containing the specified Xcode Command Line Tools installer from Apple's web site

2. Renames the downloaded disk image to cltools.dmg.

2. Mounts the disk image silently in /tmp. Disk image will not be visible to any logged-in user.

3. Installs the Xcode Command Line Tools using the installer package stored on the disk image

4. After installation, unmounts the disk image and removes it from the Mac in question.


Note: This script should not be used in combination with a payload-free installer package. On 10.9.x and later, the softwareupdate tool will not work properly when called from within a payload-free package.


