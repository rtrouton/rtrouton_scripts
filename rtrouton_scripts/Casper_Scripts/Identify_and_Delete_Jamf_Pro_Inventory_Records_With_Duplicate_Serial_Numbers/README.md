This script downloads all computer inventory records from a Jamf Pro server. The list of records is then parsed for inventory records with the same Apple serial number as at least one other record.

Once the duplicate serial numbers are identified, the script takes the following actions:

1. Loop through the duplicate serial number list and get all of the associated Jamf Pro computer IDs
2. Loop through the Jamf Pro IDs and identify the IDs with the most recent enrollment dates.
3. Verify that the individual Jamf Pro IDs are associated with Macs, as opposed to virtual machines running macOS.
4. Loop through the list of identified Macs with Jamf Pro IDs and delete all Macs except for the one with the most recent enrollment date.
5. Create a report in tab-separated value (.tsv) format which contains the following information about the deleted Macs:

    ```
    Jamf Pro ID
    Manufacturer
    Model
    Serial Number
    Hardware UDID
    ```