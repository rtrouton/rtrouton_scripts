This script is designed to install Jamf's Jamf Infrastructure Manager (JIM)
onto the following OSs:

* CentOS 7.x
* Red Hat Enterprise Linux 7.x

Following installation, the JIM is enrolled with a specified Jamf Pro server, using credentials provided in the script. If the JIM hostname, Jamf Pro URL, the account username or the account password aren't available in the script, the script will prompt the user to enter the requested hostname, URL or account credentials.

**Note:** The hostname of the JIM server must resolve both for the machine 
hosting the JIM and for the remote Jamf Pro server, so there can’t be 
mismatches like having the JIM server itself think its hostname is 
`blahblah.int.company.com` and the remote Jamf Pro server think the JIM's
hostname is `blehbleh.ext.company.com`.

If necessary, set an entry into the `/etc/hosts` file on the
JIM server similar to what's shown below. That will allow the JIM server's
IP address to map to the hostname used for the JIM's hostname.

`ip.address.goes.here    blehbleh.ext.company.com`