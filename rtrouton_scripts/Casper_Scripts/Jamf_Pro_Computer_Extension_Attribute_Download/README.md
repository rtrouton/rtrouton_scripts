This script is designed to use the Jamf Pro API to identify the individual IDs of the computer extension attributes stored on a Jamf Pro server then do the following:

1. Download the extension attribute as XML.
2. Identify the extension attribute name.
3. Categorize the downloaded extension attribute.
4. If it's a macOS or Windows extension attribute and it has a script, extract the script.
5. Save the extension attribute as `Extension Attribute Name Here` to a specified directory.


If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Computer Extension Attributes: `Read`