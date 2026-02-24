This script imports a list of Jamf Pro ID numbers from a plaintext file 
and uses that information to generate a report about the matching computers.

Usage: `/path/to/Delete_Computers_From_Jamf_Pro.sh jamf_pro_id_numbers.txt`

The script can also accept one Jamf Pro ID number as input, if a plaintext file containing Jamf Pro ID numbers is not available.

Once the Jamf Pro ID numbers are read from in from the plaintext file, the script takes the following actions:

1. Uses the Jamf Pro API to download all information about the matching computer inventory record in XML format.
2. Pulls the following information out of the inventory entry:

*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID

3. Create a report in tab-separated value (.tsv) format which contains the following information about the computers being deleted.

*    Jamf Pro ID
*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID
*    Jamf Pro URL for the computer inventory record

4. Deletes the specified computers.

The report which is generated should appear similar to what is shown below:

```
Jamf Pro ID Number	Make	Model	Serial Number	UDID	Jamf Pro URL
56894	Apple	15-inch Retina MacBook Pro with TouchID (Mid 2017)	C0CD3782EBD12	BCD409C2-4716-4A6C-B317-9D59B2B67658	https://jamf.pro.server.here/computers.html?id=56894
98324	Apple	15-inch Retina MacBook Pro with TouchID (Mid 2017)	C060DC6F2C6D	4059B073-11D2-4DE1-A2C4-1B8B78D3D712	https://jamf.pro.server.here/computers.html?id=98324
```

This script comes in two versions to support the following methods of API authentication:

* API client authentication -  see the `API_client_authentication` directory.
* User account authentication - see the `user_account_authentication` directory.

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

Jamf Pro Server Objects:

`Computers: Read, Delete`

If setting up an API client with limited rights, here are the required API role privileges for the API client on the Jamf Pro server:

`Computers Read`
`Computers Delete`