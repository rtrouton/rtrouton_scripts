#!/bin/bash

# This program will uninstall MacKeeper and JustCloud
#
# Original script by John Kitzmiller:
# https://github.com/kitzy/MacDeploymentScripts/blob/master/deleteMacKeeper/deleteMacKeeper.sh
#
# Credits for Elliot Jordan, Linde Group brought over from the original script

#################
### Variables ###
#################

# Items at the system level to be removed
systemItems=(
	/Applications/MacKeeper.app
	/Applications/JustCloud.app
	/Library/Preferences/.3FAD0F65-FC6E-4889-B975-B96CBF807B78
	/private/var/folders/mh/yprf0vxs3mx_n2lg3tjgqddm0000gn/T/MacKeeper*
	#Following items added by Elliot Jordan, Linde Group
    /private/tmp/MacKeeperOffers
    /private/tmp/_--_BRAND_--_.app
    /private/tmp/brand.tar.gz
    /private/tmp/com.mackeeper.MacKeeper.Installer.config
    /private/tmp/preinstall-JustCloud.log
    /private/tmp/postinstall-JustCloud.log
)

# Items at the user level to be removed
userItems=(
	Library/Application\ Support/MacKeeper\ Helper
	Library/LaunchAgents/com.zeobit.MacKeeper.Helper.plist
	Library/LaunchAgents/com.mackeeper.MacKeeper.Helper.plist
	Library/LaunchAgents/com.jdibackup.JustCloud.autostart.plist
	Library/LaunchAgents/com.jdibackup.JustCloud.notify.plist
	Library/Logs/JustCloud
	Library/Logs/MacKeeper.log
	Library/Logs/MacKeeper.log.signed
	Library/Logs/SparkleUpdateLog.log
	Library/Preferences/.3246584E-0CF8-4153-835D-C7D952862F9D
	Library/Preferences/com.zeobit.MacKeeper.Helper.plist
	Library/Preferences/com.mackeeper.MacKeeper.Helper.plist
	Library/Preferences/com.zeobit.MacKeeper.plist
	Library/Preferences/com.mackeeper.MacKeeper.plist
	Library/Saved\ Application\ State/com.zeobit.MacKeeper.savedState
	Library/Saved\ Application\ State/com.mackeeper.MacKeeper.savedState
	Documents/MacKeeper\ Backups
)

#################
### Functions ###
#################

function deleteItems()
{
	declare -a toDelete=("${!1}")

	for item in "${toDelete[@]}"
		do
			if [[ ! -z "${2}" ]]
				then
					item=("${2}""${item}")
			fi

			echo "Looking for $item"

			if [ -e "${item}" ]
				then
					echo "Removing $item"
					rm -rf "${item}"
			fi
		done
}

####################
### Main Program ###
####################

# Kill the apps, if they are running
# Added by Elliot Jordan, Linde Group
echo "Killing MacKeeper-related apps"
killall "JustCloud"
killall "MacKeeper Helper"
killall "MacKeeper"

# Delete system level items
deleteItems systemItems[@]

# Delete user level items
for dirs in /Users/*/
		do
			deleteItems userItems[@] "${dirs}"
		done

exit 0