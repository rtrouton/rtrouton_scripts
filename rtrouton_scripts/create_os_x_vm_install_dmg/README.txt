This script prepares customized OS X installer disk images for use with VMware Fusion and ESXi. It's adapted from the prepare_iso script created by Tim Sutton: https://github.com/timsutton/osx-vm-templates/tree/master/prepare_iso

Running the script: 

Run the create_vmware_osx_install_dmg.sh script with two arguments: the path to an "Install OS X.app" or the InstallESD.dmg contained within, and an output directory. 

Example usage: 

If you have a 10.9.x Mavericks installer available, run this command:

sudo /path/to/create_vmware_osx_install_dmg.sh "/Applications/Install OS X Mavericks.app" /path/to/output_directory

This should produce a DMG file at output_directory that's named OSX_InstallESD_10.9_13A598.dmg. An MD5 checksum is printed at the end of the process.

What the script does:

1. Mounts the InstallESD.dmg using a shadow file, so the original DMG is left
   unchanged.
2. minstallconfig.xml and PartitionInfo.plist are also copied, which is looked for by the installer environment's 
   rc.* files that first load with the system. This allows us to never actually modify the 
   BaseSystem.dmg and only drop in these extra files.
3. Additional installer packages can be added using First Boot Package Install.pkg, 
   which is added to the OS X install by way of the OSInstall.collection file. The instructions
   on how to use this package are documented here: 
   https://github.com/rtrouton/First-Boot-Package-Install
4. If desired, a second disk image in .iso format can be generated for use with VMware ESXi
   servers running on Apple hardware. The .iso file will also be stored in the output directory.


Once you have the customized DMG file created, you can choose it as an install disk image in VMware Fusion when creating virtual machines in VMware Fusion.

This script has been tested with Apple's 10.7.5, 10.8.5 and 10.9.4 installers from the Mac App Store.

Necessary parts: This script and the associated support directory. This script and the support directory must be both stored in the same directory in order for the script to work properly.


NOTES: 

1. First Boot Package Install.pkg is stored in the support directory as a zip file named First_Boot_Package_Install.zip. Unzip the file before running the script.


2. The disk images created with this method will not install a recovery partition. As a workaround, it appears that this can be addressed via using Per Olafsson’s Create Recovery Partition Installer to generate an installer that can install the missing recovery partition:

Create Recovery Partition Installer is available from here on GitHub:
https://github.com/MagerValp/Create-Recovery-Partition-Installer

Unfortunately, that installer would be too large to include as part of First Boot Package Install’s payload (available space is around 350 MBs, the Recovery Partition installer is around 485 MBs.)