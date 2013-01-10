#!/bin/sh

# Convert plist to XML

/usr/bin/plutil -convert xml1 /Users/username/Library/Preferences/com.apple.sidebarlists.plist

# Search and replace in /Users/username/Library/Preferences/com.apple.sidebarlists.plist

/usr/bin/sed -i "" -e 's/smb:\/\/oldservername\/oldsharename/smb:\/\/newservername\/newsharename/g' /Users/username/Library/Preferences/com.apple.sidebarlists.plist

# Fix permissions on file

/usr/sbin/chown username /Users/username/Library/Preferences/com.apple.sidebarlists.plist

