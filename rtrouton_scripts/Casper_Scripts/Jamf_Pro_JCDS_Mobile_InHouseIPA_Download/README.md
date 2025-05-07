This script is designed to use the Jamf Pro Classic API and Jamf Pro API to download IPA files for in-house iOS apps from a JCDS 2 distribution point to a download directory.

This script comes in two versions to support the following methods of API authentication:

* API client authentication -  see the `API_client_authentication` directory.
* User account authentication - see the `user_account_authentication` directory.

Here are the required API privileges for the API client or user account on the Jamf Pro server:

API client permissions:

**Privileges:**

* `Read Mobile Device Apps`
* `Read Jamf Cloud Distribution Service Files`


User account permissions:

**Jamf Pro Server Objects:**

* Packages: `Read`
* Jamf Content Distribution Server Files: `Read`