This script is designed to report if the current logged-in user has a Secure Token attribute associated with their account. It checks for the following:

1. If the Mac is running 10.13.x or later.
2. If the boot drive is using Apple File System (APFS) for its filesystem.
3. If FileVault is enabled or not.

If the Mac passes the following checks:

* Running 10.13.0 or later
* The boot drive is using APFS
* FileVault is enabled

Then the following actions take place:

1. The logged-in user is checked to see if it can be determined.
2. If the logged-in user can be determined and it is not the `root` user, the `sysadminctl` tool is used to check to see if the account has the Secure Token attribute associated with it.

If the logged-in user account should have a Secure Token attribute associated with it and does not, the script will report the following:

`1` 

Any other outcome, the script will report the following:

`0`