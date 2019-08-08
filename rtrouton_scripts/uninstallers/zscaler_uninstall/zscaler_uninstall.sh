#!/bin/bash

# This script uninstalls Zscaler software using the
# uninstall process provided by Zscaler:
#
# https://help.zscaler.com/z-app/uninstalling-zscaler-app
# 
# This script would use the Zscaler-provided uninstall script to remove the Zscaler app 
# components by preference, with a fallback removal process if the Zscaler-provided 
# uninstall script is unavailable.
#
# The script runs the following actions:
#
# 1. Verifies if the Zscaler software is installed.
# 2. Verifies if the Zscaler-provided uninstall script is available.
#
# If the  Zscaler-provided uninstall script is available:
#
# 1. Runs the Zscaler-provided uninstall script
# 2. Removes any installer package receipts (this assumes that Zscaler was packaged for delivery using AutoPkg or other means.)
#
# If the  Zscaler-provided uninstall script is not available:
# 
# 1. Unloads the Zscaler LaunchAgent.
# 2. Removes the Zscaler LaunchAgent.
# 3. Unloads the Zscaler LaunchDaemons.
# 4. Removes the Zscaler LaunchDaemons.
# 5. Removes the Zscaler software.
# 6. Removes Zscaler components from user folders.
# 7. Removes any installer package receipts (this assumes that Zscaler was packaged for delivery using AutoPkg or other means.)


ReceiptRemoval (){

# Removing package receipts

for zscaler_receipt in $(pkgutil --pkgs=".*zscaler.*"); do
   /usr/sbin/pkgutil --forget $zscaler_receipt
done
}


ZscalerUninstall (){

/Applications/Zscaler/.Uninstaller.sh

# Removing Jamf Pro and installer package receipts

ReceiptRemoval
}

FallbackUninstall (){

echo "Uninstalling Zscaler software..."

echo "Unloading LaunchAgents"

# Checks to see if any user accounts are currently logged into the console (AKA logged into the GUI via the OS loginwindow)

logged_in_user=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

# If a user is logged in, unload the Zscaler LaunchAgent for the logged-in user.

if [[ -n "$logged_in_user" ]]; then
    
    # Identify the UID of the logged-in user
    logged_in_user_uid=$(id -u "$logged_in_user")
    
    /bin/launchctl bootout gui/"$logged_in_user_uid" /Library/LaunchAgents/com.zscaler.tray.plist
else
    echo "No user accounts are logged in at the login window. LaunchAgent does not need to be unloaded"
fi

echo "Removing LaunchAgents"

if [[ -f "/Library/LaunchAgents/com.zscaler.tray.plist" ]]; then
  rm "/Library/LaunchAgents/com.zscaler.tray.plist"
fi

echo "Unloading LaunchDaemons"

/bin/launchctl bootout system /Library/LaunchDaemons/com.zscaler.service.plist
/bin/launchctl bootout system /Library/LaunchDaemons/com.zscaler.tunnel.plist

echo "Removing LaunchDaemons"

if [[ -f "/Library/LaunchDaemons/com.zscaler.service.plist" ]]; then
  rm "/Library/LaunchDaemons/com.zscaler.service.plist"
fi

if [[ -f "/Library/LaunchDaemons/com.zscaler.tunnel.plist" ]]; then
  rm "/Library/LaunchDaemons/com.zscaler.tunnel.plist"
fi

echo "Deleting Zscaler software"

rm -rf "/Applications/Zscaler"

echo "Removing Zscaler components from user folder"

allLocalUsers=$(/usr/bin/dscl . -list /Users UniqueID | awk '$2>500 {print $1}')

for userName in ${allLocalUsers}; do

	  # get path to user's home directory
	  userHome=$(/usr/bin/dscl . -read "/Users/$userName" NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g')
 
      rm -rf "${userHome}/Library/Application Support/com.zscaler.Zscaler"
done

# Removing Jamf Pro and installer package receipts

ReceiptRemoval


echo "Uninstall completed successfully."
}

# Set exit error code

ERROR=0

# Check to see if Zscaler sofware is installed
# by locating the Zscaler directory in /Applications.

if [[ -d "/Applications/Zscaler" ]]; then
   
   # If the Zscaler software is installed, 
   # check for the Zscaler uninstall script.
   
   if [[ -x "/Applications/Zscaler/.Uninstaller.sh" ]]; then
   
       # Run the vendor-provided uninstall script for the Zscaler software.
       
       ZscalerUninstall
       
       if [[ $? -eq 0 ]]; then
			echo "Zscaler uninstalled successfully."
		else
			echo "Error: Failed to uninstall Zscaler software."
			ERROR=1
		fi
	else
		# Run the fallback Zscaler software uninstaller
		
		FallbackUninstall

       if [[ $? -eq 0 ]]; then
			echo "Zscaler uninstalled successfully."
		else
			echo "Error: Failed to uninstall Zscaler software."
			ERROR=1
		fi
    fi
else
   echo "Error: Zscaler software is not installed."
   ERROR=1
fi

exit $ERROR
