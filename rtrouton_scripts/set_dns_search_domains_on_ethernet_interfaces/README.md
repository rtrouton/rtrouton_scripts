This script will set specified DNS search domains on a Mac's ethernet interfaces.

How the script works:

1. The script scans for and registers any network hardware that has not already registered.
2. All detected Ethernet interface names are read into an array
3. The script loops through the list of Ethernet network interfaces available on this Mac and sets the specified DNS search domains on each Ethernet network interface.

For the **SearchDomains** variable, change the search domains to be the ones you need and separate the search domains from each other by using spaces. For example, if you needed to set **verizon.com** and **comcast.com** as DNS search domains on Ethernet interfaces, the **SearchDomains** variable would be set like this:

`SearchDomains="verizon.com comcast.com"`