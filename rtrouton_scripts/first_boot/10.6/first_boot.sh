#!/bin/sh

#
# Initial setup script for Mac OS X 10.6.x
# Rich Trouton, created September 18 2009
# Last modified 9-17-2010
#

# Delay the login window by three minutes to give all settings time to apply

defaults write /Library/Preferences/com.apple.loginwindow StartupDelay -int 180

# Sleeping for 10 seconds to allow the new default User Template folder to be moved into place

sleep 10

# Get the system's MAC address to set ByHost prefs
MACADD=`/sbin/ifconfig en0 | awk '/ether/ { gsub(":", ""); print $2 }'` 
#Primary Time server for Company Macs
TimeServer1=ns0.time.server
#Secondary Time server for Company Macs
TimeServer2=ns1.time.server
#Tertiary Time Server for Company Macs, used outside of Company network
TimeServer3=time.apple.com
# Time zone for Macs
TimeZone=America/New_York
#Default search domains
SearchDomains="searchdomain1.com searchdomain2.com searchdomain3.com"

# Set correct DNS search domains

/usr/sbin/networksetup -setsearchdomains "Built-in Ethernet" $SearchDomains
/usr/sbin/networksetup -setsearchdomains "Ethernet" $SearchDomains
/usr/sbin/networksetup -setsearchdomains "Ethernet 1" $SearchDomains
/usr/sbin/networksetup -setsearchdomains "Ethernet 2" $SearchDomains

# Enable secure virtual memory

defaults write /Library/Preferences/com.apple.virtualMemory UseEncryptedSwap -bool YES

# Disable Time Machine's pop-up message whenever an external drive is plugged in

defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Set default  screensaver settings
mkdir /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost

# Disabling screensaver password requirement by commenting out this line - can be re-enabled later.
#
# defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.${MACADD} "askForPassword" -int 1
#

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.${MACADD} "idleTime" -int 900

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.${MACADD} "moduleName" -string "Flurry"

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.${MACADD} "modulePath" -string "/System/Library/Screen Savers/Flurry.saver"

# Turn off DS_Store file creation on network volumes

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores true

# Turn off Keychain's built-in sync message on 10.6, using Keychain Minder instead

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.keychainaccess SyncLoginPassword -bool false

# Configure Finder to use Column View

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.finder "AlwaysOpenWindowsInColumnView" -bool true

# Configure network time server and region

# Set the time zone
/usr/sbin/systemsetup -settimezone $TimeZone

# Set the primary network server with systemsetup -setnetworktimeserver
# Using this command will clear /etc/ntp.conf of existing entries and
# add the primary time server as the first line.
/usr/sbin/systemsetup -setnetworktimeserver $TimeServer1

# Add the secondary time server as the second line in /etc/ntp.conf
echo "server $TimeServer2" >> /etc/ntp.conf 

# Add the tertiary time server as the third line in /etc/ntp.conf
echo "server $TimeServer3" >> /etc/ntp.conf

# Enables the Mac to set its clock using the network time server(s) 
/usr/sbin/systemsetup -setusingnetworktime on

# Disable root login by setting root's shell to /usr/bin/false

dscl . -create /Users/root UserShell /usr/bin/false

# The following are changes from the 10.5 initial setup script, to add customizations for 10.6.x
#
# Make a symbolic link from /System/Library/CoreServices/Directory Utility.app 
# to /Applications/Utilities so that Directory Utility.app is easier to access.

ln -s /System/Library/CoreServices/Directory\ Utility.app /Applications/Utilities/Directory\ Utility.app

# Set separate power management settings for desktops and laptops
# If it's a laptop, the power management settings for "Battery" are set to have the computer sleep in 15 minutes, disk will spin down 
# in 10 minutes, the display will sleep in 5 minutes and the display itslef will dim to half-brightness before sleeping. While plugged 
# into the AC adapter, the power management settings for "Charger" are set to have the computer never sleep, the disk doesn't spin down, 
# the display sleeps after 30 minutes and the display dims before sleeping.
# 
# If it's not a laptop (i.e. a desktop), the power management settings are set to have the computer never sleep, the disk doesn't spin down, the display 
# sleeps after 30 minutes and the display dims before sleeping.
#

# Detects if this Mac is a laptop or not by checking the model ID for the word "Book" in the name.
IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`

if [ "$IS_LAPTOP" != "" ]; then
	pmset -b sleep 15 disksleep 10 displaysleep 5 halfdim 1
	pmset -c sleep 0 disksleep 0 displaysleep 30 halfdim 1
else	
	pmset sleep 0 disksleep 0 displaysleep 30 halfdim 1
fi

# Set the login window to name and password

defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true

# Disable external accounts (i.e. accounts stored on drives other than the boot drive.)

defaults write /Library/Preferences/com.apple.loginwindow EnableExternalAccounts -bool false

# Turn SSH on

sudo systemsetup -setremotelogin on

# Remove the loginwindow delay

defaults delete /Library/Preferences/com.apple.loginwindow StartupDelay

# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.initialsetup.plist

# Make script self-destruct

rm -rf $0
