This Casper Extension Attribute determines if Sophos Anti-Virus is installed and then checks for to see if it is managed by a Sophos enterprise management or update server. 

If Sophos Anti-Virus is installed, the script checks to see if there is a com.sophos.sau.plist file in either the usual or alternate locations. If a file is located, the PrimaryServerURL key is read from the plist to determine the Sophos enterprise management or update server's address. In this case, the script will return a result displaying the update server's address.

If reading the PrimaryServerURL key returns a blank result, the Sophos Anti-Virus client is not configured to receive updates from a Sophos enterprise management or  update server. In this case, the script will return a result of "Sophos Anti-Virus Not Managed"

If Sophos Anti-Virus is not installed, the script will return a result of "Sophos Anti-Virus Not Installed"

See "Casper_Extension_Attribute_Setup.png" for a screenshot of how the Extension Attribute should be configured.