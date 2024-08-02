This script is designed to use the Jamf Pro API to identify the individual IDs of the buildings stored on a Jamf Pro server then do the following:

 1. Back up existing downloaded building directory
 2. Download the building as XML
 3. Identify the building name
 4. Save the building to a specified directory

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Buildings: `Read`