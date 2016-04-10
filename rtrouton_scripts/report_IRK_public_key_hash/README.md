This script is designed to report the hash of the institutional recovery key's public key.

The script first checks the OS on a particular Mac and verify that it's running 10.11.2 or later. If the Mac is running an earlier OS, the script reports the following:

**Not Available - Unable To Export IRK Public Key Hash On**, followed by the OS version.

If the script verifies that it is running on 10.11.2 or later, the script continues on to see if the Mac is encrypted and if it is using an institutional recovery key as a valid recovery key.

If the Mac is not encrypted, the script reports the following:

**Not Available - Encryption Not Enabled** 

If the Mac is encrypted but is not using an institutional recovery key, the script reports the following:

**Not Available - Valid IRK Not Found**

If the Mac is encrypted and an institutional recovery key is in use as a valid recovery key on the Mac's boot volume, the script reports the SHA-1 hash of the institutional recovery key's public key in hexadecimal notation.