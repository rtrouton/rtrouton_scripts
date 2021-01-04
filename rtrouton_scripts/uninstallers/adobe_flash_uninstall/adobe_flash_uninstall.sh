#!/bin/bash

# This script uninstalls Adobe Flash software

AdobeFlashUninstall (){

echo "Uninstalling Adobe Flash software..."

# kill the Adobe Flash Player Install Manager

echo "Stopping Adobe Flash Install Manager."
killall "Adobe Flash Player Install Manager"

if [[ -f "/Library/LaunchDaemons/com.adobe.fpsaud.plist" ]]; then
   echo "Stopping Adobe Flash update process."
  /bin/launchctl bootout system "/Library/LaunchDaemons/com.adobe.fpsaud.plist"
fi

if [[ -f "/Library/Application Support/Macromedia/mms.cfg" ]]; then
  echo "Deleting Adobe Flash update preferences."
  rm "/Library/Application Support/Macromedia/mms.cfg"
fi

if [[ -e "/Library/Application Support/Adobe/Flash Player Install Manager/fpsaud" ]]; then
    echo "Deleting Adobe software update app and support files."
    rm "/Library/LaunchDaemons/com.adobe.fpsaud.plist"
    rm "/Library/Application Support/Adobe/Flash Player Install Manager/FPSAUConfig.xml"
    rm "/Library/Application Support/Adobe/Flash Player Install Manager/fpsaud"
fi

if [[ -e "/Library/Internet Plug-Ins/Flash Player.plugin" ]]; then
    echo "Deleting NPAPI browser plug-in files."
    rm -Rf "/Library/Internet Plug-Ins/Flash Player.plugin"
    rm -Rf "/Library/Internet Plug-Ins/Flash Player Enabler.plugin"
    rm "/Library/Internet Plug-Ins/flashplayer.xpt"
fi

if [[ -e "/Library/Internet Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin" ]]; then
    echo "Deleting PPAPI browser plug-in files."
    rm -Rf "/Library/Internet Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin"
    rm "/Library/Internet Plug-Ins/PepperFlashPlayer/manifest.json"
fi

if [[ -e "/Library/PreferencePanes/Flash Player.prefPane" ]]; then
    echo "Deleting Flash Player preference pane from System Preferences."
    rm -Rf "/Library/PreferencePanes/Flash Player.prefPane"
fi

# Removing Adobe Flash preference pane settings at user level

allLocalUsers=$(/usr/bin/dscl . -list /Users UniqueID | awk '$2>500 {print $1}')

for userName in ${allLocalUsers}; do

	  # get path to user's home directory
	  userHome=$(/usr/bin/dscl . -read "/Users/$userName" NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g')
 
      /usr/bin/defaults delete "${userHome}/Library/Preferences/com.apple.systempreferences.plist" com.adobe.preferences.flashplayer 2>/dev/null
done

#Remove receipts

rm -Rf /Library/Receipts/*FlashPlayer*
pkgutil --forget com.adobe.pkg.FlashPlayer >/dev/null 2>&1
pkgutil --forget com.adobe.pkg.PepperFlashPlayer >/dev/null 2>&1

# Remove Adobe Flash Player Install Manager.app

if [[ -e "/Applications/Utilities/Adobe Flash Player Install Manager.app" ]]; then
   echo "Deleting the Adobe Flash Player Install Manager app."
   rm -Rf "/Applications/Utilities/Adobe Flash Player Install Manager.app"
fi

echo "Uninstall completed successfully."
}

# Set exit error code

ERROR=0

# Check to see if Adobe Flash sofware is installed by locating either the Flash NPAPI or PPAPI browser
# plug-ins in /Library/Internet Plug-Ins or the Adobe Flash Player Install Manager.app in /Applications/Utilities

if [[ -e "/Library/Internet Plug-Ins/Flash Player.plugin" ]] || [[ -e "/Library/Internet Plug-Ins/PepperFlashPlayer/PepperFlashPlayer.plugin" ]] || [[ -e "/Applications/Utilities/Adobe Flash Player Install Manager.app" ]]; then

# Run the Adobe Flash Player software uninstaller
		
		AdobeFlashUninstall

       if [[ $? -eq 0 ]]; then
			echo "Adobe Flash Player uninstalled successfully."
		else
			echo "Error: Failed to uninstall Adobe Flash Player software."
			ERROR=1
		fi
 else
   echo "Error: Adobe Flash Player software is not installed."
   ERROR=1
fi
exit $ERROR
