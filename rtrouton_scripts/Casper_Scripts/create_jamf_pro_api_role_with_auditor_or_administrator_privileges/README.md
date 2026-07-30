This script connects to the Jamf Pro API on a Jamf Pro server and creates a new Jamf Pro API Role whose privileges approximate either the `Administrator` or `Auditor` account privilege sets available to Jamf Pro user accounts.

Usage: `/path/to/create_jamf_pro_api_role_with_auditor_or_administrator_privileges.sh`

1. Prompts for Jamf Pro API Client authentication as needed.
2. Uses the Jamf Pro API to retrieve the full catalog of available API Role privileges.
3. Prompts for the name of the new API role and whether it should approximate the `Administrator` (all available privileges) or `Auditor` (all `Read` privileges) privilege set.
4. Verifies that the API Client being used already holds every privilege it is about to assign to the new role.
5. Uses the Jamf Pro API to create the new API role with the selected privileges.
6. Displays information about the newly-created API role.

**Note:** `Administrator` and `Auditor` are this script's own approximation of the similarly-named Jamf Pro account privilege sets. API Roles have no built-in privilege sets of their own.

This script supports the following method of API authentication for Jamf Pro:

* API Client authentication

**Note:** The API Client used for authentication must already be assigned an API Role that includes every privilege being granted to the new role - either every available API Role privilege (for `Administrator`) or every `Read` privilege plus `Create API Roles` and `Update API Roles` (for `Auditor`). Jamf Pro will not allow an API Client to grant a role more privileges than the client itself already has.


