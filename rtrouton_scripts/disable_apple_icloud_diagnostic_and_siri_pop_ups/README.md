Starting in 10.7.2, Apple set the iCloud sign-in to pop up on the first login. In 10.10, Apple added a new Diagnostic window that pops up at first login after the iCloud sign-in. In 10.12, Apple added another new pop-up window for Siri. 

Since having this appear may not be desirable in all Mac environments, it makes sense to be able to turn the the iCloud, Diagnostic and Siri pop-up windows off for new user accounts. 

Apple is using `~/Library/Preferences/com.apple.SetupAssistant.plist` to store the settings that indicate whether or not the iCloud, Diagnostic and Siri agreement processes have run. Building on work done by the folks behind DeployStudio, I've built a script that pre-sets those values for new and existing accounts on a particular Mac. In turn, that should stop the iCloud, Diagnostic and Siri pop-up messages from appearing on that Mac.

This script is also available as a payload-free package, available for download from the **payload_free_package** directory.
