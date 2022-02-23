This script imports a list of Jamf Pro ID numbers from a plaintext file 
and uses that information to generate a report about the matching mobile devices.

Usage: `/path/to/Generate_Mobile_Device_Report_From_Jamf_Pro_ID_Numbers.sh jamf_pro_id_numbers.txt`

Once the Jamf Pro ID numbers are read from in from the plaintext file, the script takes the following actions:

1. Uses the Jamf Pro API to download all information about the matching mobile device inventory record in XML format.
2. Pulls the following information out of the inventory entry:

*    Model
*    Serial Number
*    Hardware UDID

3. Create a report in tab-separated value (.tsv) format which contains the following information
   about the mobile devices.

*    Jamf Pro ID
*    Model
*    Serial Number
*    Hardware UDID
*    Jamf Pro URL for the mobile device inventory record
