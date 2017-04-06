This script will download and install the latest version of Parallels Tools.

***Essential Pre-requisite:***

*Xcode or the Xcode command line tools* **must** *be installed and licensed inside the OS X VM before running this script.*

How the script works:

1. Downloads [AutoPkg](https://github.com/autopkg/autopkg) from GitHub using git.
2. Adds the AutoPkg recipe repo containing the ParallelsTools .download and .pkg recipes
3. Redirects the AutoPkg cache to a temp location.
4. Downloads the current release version of Parallels Tools for OS X and extracts the installer package.
5. Installs the latest Parallels Tools using the AutoPkg-generated installer package.

**Post-installation**

  
Once installed, the VM where Parallels Tools has been installed must be restarted in order to activate Tools' functionality.

This script is also available as a payload-free installer package, stored as a .zip file in the **payload_free_installer** directory.