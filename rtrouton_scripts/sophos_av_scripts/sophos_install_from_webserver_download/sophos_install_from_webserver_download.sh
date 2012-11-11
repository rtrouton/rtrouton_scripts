#!/bin/sh

# Checks for Sophos Antivirus uninstaller package.
# If present, uninstall process is run

if [ -d "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
     /usr/sbin/installer -pkg "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target /
elif [ -d "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
     /usr/sbin/installer -pkg "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target /    
else
   echo "Sophos Antivirus Uninstaller Not Present"
fi

# Stops the Sophos menu bar process. Sophos icon will disappear.

killall SophosUIServer


# Make a working directory, after checking for and removing any leftover instances from a broken install

if [ -d /private/tmp/sophos/ ]; then
	rm -r /private/tmp/sophos/
	mkdir /private/tmp/sophos/
	logger "Sophos install temp directory created after removing old directory"
else
	mkdir /private/tmp/sophos/
	logger "Sophos install temp directory created"
fi

# Download tar'd Sophos installer files from web server
# to /private/tmp/sophos/ working directory

curl http://server.name.here/sophos/sophos.tgz > /private/tmp/sophos/sophos.tgz

# Decompress tar file

cd /private/tmp/sophos/
tar -zxvf sophos.tgz

# Install Sophos using the Sophos Anti-Virus metapackage stored inside /private/tmp/sophos/ESCOSX

cd /private/tmp/sophos/ESCOSX
installer -dumplog -verbose -pkg /private/tmp/sophos/ESCOSX/Sophos\ Anti-Virus.mpkg -target /

# Write configuration file
# Note: Plist file here is only an example. You will
# need to provide your own plist settings between the
# following lines:
#
# /bin/cat > "/Library/Sophos Anti-Virus/com.sophos.sau.plist" << 'SOPHOS_CONFIG'
#
# ....plist data goes here....
#
# SOPHOS_CONFIG
#

/bin/cat > "/Library/Sophos Anti-Virus/com.sophos.sau.plist" << 'SOPHOS_CONFIG'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>PrimaryServerPassword</key>
	<string>iQEHHMzvIdHYUwBJDp01cT3r16od4NZ</string>
	<key>PrimaryServerProxy</key>
	<integer>0</integer>
	<key>PrimaryServerProxyPassword</key>
	<string>AAA=</string>
	<key>PrimaryServerProxyPort</key>
	<integer>0</integer>
	<key>PrimaryServerProxyURL</key>
	<string></string>
	<key>PrimaryServerProxyUserName</key>
	<string>AAA=</string>
	<key>PrimaryServerType</key>
	<integer>2</integer>
	<key>PrimaryServerURL</key>
	<string>smb://server.name.here/SophosUpdate/CIDs/S000/ESCOSX</string>
	<key>PrimaryServerUserName</key>
	<string>oZjoEEiGKwXEg0conDHVQpqFLOXIrAT</string>
	<key>SecondaryServer</key>
	<true/>
	<key>SecondaryServerPassword</key>
	<string>V62NQG3gbqY5CPKSa5VT4TmFA0TOGhj</string>
	<key>SecondaryServerProxy</key>
	<integer>0</integer>
	<key>SecondaryServerProxyPassword</key>
	<string>AAA=</string>
	<key>SecondaryServerProxyPort</key>
	<integer>0</integer>
	<key>SecondaryServerProxyURL</key>
	<string></string>
	<key>SecondaryServerProxyUserName</key>
	<string>AAA=</string>
	<key>SecondaryServerType</key>
	<integer>0</integer>
	<key>SecondaryServerURL</key>
	<string></string>
	<key>SecondaryServerUserName</key>
	<string>a4yKGgTvRuB6vdDLpIp0igr4NVzNA73</string>
	<key>UpdateInterval</key>
	<integer>10</integer>
	<key>UpdateLogIntoFile</key>
	<true/>
	<key>UpdateOnConnection</key>
	<false/>
</dict>
</plist>
SOPHOS_CONFIG

# Restart SophosAutoUpdate to force the Sophos AutoUpdate process
# to read the settings stored in /Library/Sophos Anti-Virus/com.sophos.sau.plist

killall -HUP SophosAutoUpdate

# Cleanup

cd /
rm -rf /private/tmp/sophos

exit 0

