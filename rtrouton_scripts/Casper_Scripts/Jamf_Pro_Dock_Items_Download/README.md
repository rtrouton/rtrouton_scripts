This script is designed to use the Jamf Pro API to identify the individual IDs of the dock items stored on a Jamf Pro server then do the following:

 1. Back up existing downloaded dock item directory
 2. Download the dock item as XML
 3. Identify the dock item name
 4. Save the dock item to a specified directory

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Dock Items: `Read`