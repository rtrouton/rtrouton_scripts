This script is designed to be run on a Mac via a Jamf Pro policy to renew MDM profiles before their expiration date.

API rights required by account specified in the script's `jamfpro_user` variable:

**Jamf Pro Server Objects**:

**Computers**: `Read`

**Jamf Pro Server Actions**:

`Send Command to Renew MDM Profile`