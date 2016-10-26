#!/bin/bash
	
LOGGER="/usr/bin/logger"

# Determine working directory
install_dir=`dirname $0`
	
# Uninstall existing copy of Sophos 8.x by checking for the
# Sophos Antivirus uninstaller package in /Library/Sophos Anti-Virus.
# If present, the uninstallation process is run.

if [ -d "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
	${LOGGER} "Sophos AV present on Mac. Uninstalling before installing new copy."
	/usr/sbin/installer -pkg "/Library/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target ""
	killall SophosUIServer
elif [ -d "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" ]; then
	${LOGGER} "Sophos AV present on Mac. Uninstalling before installing new copy."
	/usr/sbin/installer -pkg "/Library/Application Support/Sophos Anti-Virus/Remove Sophos Anti-Virus.pkg" -target ""
	killall SophosUIServer
    
else
	${LOGGER} "Sophos Anti-Virus 8.x Uninstaller Not Present"
fi
	
# Uninstall existing copy of Sophos 9.x by checking for the InstallationDeployer application
# in the following locations:
#
# Sophos AV Cloud
# /Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/
# /Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/
#
# Sophos AV Home Edition
# /Library/Application Support/Sophos/he/Installer.app/Contents/MacOS
# /Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/tools
#
# Sophos AV Standalone
# /Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS
# /Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/tools
#
# Sophos AV Enterprise
# /Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS
# /Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools
#
# If the InstallationDeployer application is present in the Contents/MacOS/tools directory, the 
# uninstallation process is run using the InstallationDeployer tool located there.
#
# If the InstallationDeployer application is present only in the Contents/MacOS directory, the 
# uninstallation process is run using the InstallationDeployer tool located there.
#
# The reason for the directory-specific check is that running the InstallationDeployer application 
# from Contents/MacOS on Sophos 9.1.x and later will cause the Sophos uninstaller application to 
# launch in the dock and interfere with a normal installation via installer package.
#
# For more information, see the link below:
# http://www.sophos.com/en-us/support/knowledgebase/14179.aspx
	
if [[ -f "/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ ! -f "/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Home Edition present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/InstallationDeployer" --remove
elif [[ -f "/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Home Edition present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove
elif [[ ! -f "/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Home Edition present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/he/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove	
else
	${LOGGER} "Sophos Anti-Virus 9.x Home Edition Uninstaller Not Present"
fi

if [[ -f "/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ ! -f "/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Standalone present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/InstallationDeployer" --remove
elif [[ -f "/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Standalone present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove
elif [[ ! -f "/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Standalone present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/opm-sa/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove	
else
	${LOGGER} "Sophos Anti-Virus 9.x Standalone Uninstaller Not Present"
fi

if [[ -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ ! -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Enterprise present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/InstallationDeployer" --remove
elif [[ -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Enterprise present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove
elif [[ ! -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Enterprise present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/opm/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove	
else
	${LOGGER} "Sophos Anti-Virus 9.x Enterprise Uninstaller Not Present"
fi

if [[ -f "/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ ! -f "/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Cloud present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/InstallationDeployer" --remove
elif [[ -f "/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Cloud present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove
elif [[ ! -f "/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/InstallationDeployer" ]] && [[ -f "/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer" ]]; then
	${LOGGER} "Sophos AV Cloud present on Mac. Uninstalling before installing new copy."
	"/Library/Application Support/Sophos/saas/Installer.app/Contents/MacOS/tools/InstallationDeployer" --remove	
else
	${LOGGER} "Sophos Anti-Virus 9.x Cloud Uninstaller Not Present"
fi

exit 0