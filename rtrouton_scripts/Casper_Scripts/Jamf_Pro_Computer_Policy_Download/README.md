This script is designed to use the Jamf Pro API to identify the individual IDs of the macOS policies stored on a Jamf Pro server then do the following:

1. If any policies were previously downloaded, back up existing downloaded policies into a `.zip` file
2. Download the policy information as XML
2. Properly format the downloaded XML
3. Identify the display name of the policy.
4. Identify the category of the policy.
5. Save the downloaded XML as `Policy Name Here.xml` to a specified download directory, based on the category that the policy is in.

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Policies: `Read`