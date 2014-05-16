One side effect of the iTunes 11.2 update on Thursday, May 15th 2014 has been that some but not all Macs were seeing the /Users and /Users/Shared folders disappear. The permissions on the /Users folder were also changed to be world-writable, so that anyone could read and write to the /Users folder.

After considerable investigation, it looks like the issue has been tied to two causes:

1. iTunes 11.2 being installed
2. iCloud's Find My Mac being enabled. 

The 10.9.3 update by itself does not seem to be the root cause, as the behavior has also been reproduced on 10.9.2 with iTunes 11.2 and Find My Mac enabled.

To fix this issue if you're seeing it:

1. Open System Preferences
2. Open the iCloud preference pane
3. Check if Find My Mac is enabled
4. If Find My Mac is enabled, uncheck it to disable it.
5. Run the unhide_users_and_fix_permissions.sh script found in this directory.


What the unhide_users_and_fix_permissions.sh script does is look for the /Users and /Users/Shared directory. If found, the directories are unhidden. A permissions repair is then run using the diskutil command to fix the world-writable permission issue for the /Users directory.

Note: The permissions repair may take up to 10 minutes to run.

It is important that Find My Mac be disabled before the permissions fix and also that Find My Mac remain disabled. If Find My Mac is re-enabled, the /Users and /Users/Shared folder will disappear again and /Users will revert to being world-writable.

To help automate running this script, a payload-free package containing this script is available in the payload_free_package directory
