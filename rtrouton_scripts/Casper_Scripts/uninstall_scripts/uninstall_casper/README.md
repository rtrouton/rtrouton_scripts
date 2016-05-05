There may be certain instances where the Casper agent has failed on a Mac, where the fix is to uninstall and reinstall the Casper agent. [JAMF Software h​as provided directions on how to uninstall the Mac agent](https://jamfnation.jamfsoftware.com/article.html?id=153)​, where the following command needs to be run with root privileges in Terminal:

`jamf removeFramework`

I've written a script to run this command, along with a payload-free installer package to run this command. The payload-free package is available for download in the **payload_free** directory.