This script connects to the Jamf Pro API and reports the privileges assigned to each Jamf Pro API Role, along with which API Client(s), if any, are assigned that role.

Usage: `/path/to/Generate_Jamf_Pro_API_Role_Privileges_Report.sh`

1. Prompts for API client authentication as needed.
2. Uses the Jamf Pro API to download the relevant information regarding which API roles are assigned to which API clients.
3. Create a report in tab-separated value (`.tsv`) format which contains the following information about API clients and their associated API roles.

* API Role Display Name
* API Role ID number
* API privileges assigned to the API Role
* API Client(s) assigned to each API Role and whether the API Client is enabled or disabled.

4. Displays the information in the report.

The report which is generated should appear similar to what is shown below:


| Role Name | Role ID | Privilege Name | Assigned API Clients |
| --- | --- | --- | --- |
| Create API Roles and Update API Roles | 28 | Create API Roles | 125ed256-21e1-42b6-bb77-afe3c917a940 (Disabled) |
| Create API Roles and Update API Roles | 28 | Update API Roles | 125ed256-21e1-42b6-bb77-afe3c917a940 (Disabled) |
| Read Computers API Role | 29 | Read Computers | 47da63c0-1386-4c55-851b-cc0098621f26 (Enabled) |
| Read API Roles and API Integrations | 30 | Read API Integrations | 88ab021a-6b2e-478e-ae57-7b2208664c7c (Enabled) |
| Read API Roles and API Integrations | 30 | Read API Roles | 88ab021a-6b2e-478e-ae57-7b2208664c7c (Enabled) |
| Create Computers API Role | 31 | Create Computers | (No API Client assigned) |



This script supports the following method of API authentication for Jamf Pro:

* API client authentication

If setting up an API client with limited rights, here are the required API role privileges for the API client on the Jamf Pro server:

* `Read API Integrations`
* `Read API Roles`
