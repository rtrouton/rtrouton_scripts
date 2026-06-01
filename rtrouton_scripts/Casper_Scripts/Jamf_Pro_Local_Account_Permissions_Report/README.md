This script connects to the Jamf Pro Classic API on a Jamf Pro server and reports which Jamf Pro user accounts have which permissions assigned, along with how those permissions are assigned (direct assignment to the user account, or via membership in a user group.)

Usage: `/path/to/Jamf_Pro_Local_Account_Permissions_Report.sh`

1. Prompts for API client authentication as needed.
2. Uses the Jamf Pro Classic API to download the relevant information regarding which permissions are assigned to which Jamf Pro user clients.
3. Create a report in tab-separated value (`.tsv`) format which contains the following information about Jamf Pro user accounts and their associated permissions.

* Account Name
* Account ID
* Enabled / Disabled
* Privilege Category
* Privilege Name
* Assignment Type

4. Displays the information in the report.

The report which is generated should appear similar to what is shown below:


|Account Name|Account ID|Account Enabled|Privilege Category|Privilege Name|Assignment Type|
|---|---|---|---|---|---|
|computer_deletion_service_account|6|Enabled|Jamf Pro Server Objects|Read Computers|Permission assigned directly to account|
|computer_deletion_service_account|6|Enabled|Jamf Pro Server Objects|Delete Computers|Permission assigned directly to account|
|computer_deletion_service_account|6|Enabled|Jamf Pro Server Settings|Read Activation Code|Permission assigned directly to account|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Create Mobile Device Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Read Mobile Device Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Update Mobile Device Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Delete Mobile Device Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Create Computer Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Read Computer Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Update Computer Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Delete Computer Enrollment Invitations|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Create Computers|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Read Computers|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Create User|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Read User|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Update User|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Create Mobile Devices|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Read Mobile Devices|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Create Enrollment Profiles|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Read Enrollment Profiles|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Update Enrollment Profiles|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Objects|Delete Enrollment Profiles|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Settings|Read Activation Code|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Actions|Allow User to Enroll|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Actions|Assign Users to Computers|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Actions|Assign Users to Mobile Devices|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Actions|Enroll Computers|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|
|jamfpro-enroll|2|Enabled|Jamf Pro Server Actions|Enroll Mobile Devices|Permission assigned via membership in Jamf Pro group: Enrollment Permissions Group|


This script supports the following method of API authentication for Jamf Pro:

* API client authentication

If setting up an API client with limited rights, here are the required API role privileges for the API client on the Jamf Pro server:

* `Read Accounts`
