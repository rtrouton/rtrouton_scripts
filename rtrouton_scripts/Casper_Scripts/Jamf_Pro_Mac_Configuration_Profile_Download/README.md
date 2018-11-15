This script is designed to use the Jamf Pro API to identify the individual IDs of 
the macOS configuration profiles stored on a Jamf Pro server then download, decode
and properly format the profiles as `.mobileconfig` files.

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

macOS Configuration Profiles: `Read`