The script will set the "Enable applet plug-in and Web Start Applications" setting for Java in your Mac’s default user template.

You’ll need to use PlistBuddy to set this, and you’ll need to have the UUID of the machine, since this setting is stored in the user’s Library/Preferences/ByHost directory. This script will pull the UUID and use that to correctly name the file.