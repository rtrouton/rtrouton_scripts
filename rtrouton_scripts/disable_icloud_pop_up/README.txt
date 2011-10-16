In 10.7.2, Apple set the iCloud sign-in to pop up on the first login. Since having this appear may not be desirable in all Mac environments, it makes sense to be able to turn this off for this user. Setting com.apple.SetupAssistant.plist in /System/Library/User\ Template/Non_localized/Library/Preferences/ to include the key DidSeeCloudSetup with a Boolean value of TRUE will stop the iCloud login from coming up for new users.

Hat tip to Mike Boylan and Allen Golbig for figuring out how to do this:

http://twitter.com/golby/status/124231769460453377 