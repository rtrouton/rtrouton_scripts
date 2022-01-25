This script is designed to delete installer packages from Jamf Pro using the Jamf Pro Classic API. Four items are required to use this script:

* A text file containing the Jamf Pro IDs of the installer package(s) you wish to delete.
* The URL of the appropriate Jamf Pro server.
* The username of an account on the Jamf Pro server with sufficient privileges to delete installer packages from the Jamf Pro server.
* The password for the relevant account on the Jamf Pro server.

Once the four specified items are available, the script can be run using the following command:

`/path/to/delete_Jamf_Pro_Packages.sh /path/to/text_filename_here.txt`
