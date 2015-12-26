This script will disable the display of the Message of the Day (**motd**) banner, which is  normally shown when opening a new Terminal window. For more information about this banner, please see the link below:

[https://kb.iu.edu/d/acdd](https://kb.iu.edu/d/acdd)

An payload-free package, which installs this script and an accompanying LaunchAgent to trigger it to run on login, is available from the **installer** directory.

When the installer is run, it installs the script and LaunchAgent in the following locations:

Script - `/Library/Scripts/hush_login.sh`

LaunchAgent - `/Library/LaunchAgents/com.github.hush_login.plist`