This script sets the **Open** and **Save** options in Office 2016 apps to default to **On My Mac** instead of **Online Locations**, by running the following command with root privileges:

`/usr/bin/defaults write /Library/Preferences/com.microsoft.office DefaultsToLocalOpenSave -bool true`

This setting will apply to all users on this Mac. There is a payload-free package for running this script available from the **payload_free** directory.
