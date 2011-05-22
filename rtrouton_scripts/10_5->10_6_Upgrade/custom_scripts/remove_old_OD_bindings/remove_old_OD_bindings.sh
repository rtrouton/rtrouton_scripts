#!/bin/sh

# This script is designed to check for the settings of a OD
# server that you're not using any more and remove the settings
# from your Directory Service settings.

oldDomain="old.odserver.here" # Enter the FQDN of your old OD
oldODip="old.od.ip.here" # Enter the IP of your old OD
 
# These variables probably don't need to be changed
check4OD=`dscl localhost -list /LDAPv3`
 
# Check if bound to old Open Directory domain

if [ "${check4OD}" == "${oldDomain}" ]; then
	echo "This machine is joined to ${oldDomain}"
	echo "Removing from ${oldDomain}"
		dsconfigldap -r "${oldDomain}"
		dscl /Search -delete / CSPSearchPath /LDAPv3/"${oldDomain}"
		dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${oldDomain}"
	if [ "${odSearchPath}" = "" ]; then
		echo "$oldDomain not found in search path."
	fi

# Check if bound to old Open Directory domain's IP address

else if [ "${check4OD}" == "${oldODip}" ]; then
	echo "This machine is joined to ${oldODip}"
	echo "Removing from ${oldODip}"
		dsconfigldap -r "${oldODip}"
		dscl /Search -delete / CSPSearchPath /LDAPv3/"${oldODip}"
		dscl /Search/Contacts -delete / CSPSearchPath /LDAPv3/"${oldODip}"
	if [ "${odSearchPath}" = "" ]; then
		echo "$oldODip not found in search path."
	fi
fi
fi
killall DirectoryService
echo "Finished. Exiting..."