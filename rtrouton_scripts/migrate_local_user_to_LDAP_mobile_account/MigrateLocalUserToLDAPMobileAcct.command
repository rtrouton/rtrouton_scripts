#!/bin/sh
# Modified 10/10/2013
Version=1.2
#
# Adapted from 
# MigrateUserHomeToADAcct.sh
# Patrick Gallagher
# Emory College
#
# Modified by Rich Trouton
#
# Version 1.0 - Has the ability to check if the Mac is bound to LDAP.
#
# If the OS running is Mac OS X 10.7 or higher, script runs "killall opendirectoryd"
# to restart directory services.
#
# If the OS running is Mac OS X 10.6, script runs "killall DirectoryService" 
# to restart directory services.
#
# Version 1.1 - Changed the admin rights function from using dscl append to using dseditgroup
#
# Version 1.2 - Fixed the admin rights functionality so that it actually now grants admin rights
#


clear

netIDprompt="Please enter the LDAP account for this user: "
listUsers="$(/usr/bin/dscl . list /Users | grep -v _ | grep -v root | grep -v uucp | grep -v amavisd | grep -v nobody | grep -v messagebus | grep -v daemon | grep -v www | grep -v Guest | grep -v xgrid | grep -v windowserver | grep -v unknown | grep -v unknown | grep -v tokend | grep -v sshd | grep -v securityagent | grep -v mailman | grep -v mysql | grep -v postfix | grep -v qtss | grep -v jabber | grep -v cyrusimap | grep -v clamav | grep -v appserver | grep -v appowner) FINISHED"
#listUsers="$(/usr/bin/dscl . list /Users | grep -v -e _ -e root -e uucp -e nobody -e messagebus -e daemon -e www -v Guest -e xgrid -e windowserver -e unknown -e tokend -e sshd -e securityagent -e mailman -e mysql -e postfix -e qtss -e jabber -e cyrusimap -e clamav -e appserver -e appowner) FINISHED"
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"
check4LDAP=`/usr/bin/dscl localhost -list . | grep LDAPv3`
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')
lookupAccount=helpdesk
OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`

echo "********* Running $FullScriptName Version $Version *********"

# If the machine is not bound to the LDAP server, then there's no purpose going any further. 
if [ "${check4LDAP}" != "LDAPv3" ]; then
	echo "This machine is not bound to the LDAP server.\nPlease bind this Mac to the LDAP server first. "; exit 1
fi

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

until [ "$user" == "FINISHED" ]; do

	printf "%b" "\a\n\nSelect a user to convert or select FINISHED:\n" >&2
	select user in $listUsers; do
	
		if [ "$user" = "FINISHED" ]; then
			echo "Finished converting users to LDAP"
			break
		elif [ -n "$user" ]; then
			if [ `who | grep console | awk '{print $1}'` == "$user" ]; then
				echo "This user is logged in.\nPlease log this user out and log in as another admin"
				exit 1
			fi
			# Verify NetID
				printf "\e[1m$netIDprompt"
				read netname
				/usr/bin/id $lookupAccount
                                echo ""
				echo "Did the information displayed include a line similar to this: gid=93417(helpdesk)?\nIt should be the second item listed."
				select yn in "Yes" "No"; do
    					case $yn in
        					Yes) echo "Great! It looks like this Mac is communicating with the LDAP server correctly.\nScript will continue the migration process."; break;;
        					No ) echo "It doesn't look like this Mac is communicating with the LDAP server correctly.\nExiting the script."; exit 0;;
    					esac
				done

			# Determine location of the users home folder
			userHome=`/usr/bin/dscl . read /Users/$user NFSHomeDirectory | cut -c 19-`
			
			# Get list of groups
			echo "Checking group memberships for local user $user"
			lgroups="$(/usr/bin/id -Gn $user)"
			
			
			if [[ $? -eq 0 ]] && [[ -n "$(/usr/bin/dscl . -search /Groups GroupMembership "$user")" ]]; then 
			# Delete user from each group it is a member of
				for lg in $lgroups; 
					do
						/usr/bin/dscl . -delete /Groups/${lg} GroupMembership $user >&/dev/null
					done
			fi
			# Delete the primary group
			if [[ -n "$(/usr/bin/dscl . -search /Groups name "$user")" ]]; then
  				/usr/sbin/dseditgroup -o delete "$user"
			fi
			# Get the users guid and set it as a var
			guid="$(/usr/bin/dscl . -read "/Users/$user" GeneratedUID | /usr/bin/awk '{print $NF;}')"
			if [[ -f "/private/var/db/shadow/hash/$guid" ]]; then
 				/bin/rm -f /private/var/db/shadow/hash/$guid
			fi
			# Delete the user
			/bin/mv $userHome /Users/old_$user
			/usr/bin/dscl . -delete "/Users/$user"

				# Refresh Directory Services
				if [[ ${osvers} -ge 7 ]]; then
					/usr/bin/killall opendirectoryd
				else
					/usr/bin/killall DirectoryService
				fi
				sleep 20
				/usr/bin/id $netname
				# Check if there's a home folder there already, if there is, exit before we wipe it
				if [ -f /Users/$netname ]; then
					echo "Oops, theres a home folder there already for $netname.\nIf you don't want that one, delete it in the Finder first,\nthen run this script again."
					exit 1
				else
                                        /System/Library/CoreServices/ManagedClient.app/Contents/Resources/createmobileaccount -n $netname
                                        /bin/rm -rf /Users/$netname
					/bin/mv /Users/old_$user /Users/$netname
					/usr/sbin/chown -R ${netname} /Users/$netname
					echo "Home for $netname now located at /Users/$netname"
					
					echo "Account for $netname has been created on this computer"			
				fi
				echo "Do you want to give the $netname account admin rights?"
				select yn in "Yes" "No"; do
    					case $yn in
        					Yes) /usr/sbin/dseditgroup -o edit -a "$netname" -t user admin; echo "Admin rights given to this account"; break;;
        					No ) echo "No admin rights given"; break;;
    					esac
				done
			break
		else
			echo "Invalid selection!"
		fi
	done
done