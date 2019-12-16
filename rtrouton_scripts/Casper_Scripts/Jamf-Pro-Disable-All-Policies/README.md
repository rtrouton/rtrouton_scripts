This script is designed to use the Jamf Pro API to identify the individual IDs of 
the computer policies stored on a Jamf Pro server then do the following:

* Disable the policy
* Display HTTP return code and API output

Successful policy disabling should produce output similar to that shown below:

`201	<?xml version="1.0" encoding="UTF-8"?><policy><id>1</id></policy>`

If setting up a specific user account with limited rights, here are the required API privileges for the account on the Jamf Pro server:

**Jamf Pro Server Objects**:

**Policies**: `Read`, `Update`