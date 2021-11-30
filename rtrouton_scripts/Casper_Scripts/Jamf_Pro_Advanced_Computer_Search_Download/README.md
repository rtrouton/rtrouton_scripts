This script is designed to use the Jamf Pro API to identify the individual IDs of the computer extension attributes stored on a Jamf Pro server then do the following:

1. Back up existing downloaded advanced computer search directory
2. Download the advanced computer search as XML
3. Identify the advanced computer search name
4. Save the advanced computer search to a specified directory


If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Advanced Computer Searches: `Read`