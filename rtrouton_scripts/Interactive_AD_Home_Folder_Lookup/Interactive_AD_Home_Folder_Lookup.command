#!/bin/sh

#
# This script looks up the location of the network home folder for a particular Active Directory account.
#


# General parameters

Version=1.0
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"
OS=`/usr/bin/sw_vers | grep ProductVersion | cut -c 17-20`

# Error checking

check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

# Domain-specific parameters

netIDprompt="Please enter the username in the blank provided, then click Enter: "

echo "********* Running $FullScriptName Version $Version *********"

# If the machine is not bound to AD, then there's no purpose going any further. 
if [ "${check4AD}" != "Active Directory" ]; then
	echo "This machine is not bound to Active Directory and won't be able to look up the network home location.\nThis script will now exit. "; exit 1
fi

# Enter AD admin account information
printf "\e[1m$netIDprompt"
read udn
stty -echo
echo ""         # force a carriage return to be output

# Error checking, to verify that the user entered the right information

echo "You entered $udn as the account name that you want to look up the home folder for. Is this correct?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) echo "OK, the script will continue."; break;;
        	No ) echo "To avoid errors, the script will need to be restarted. Exiting the script."; exit 0;;
    	esac
done
echo ""         # force a carriage return to be output
echo ""
echo "Home folder is located at the following address:"
echo ""
if [ "${OS}" = "10.7" ]; then
	#
	# For your 10.7 and higher Macs, you'll need to replace DOMAIN with your own Active Directory domain name
	#
	/usr/bin/dscl localhost -read /Active\ Directory/DOMAIN/All\ Domains/Users/$udn SMBHome | /usr/bin/sed -e 's/\\\/\\//g' | /usr/bin/awk '{print $2}'                
else
	/usr/bin/dscl localhost -read /Active\ Directory/All\ Domains/Users/$udn SMBHome | /usr/bin/sed -e 's/\\\/\\//g' | /usr/bin/awk '{print $2}'
fi
echo ""         # force a carriage return to be output
echo ""

#Exiting the script
echo "Finished looking up the home folder"
exit 0