#!/bin/sh
# Modified 12/20/2016
Version=1.0
# Original source is from MigrateUserHomeToDomainAcct.sh
# Written by Patrick Gallagher - https://twitter.com/patgmac
#
# Modified by Rich Trouton
#
# Version 1.0 - Migrates an Active Directory mobile account to a local account by the following process:

# 1. Display a list of the accounts with a UID greater than 1000
# 2. Select an account from the list
# 3. Back up the password hash of the account from the AuthenticationAuthority attribute
# 4. Remove the following attributes from the specified account:
# 
# cached_groups
# cached_auth_policy
# CopyTimestamp - This attribute is used by the OS to determine if the account is a mobile account
# SMBPrimaryGroupSID
# OriginalAuthenticationAuthority
# OriginalNodeName
# AuthenticationAuthority
# SMBSID
# SMBScriptPath
# SMBPasswordLastSet
# SMBGroupRID
# PrimaryNTDomain
# AppleMetaRecordName
# MCXSettings
# MCXFlags
#
# 5. Recreate the AuthenticationAuthority attribute and restore the password hash of the account from backup
# 6. Restart the directory services process
# 7. Check to see if the conversion process succeeded by checking the OriginalNodeName attribute for the value "Active Directory"
# 8. If the conversion process succeeded, update the permissions on the account's home folder.
# 9. Prompt if admin rights should be granted for the specified account

clear

listUsers="$(/usr/bin/dscl . list /Users UniqueID | awk '$2 > 1000 {print $1}') FINISHED"
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"
check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

echo "********* Running $FullScriptName Version $Version *********"

RunAsRoot()
{
        ##  Pass in the full path to the executable as $1
        if [[ "${USER}" != "root" ]] ; then
                echo
                echo "***  This application must be run as root.  Please authenticate below.  ***"
                echo
                sudo "${1}" && exit 0
        fi
}

RunAsRoot "${0}"

# If the machine is not bound to AD, then there's no purpose going any further. 
if [[ "${check4AD}" = "Active Directory" ]]; then
	printf "This machine is bound to Active Directory.\nDo you want to unbind this Mac from AD?\n"
		select yn in "Yes" "No"; do
			case $yn in
			    Yes) /usr/sbin/dsconfigad -remove -force -u none -p none; echo "AD binding has been removed."; break;;
			    No) echo "Active Directory binding is still active."; break;;
			esac
		done
fi

until [ "$user" == "FINISHED" ]; do

	printf "%b" "\a\n\nSelect a user to convert or select FINISHED:\n" >&2
	select netname in $listUsers; do
	
		if [ "$netname" = "FINISHED" ]; then
			echo "Finished converting users to local accounts"
			exit 0
		fi
	
	  accounttype=`/usr/bin/dscl . -read /Users/"$netname" OriginalNodeName | tail -1 | awk -F'/' '{print $2}'`
			
		if [[ "$accounttype" = "Active Directory" ]]; then
			printf "$netname has an AD mobile account.\nConverting to a local account with the same username and UID.\n"
		else
			printf "The $netname account is not a mobile account\n"
			break
		fi

			# Preserve the account password by backing up password hash
			
			shadowhash=`/usr/bin/dscl . -read /Users/$netname AuthenticationAuthority | grep " ;ShadowHash;HASHLIST:<"`
			
			# Remove the account attributes that identify it as an Active Directory mobile account
			
			/usr/bin/dscl . -delete /users/$netname cached_groups
			/usr/bin/dscl . -delete /users/$netname cached_auth_policy
			/usr/bin/dscl . -delete /users/$netname CopyTimestamp
			/usr/bin/dscl . -delete /users/$netname AltSecurityIdentities
			/usr/bin/dscl . -delete /users/$netname SMBPrimaryGroupSID
			/usr/bin/dscl . -delete /users/$netname OriginalAuthenticationAuthority
			/usr/bin/dscl . -delete /users/$netname OriginalNodeName
			/usr/bin/dscl . -delete /users/$netname AuthenticationAuthority
			/usr/bin/dscl . -create /users/$netname AuthenticationAuthority \'$shadowhash\'
			/usr/bin/dscl . -delete /users/$netname SMBSID
			/usr/bin/dscl . -delete /users/$netname SMBScriptPath
			/usr/bin/dscl . -delete /users/$netname SMBPasswordLastSet
			/usr/bin/dscl . -delete /users/$netname SMBGroupRID
			/usr/bin/dscl . -delete /users/$netname PrimaryNTDomain
			/usr/bin/dscl . -delete /users/$netname AppleMetaRecordName
			/usr/bin/dscl . -delete /users/$netname PrimaryNTDomain
			/usr/bin/dscl . -delete /users/$netname MCXSettings
			/usr/bin/dscl . -delete /users/$netname MCXFlags

			# Refresh Directory Services
			if [[ ${osvers} -ge 7 ]]; then
				/usr/bin/killall opendirectoryd
			else
				/usr/bin/killall DirectoryService
			fi
			
			sleep 20
			
			accounttype=`/usr/bin/dscl . -read /Users/"$netname" OriginalNodeName | tail -1 | awk -F'/' '{print $2}'`
			if [[ "$accounttype" = "Active Directory" ]]; then
			   printf "Something went wrong with the conversion process.\nThe $netname account is still an AD mobile account.\n"
			   exit 1
			 else
			   printf "Conversion process was successful.\nThe $netname account is now a local account.\n"
			fi
			
			/usr/bin/id $netname
			homedir=`/usr/bin/dscl . -read /Users/"$netname" NFSHomeDirectory  | awk '{print $2}'`
			if [[ "$homedir" != "" ]]; then
			   echo "Home directory location: $homedir"
			   echo "Updating home folder permissions for the $netname account"
			   /usr/sbin/chown -R "$netname" "$homedir"		
			fi
			echo "Do you want to give the $netname account admin rights?"
			select yn in "Yes" "No"; do
    				case $yn in
        				Yes) /usr/sbin/dseditgroup -o edit -a "$netname" -t user admin; echo "Admin rights given to this account"; break;;
        				No ) echo "No admin rights given"; break;;
    				esac
			done
			break
	done
done