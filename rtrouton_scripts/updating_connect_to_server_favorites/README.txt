This script will convert com.apple.sidebarlists.plist to XML using plutil, then use sed to find and replace one smb:// address with another. The work is being done by the root account, so the permissions are fixed by a chown command once the sed command has finished.

As written, the script does a find and replace as follows:

Find: smb://oldserver/oldsharename 
Replace with: smb://newserver/newsharename

