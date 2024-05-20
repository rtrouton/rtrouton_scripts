This script is designed to use the Jamf Pro API to identify the individual IDs of the webhooks stored on a Jamf Pro server then do the following:

1. Back up existing downloaded webhook directory
2. Download the webhook as XML
3. Identify the webhook name
4. Save the webhook to a specified directory

If setting up a specific user account with limited rights, here are the required API privileges
for the account on the Jamf Pro server:

**Jamf Pro Server Objects:**

* Webhooks: `Read`