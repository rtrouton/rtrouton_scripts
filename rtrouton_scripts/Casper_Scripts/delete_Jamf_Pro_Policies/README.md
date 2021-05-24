This script is designed to delete policies from Jamf Pro using the Jamf Pro API. Four items are required to use this script:

* A text file containing the Jamf Pro IDs of the policies you wish to delete.
* The URL of the appropriate Jamf Pro server.
* The username of an account on the Jamf Pro server with sufficient privileges to delete policies from the Jamf Pro server.
* The password for the relevant account on the Jamf Pro server.

Once the four specified items are available, the script can be run using the following command:

`/path/to/delete_Jamf_Pro_Scripts.sh /path/to/text_filename_here.txt`