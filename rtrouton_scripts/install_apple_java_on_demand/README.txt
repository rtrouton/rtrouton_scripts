For Mac OS X 10.7.x and higher, there's a way to override the install check that softwareupdate uses which is specific to Apple's Java updates. By setting the JAVA_INSTALL_ON_DEMAND environment variable for softwareupdate, you can force softwareupdate to install the latest Java update from Apple.

This script does the following:

1. Checks the current OS to see if the Mac is running Mac OS X 10.7.x or later. If not, the script will exit and display the following message:

Not supported on this version of Mac OS X

If the Mac is running 10.7.x or higher, the following actions occur

2. Checks the Java version and displays the results
3. Set the JAVA_INSTALL_ON_DEMAND environment variable
4. Uses the softwareupdate tool to check for and get the name of the latest Apple Java update for 10.7.x and 10.8.x
5. Installs the latest available Apple Java update for 10.7.x and 10.8.x
6. Checks the current Java version and displays the results

Original version of this script was posted by Michael Kuron to the MacEnterprise list:

http://tinyurl.com/m8fp4ou