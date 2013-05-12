First Boot Package Install is an installer package that enables other packages to be installed at first boot. It's designed for use with createOSXinstallPkg with the goal of allowing installer packages that can't run in the OS X Install environment to be incorporated into a createOSXinstallPkg-using deployment workflow.

Usage
------

1. Download the First_Boot_Package_Install.zip file from the "installer" directory.

2. Once downloaded and unzipped, right-click on the package and choose "Show Package Contents".

3. Go to Contents: Resources: fb_installers

4. Add one installer package to each numbered directory. The number of the directory indicates the install order, with 00 being the first. As needed, more numbered directories may be added. For numbers less than 9, make sure to label the directory with a leading zero (For example, 06).

NOTE: createOSXinstallPkg has an upper limit of 350 MBs of available space for added packages. This is sufficient space for basic configuration, payload-free or bootstrapping packages, but it's not a good idea to add Microsoft Office or similar large installers to this installer.

5. Once finished adding installers to the numbered directories, First Boot Package Install.pkg is ready to be added to a deployment workflow.


Operation
---------

When First Boot Package Install.pkg is installed via createOSXinstallPkg, it does the following:

1. Copies First Boot Package Install.pkg/Contents/Resources/fb_installers to /Users/Shared/fb_installers
2. Installs /Library/LaunchDaemons/com.company.firstbootpackageinstall.plist
3. Installs /var/firstbootpackageinstall.sh

After OS X is installed by createOSXinstallPkg and reboots, the following process occurs:

1. com.company.firstbootpackageinstall LaunchDaemon triggers /var/firstbootpackageinstall.sh to run. 
2. /var/firstbootpackageinstall.sh stops the login window from loading and checks for the existence of /Users/Shared/fb_installers.

If /Users/Shared/fb_installers is not found, the following actions take place:

A. The login window is allowed to load
B. /Library/LaunchDaemons/com.company.firstbootpackageinstall.plist is deleted
C. /var/firstbootpackageinstall.sh is deleted

If /Users/Shared/fb_installers is found, the following actions take place:

A. The packages are installed, using the numbered subdirectories to set the order of installation
B. Once installation has finished, /Users/Shared/fb_installers is deleted
C. The Mac is restarted
D. On restart, the "if /Users/Shared/fb_installers is not found" actions occur.


End Result
-----------

The installer package is designed to install packages in the desired order, then remove all traces. All actions occur before the OS X login window appears.


Components
-----------

If you want to modify the installer package for your own users, the components are included in the following directories:

Iceberg project files - Available in Iceberg_project_files as First_Boot_Package_Install.zip

LaunchDaemon - Available in launchd_items/LaunchDaemons as com.company.firstbootpackageinstall.plist

Scripts - Both the installer postflight and firstbootpackageinstall.sh are available in the following directories:

- Installer Postflight - Available in scripts/installer_postflight as postflight

- firstbootpackageinstall.sh - Available in scripts as firstbootpackageinstall.sh