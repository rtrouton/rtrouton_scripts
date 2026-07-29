This script connects to the Jamf Pro API on a Jamf Pro server and creates a new Jamf Pro API Role which is then granted every available API privilege.

Usage: `/path/to/create_jamf_pro_api_role_with_all_available_privileges.sh`

1. Prompts for Jamf Pro user authentication as needed.
2. Uses the Jamf Pro API to create a new API role on a Jamf Pro server.
3. Assigns all available API privileges to that newly-created API role.
4. Displays information about the newly-created API role.

This script supports the following method of API authentication for Jamf Pro:

* Jamf Pro user account

**Note:** The Jamf Pro user account used for authentication must have the `Administrator` privileges set assigned to it.
