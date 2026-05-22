This script connects to the Jamf Pro API on a Jamf Pro server and reports which API clients are assigned to which API client roles.

Usage: `/path/to/API_Client_Role_Reporting.sh`

1. Prompts for API client authentication as needed.
2. Uses the Jamf Pro API to download the relevant information regarding which API roles are assigned to which API clients.
3. Create a report in tab-separated value (`.tsv`) format which contains the following information about API clients and their associated API roles.

* Client Name
* Client ID
* Enabled / Disabled
* Assigned Role

4. Displays the information in the report.

The report which is generated should appear similar to what is shown below:


|Client Name|Client ID|Enabled|Assigned Role|
|---|---|---|---|
|ReadComputerSearches|3e8ca82c-b4c2-48f3-90fc-fcb637a6c845|false|Read Advanced Computer Searches|
|ReadMobileDevices|605c3677-7c46-46e9-9c91-10e99a7f296c|true|Read Mobile Devices|
|API_mapping|ab087cea-f1f3-4953-a452-21454713da5f|true|Read API Integrations and Roles|
|ReadComputers|5789b2e1-6f70-41b8-8ec2-65a478c53aef|true|Read Computers|


This script supports the following method of API authentication for Jamf Pro:

* API client authentication

If setting up an API client with limited rights, here are the required API role privileges for the API client on the Jamf Pro server:

* `Read API Integrations`
* `Read API Roles`
