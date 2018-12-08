This script is designed to use the Jamf Pro API to identify the individual IDs of the macOS scripts stored on a Jamf Pro server then do the following:

1. Use the Jamf Pro API to identify the Jamf Pro ID numbers of the scripts.
2. Download each script using its Jamf Pro ID number as raw XML.
3. Format the downloaded XML
4. Identify the display name of the script
5. Extract the script from the downloaded XML
6. Save the script as `Display Name Goes Here` to a specified download directory.

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Scripts: `Read`