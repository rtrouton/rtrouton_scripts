This script imports a list of serial numbers from a plaintext file 
and uses that information to generate a report about the matching computers.

Usage: `/path/to/Generate_Mac_Report_From_Jamf_Pro_Serial_Numbers.sh serial_numbers.txt`

Once the serial numbers are read from in from the plaintext file, the script takes the following actions:

1. Uses the Jamf Pro API to download all information about the matching computer inventory record in XML format.
2. Pulls the following information out of the inventory entry:

*    Jamf Pro ID
*    Manufacturer
*    Model
*    Hardware UDID

3. Create a report in tab-separated value (.tsv) format which contains the following information
   about the computers.

*    Jamf Pro ID
*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID
*    Jamf Pro URL for the computer inventory record

This script comes in two versions to support the following methods of API authentication:

* API client authentication -  see the `API_client_authentication` directory.
* User account authentication - see the `user_account_authentication` directory.

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

Jamf Pro Server Objects:

`Computers: Read`

If setting up an API client with limited rights, here are the required API role privileges for the API client on the Jamf Pro server:

`Computers Read`