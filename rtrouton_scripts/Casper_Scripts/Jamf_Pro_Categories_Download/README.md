This script is designed to use the Jamf Pro API to identify the individual IDs of the categories stored on a Jamf Pro server then do the following:

 1. Back up existing downloaded category directory
 2. Download the category as XML
 3. Identify the category name
 4. Save the category to a specified directory

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Categories: `Read`