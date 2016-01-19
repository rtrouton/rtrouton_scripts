This script sets the **Open** and **Save** options in Office 2016 apps to default to **On My Mac** instead of **Online Locations**, by running the following command on both the user folders stored in **/Users** and in the default user template folders:

`/usr/bin/defaults write "/path/to/Library/Group Containers/UBF8T346G9.Office/"com.microsoft.officeprefs DefaultsToLocalOpenSave -bool true`

For the user folders stored in **/Users**, the  permissions on the affected file are re-set so that the file is owned by the user folder's owner rather than being owned by root.