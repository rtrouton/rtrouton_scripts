This script will check the current Java 6 and Java 7 browser plug-in versions and compare them against the minimum version allowed by Apple's XProtect malware protection. 

The script is named xprotect_re-enable_java_6_and_7.sh and is put into /Library/Scripts along with a LaunchDaemon named com.company.xprotect_re-enable_java_6_and_7.plist that's put into /Library/LaunchDaemons. 

If the minimum Java version allowed by XProtect does not allow the current version of the Java browser plug-in on the Mac, the script will alter the Mac's /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist file to set the minimum version allowed to match the current version of the Mac's Java browser plug-in. This change allows the Mac's current Java browser plug-in to run in Safari without being blocked.

Permissions for the script and LaunchDaemon:

Change permissions on /Library/LaunchDaemons/com.company.xprotect_re-enable_java_6_and_7.plist to match the following:

Owner – root (r/w)
Group – wheel (r)
Everyone – (r)

Change permissions on /Library/Scripts/xprotect_re-enable_java_6_and_7.sh to match the following:

Owner – root (r/w/x)
Group – wheel (r/x)
Everyone – (r/x)
