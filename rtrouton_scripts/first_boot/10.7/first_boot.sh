#!/bin/sh

#
# Initial setup script for Mac OS X 10.7.x
# Rich Trouton, created July 31, 2011
# Last modified 7-3-2012
#
# Adapted from Initial setup script for Mac OS X 10.6.x
# Rich Trouton, created September 18 2009
# Last modified 9-17-2010
#
#

# Delay the 10.7 login window by unloading the com.apple.loginwindow
# LaunchDaemon in /System/Library/LaunchDaemons/

launchctl unload /System/Library/LaunchDaemons/com.apple.loginwindow.plist

# Sleeping for 30 seconds to allow the new default User Template folder to be moved into place

sleep 30

# Get the system's UUID to set ByHost prefs
MAC_UUID=$(system_profiler SPHardwareDataType | awk -F" " '/UUID/{print $3}')
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
/usr/sbin/networksetup -setsearchdomains "Thunderbolt Ethernet" $SearchDomains
/usr/sbin/networksetup -setsearchdomains "USB Ethernet" $SearchDomains

# Enable secure virtual memory                                  
#
# This setting no longer needed in 10.7 as secure virtual memory
# is now on by default. To check status, open System Profiler. 
# The Secure Virtual Memory status is listed as part of the System
# Software Overview.
# 
# defaults write /Library/Preferences/com.apple.virtualMemory UseEncryptedSwap -bool YES
#

# Disable Time Machine's pop-up message whenever an external drive is plugged in

defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# Set default  screensaver settings
mkdir /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost

# Disabling screensaver password requirement by commenting out this line - can be re-enabled later.
#
# defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "askForPassword" -int 1
#

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "idleTime" -int 900

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "moduleName" -string "Flurry"

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/ByHost/com.apple.screensaver.$MAC_UUID "modulePath" -string "/System/Library/Screen Savers/Flurry.saver"

# Turn off DS_Store file creation on network volumes

defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.desktopservices DSDontWriteNetworkStores true

# Disabling the turn-off of Keychain's built-in sync message on 10.7 by commenting out this line - can be re-enabled later.
#
# Turn off Keychain's built-in sync message on 10.6, using Keychain Minder instead
# 
# defaults write /System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.keychainaccess SyncLoginPassword -bool false

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

# The following are changes from the 10.6 initial setup script, to add customizations for 10.7.x
# 
# Set the ability to  view additional system info at the Login window
# The following will be reported when you click on the time display 
# (click on the time again to proceed to the next item):
#
# Computer name
# Version of OS X installed
# IP address
# This will remain visible for 60 seconds.

defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

# Sets the "Show scroll bars" setting (in System Preferences: General)
# to "Always" in your Mac's default user template and for all existing users.
# Code adapted from DeployStudio's rc130 ds_finalize script, where it's 
# disabling the iCloud and gestures demos

# Checks the system default user template for the presence of 
# the Library/Preferences directory. If the directory is not found, 
# it is created and then the "Show scroll bars" setting (in System 
# Preferences: General) is set to "Always".

for USER_TEMPLATE in "/System/Library/User Template"/*
  do
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences
     fi
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences/ByHost
     fi
     if [ -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        defaults write "${USER_TEMPLATE}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
     fi
  done

# Checks the existing user folders in /Users for the presence of
# the Library/Preferences directory. If the directory is not found, 
# it is created and then the "Show scroll bars" setting (in System 
# Preferences: General) is set to "Always".

for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
     then 
      if [ ! -d "${USER_HOME}"/Library/Preferences ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ ! -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences/ByHost
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
	chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost
      fi
      if [ -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        defaults write "${USER_HOME}"/Library/Preferences/.GlobalPreferences AppleShowScrollBars -string Always
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/.GlobalPreferences.*
      fi
    fi
  done

# Set the the "Enable applet plug-in and Web Start Applications" setting for Java in your Mac's default user template and for all existing users.
# Code adapted from DeployStudio's rc130 ds_finalize script, where it's disabling the iCloud and gestures demos

# Checks the system default user template for the presence of 
# the Library/Preferences and Library/Preferences/ByHost directories.
# If the directories are not found, they are created and then the
# "Enable applet plug-in and Web Start Applications" setting for Java
# setting is enabled.

for USER_TEMPLATE in "/System/Library/User Template"/*
  do
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences
     fi
     if [ ! -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        mkdir -p "${USER_TEMPLATE}"/Library/Preferences/ByHost
     fi
     if [ -d "${USER_TEMPLATE}"/Library/Preferences/ByHost ]
      then
        defaults write "${USER_TEMPLATE}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID} '{ GeneralByTask = { Any = { PrefsVersion = 2; WebComponentsEnabled = true;};};}'
     fi
  done

# Checks the existing user folders in /Users for the presence of 
# the Library/Preferences and Library/Preferences/ByHost directories.
# If the directories are not found, they are created and then the
# "Enable applet plug-in and Web Start Applications" setting for Java
# setting is enabled.

for USER_HOME in /Users/*
  do
    USER_UID=`basename "${USER_HOME}"`
    if [ ! "${USER_UID}" = "Shared" ] 
     then 
      if [ ! -d "${USER_HOME}"/Library/Preferences ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
      fi
      if [ ! -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        mkdir -p "${USER_HOME}"/Library/Preferences/ByHost
        chown "${USER_UID}" "${USER_HOME}"/Library
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences
	chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost
      fi
      if [ -d "${USER_HOME}"/Library/Preferences/ByHost ]
       then
        defaults write "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID} '{ GeneralByTask = { Any = { PrefsVersion = 2; WebComponentsEnabled = true;};};}'
        chown "${USER_UID}" "${USER_HOME}"/Library/Preferences/ByHost/com.apple.java.JavaPreferences.${MAC_UUID}.*
      fi
    fi
  done

# Disables iCloud pop-up on first login for Macs running 10.7.2 or higher

defaults write /System/Library/User\ Template/Non_localized/Library/Preferences/com.apple.SetupAssistant DidSeeCloudSetup -bool TRUE

# Turn SSH on

sudo systemsetup -setremotelogin on

# Remove the loginwindow delay by loading the com.apple.loginwindow   
# LaunchDaemon in /System/Library/LaunchDaemons/

launchctl load /System/Library/LaunchDaemons/com.apple.loginwindow.plist

# Remove setup LaunchDaemon item

rm -rf /Library/LaunchDaemons/com.company.initialsetup.plist

# Make script self-destruct

rm -rf $0
