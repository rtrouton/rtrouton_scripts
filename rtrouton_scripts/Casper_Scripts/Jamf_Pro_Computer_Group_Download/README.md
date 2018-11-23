This script is designed to use the Jamf Pro API to identify the individual IDs of the macOS smart and static groups stored on a Jamf Pro server then do the following:

1. Download the associated group information as XML
2. Properly format the downloaded XML
3. Identify the display name of the group.
4. Identify if it was a smart or static group.
5. Save the downloaded XML as `Group Name Here.xml` to a specified download directory, based on whether it was a smart or static group.

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Smart Computer Groups: `Read`
* Static Computer Groups: `Read`