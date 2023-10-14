This script is designed to update the management status in the computer inventory record from `Unmanaged` to `Managed` using the Jamf Pro Classic API. Five items are required to use this script:

* Jamf Pro 10.49.0 or later
* A text file containing the Jamf Pro IDs of the computer(s) you wish to manage.
* The URL of the appropriate Jamf Pro server.
* The username of an account on the Jamf Pro server with sufficient privileges to set computers to `managed`.
* The password for the relevant account on the Jamf Pro server.

API rights required by account specified in the script's `jamfpro_user` variable:

**Jamf Pro Server Objects**:

* **Computers**: `Read, Update`
* **Users**: `Update`

Once the five specified items are available, the script can be run using the following command:

`/path/to/Set_Jamf_Pro_Computers_To_Managed_Status.sh /path/to/text_filename_here.txt`
