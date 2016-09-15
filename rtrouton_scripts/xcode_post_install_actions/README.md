This script is designed to accept the Xcode EULA and install the following installer packages embedded inside Xcode:

* MobileDevice.pkg
* MobileDeviceDevelopment.pkg
* XcodeSystemResources.pkg 

These actions ensure that the user is not prompted to either accept the license or install anything when launching Xcode for the first time.


This script is also available as a payload-free installer package, stored as a .zip file in the **payload_free_installer** directory.