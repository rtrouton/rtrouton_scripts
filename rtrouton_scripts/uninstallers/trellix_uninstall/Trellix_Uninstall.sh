#!/bin/bash

# Trellix_Uninstall.sh, 0.1.0

# This script uninstalls Trellix Endpoint Security for Mac, Trellix DLP, and the
# Trellix agent, as well as cleaning up older McAfee Endpoint Security for Mac,
# McAfee DLP and McAfee agent installs.

# Run the vendor-provided uninstallers if available.

if [[ -x /usr/local/McAfee/uninstall ]]; then
	/usr/local/McAfee/uninstall EPM
fi

if [[ -x /Library/McAfee/agent/scripts/uninstall.sh ]]; then
	/Library/McAfee/agent/scripts/uninstall.sh
fi

if [[ -x /usr/local/McAfee/MSCUI/uninstallMSCUI.sh ]]; then
	/usr/local/McAfee/MSCUI/uninstallMSCUI.sh
fi

# Unload the LaunchAgents for the current user.

currentUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')
if [[ -n "$currentUser" && "$currentUser" != "root" ]]; then
	/usr/bin/sudo -u "$currentUser" /bin/launchctl unload /Library/LaunchAgents/com.mcafee.*
fi

# Unload the McAfee and Trellix LaunchDaemons.

/bin/launchctl bootout system /Library/LaunchDaemons/com.mcafee.*

# Stop all running processes if running.

/usr/bin/killall "McAfee Reporter" "McAfee Endpoint Security for Mac" "Trellix Reporter" "Trellix Endpoint Security for Mac" "Menulet" "Trellix Agent Status Monitor"

# Unload any running kernel extensions.

/sbin/kextunload /usr/local/McAfee/AntiMalware/Extensions/*.kext
/sbin/kextunload /usr/local/McAfee/fmp/Extensions/*.kext
/sbin/kextunload "/Library/Application Support/McAfee/AntiMalware/"*.kext
/sbin/kextunload "/Library/Application Support/McAfee/FMP/"*.kext

# Delete any remaining files.

/bin/rm -rf /Library/LaunchAgents/com.mcafee.* \
			/Library/LaunchDaemons/com.mcafee.* \
			/Library/StartupItems/cma \
			/usr/local/McAfee \
			/etc/cma.d \
			/etc/ma.d \
			/etc/cma.conf \
			/var/log/McAfeeSecurity* \
			/var/log/DLPAgent* \
			/var/log/DlpAgent* \
			/var/log/mcupdater* \
			/var/log/MFEdx* \
			/var/tmp/.msgbus/ma_* \
			/var/McAfee \
			/Library/Logs/DiagnosticReports/masvc* \
			/Library/Logs/DiagnosticReports/VShieldService* \
			"/Library/Application Support/McAfee" \
			/Library/McAfee \
			"/Library/Internet Plug-Ins/Web Control.plugin" \
			/Library/Documentation/Help/McAfeeSecurity* \
			/Library/Preferences/com.mcafee.* \
			/Library/Preferences/.com.mcafee.* \
			/Library/Frameworks/AVEngine.framework \
			/Library/Frameworks/VirusScanPreferences.framework \
			/Library/PrivilegedHelperTools/com.trellix.* \
			"/Applications/McAfee Endpoint Security for Mac.app" \
			"/Applications/McAfee Endpoint Protection for Mac.app" \
			"/Applications/McAfeeSystemExtensions.app" \
			"/Applications/Trellix Endpoint Security for Mac.app" \
			"/Applications/TrellixSystemExtensions.app"
			
# Remove the Quarantine folder if present and empty.

if [[ -z "$(/bin/ls -A /Quarantine 2>/dev/null | /usr/bin/grep -vE '(.DS_Store|.Quarantine.lck)')" ]]; then
	/bin/rm -rf /Quarantine
fi
			
localUsers=$(/usr/bin/dscl . -list /Users | /usr/bin/grep -v "^_")

for userName in ${localUsers}; do

	# Get path to user's home directory
	userHome=$(/usr/bin/dscl . -read /Users/$userName NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g')
    
    # Remove user-level files from the user home directories.
    
	if [[ -d "$userHome" && "$userHome" != "/var/empty" ]]; then
		/bin/rm -f "$userHome/Library/Preferences/com.mcafee."* \
		           "$userHome/Library/Logs/DiagnosticReports/Menulet"*
	fi
done

# remove the mfe user account created by Trellix and McAfee.

if [[ -n $(/usr/bin/id mfe 2>/dev/null) ]]; then
	/usr/sbin/sysadminctl -deleteUser mfe --keepHome
fi

# Forget the Trellix and McAfee installer package receipts

allPackages=$(/usr/sbin/pkgutil --pkgs | /usr/bin/grep -E "(mcafee|trellix|comp.nai.cmamac)")
for aPackage in ${allPackages}; do
	/usr/sbin/pkgutil --forget "$aPackage" >/dev/null 2>&1
done

exit 0