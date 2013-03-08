This script will check the current Adobe Flash browser plug-in versions and compare them against the minimum version allowed by Apple's XProtect malware protection. 

The script is named xprotect_re-enable_adobe_flash.sh and is put into /Library/Scripts along with a LaunchDaemon named com.company.xprotect_re-enable_adobe_flash.plist that's put into /Library/LaunchDaemons. 

If the minimum Adobe Flash version allowed by XProtect does not allow the current version of the Adobe Flash browser plug-in on the Mac, the script will alter the Mac's /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist file to set the minimum version allowed to match the current version of the Mac's Adobe Flash browser plug-in. This change allows the Mac's current Adobe Flash browser plug-in to run in Safari without being blocked.

Credit for this script goes to scifiman:

https://github.com/scifiman

Original gist: https://gist.github.com/scifiman/5109047

Permissions for the script and LaunchDaemon:

Change permissions on /Library/LaunchDaemons/com.company.xprotect_re-enable_adobe_flash.plist to match the following:

Owner – root (r/w)
Group – wheel (r)
Everyone – (r)

Change permissions on /Library/Scripts/xprotect_re-enable_adobe_flash.sh to match the following:

Owner – root (r/w/x)
Group – wheel (r/x)
Everyone – (r/x)


