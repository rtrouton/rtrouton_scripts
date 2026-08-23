This script imports a list of Jamf Pro ID numbers from a plaintext file and uses that information to generate a report about the matching computers' Recovery Lock passwords.

Usage: `/path/to/Generate_Recovery_Lock_Password_Report_From_Jamf_Pro_ID_Numbers.sh jamf_pro_id_numbers.txt`

Once the Jamf Pro ID numbers are read from in from the plaintext file, the script takes the following actions:

1. Uses the Jamf Pro API to download all information about the matching computer inventory record.
2. Pulls the following information out of the inventory entry:

*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID

3. Runs a separate API call to retrieve the following:

* Recovery Lock Password

4. Create a report in tab-separated value (.tsv) format which contains the following information
   about the computers.

*    Jamf Pro ID
*    Manufacturer
*    Model
*    Serial Number
*    Hardware UDID
*    Recovery Lock Password Available
*    Recovery Lock Password (if no password is set,`NA` is reported for the `Recovery Lock Password` column.)
*    Jamf Pro URL for the computer inventory record

| Jamf Pro ID Number | Make | Model | Serial Number | UDID | Recovery Lock Password Available | Recovery Lock Password | Jamf Pro URL |
| ------------------ | ---- | ----- | ------------- | ---- | -------------------------------- | ---------------------- | ------------ |
| 19 | Apple | MacBook Pro \(13-inch, M1, 2020\) | C02X25CTPSYN | 1B71C903-3BD7-441F-B063-4B49F232123A | No | NA | https://jamf.pro.server.here/computers.html?id=19 | 
| 55 | Apple | MacBook Pro \(14-inch, 2021\) | INU1GX7R3Y | F5F3E415-7A82-4A10-BF78-EAB6561670DA | No | NA | https://jamf.pro.server.here/computers.html?id=55 | 
| 72 | Apple | Mac mini \(2024\) | S8M1HLP3VW | 7D262319-3403-425E-AAF7-A5D6B62C31E0 | Yes | u+K0nrZVOvknZszakL9Rzg== | https://jamf.pro.server.here/computers.html?id=72 | 
| 93 | Apple | MacBook Pro \(14-inch, Nov 2023\) | WZ3B1JOPTT | FC3F10BA-ED5E-4F50-AD34-B70D04276984 | Yes | Qf7b5gXDBDjwyn0QLRQymA== | https://jamf.pro.server.here/computers.html?id=93 |



This script comes in two versions to support the following methods of API authentication:

* API client authentication -  see the `API_client_authentication` directory.
* User account authentication - see the `user_account_authentication` directory.

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

Jamf Pro Server Objects:

`Computers: Read`

Jamf Pro Server Actions:

`View Recovery Lock`


If setting up an API client with limited rights, here are the required API role privileges for the API client on the Jamf Pro server:

`Read Computers`

`View Recovery Lock`