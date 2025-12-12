This script is designed to update the management status in the computer inventory record from `Managed` to `Not Managed` using the Jamf Pro API. Five items are required to use this script:

* Jamf Pro 10.49.0 or later
* A text file containing the Jamf Pro IDs of the computer(s) you wish to unmanage.
* The URL of the appropriate Jamf Pro server.
* The username of an account on the Jamf Pro server with sufficient privileges to set computers to `Not Managed`.
* The password for the relevant account on the Jamf Pro server.

Once the five specified items are available, the script can be run using the following command:

`/path/to/Set_Jamf_Pro_Computers_To_Unmanaged_Status.sh /path/to/text_filename_here.txt`

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

**Jamf Pro Server Objects**:

* **Computers**: `Read, Update`
* **Users**: `Update`

If setting up an API client with limited rights, here are the required API role privileges
for the API client on the Jamf Pro server:

* `Computers Read`
* `Computers Update`
* `Users Update`