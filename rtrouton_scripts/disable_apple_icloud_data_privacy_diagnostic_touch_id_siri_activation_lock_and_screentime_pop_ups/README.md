Starting in 10.7.2, Apple has added several pop-up windows which appear at the first login of a new account:

* Mac OS X 10.7.2: iCloud sign-in window
* OS X 10.10: Diagnostic agreement window
* macOS 10.12: Siri setup window
* macOS 10.13.0: Touch ID Setup window
* macOS 10.13.4: Data & Privacy information window
* macOS 10.14.0: Dark or Light Appearance window
* macOS 10.15.0: Activation Lock window
* macOS 10.15.0: Screentime window

Since having this appear may not be desirable in all Mac environments, it makes sense to be able to turn these pop-up windows off for new user accounts. 

Apple is using `~/Library/Preferences/com.apple.SetupAssistant.plist` to store the settings that indicate whether or not the various agreement processes have run. Building on work done by the folks behind DeployStudio, I've built a script that pre-sets those values for new and existing accounts on a particular Mac. In turn, that should stop the various pop-up messages from appearing on that Mac.

This script is also available as a payload-free package, available for download from the `payload_free_package` directory.
