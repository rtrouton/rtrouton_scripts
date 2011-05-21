#!/bin/sh

# This script binds to AD and configures advanced options of the AD plugin
# As this scripts contains a number of DOMAIN-specific AD information, be sure to take appropriate security
# precautions to safeguard this script


# General parameters

Version=1.0
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"

# Error checking

check4AD=`/usr/bin/dscl localhost -list . | grep "Active Directory"`

# Domain-specific parameters

netIDprompt="Please enter the AD admin account being used to bind this machine: "
netPasswordprompt="Please enter the password for the $udn account: "
netMachineprompt="Enter the computer name you want to use to bind this machine: " 

# Host-specific parameters
# computerid should be set dynamically, this value must be machine-specific
# This value may be restricted to 19 characters! The only error you'll receive upon entering
# an invalid computer id is to the effect of not having appropriate privileges to perform the requested operation
#computerid=`/sbin/ifconfig en0 | awk '/ether/ { gsub(":", ""); print $2 }'` # MAC Address
#computerid=`hostname`
#computerid=`/usr/sbin/scutil --get LocalHostName | cut -c 1-19` # Assure that this will produce unique names!
computerid=`/usr/sbin/scutil --get LocalHostName`



# Standard parameters
domain="DOMAIN.COM"			# fully qualified DNS name of Active Directory Domain
#udn="bind_account"			# username of a privileged network user
#password=""				# password of a privileged network user
laptop_ou="OU=Macs,OU=Laptops,OU=Computers,OU=DIVISION,OU=COMPANY,OU=FOREST,DC=COMPANY,DC=COM"		# Distinguished name of container for the Mac laptops
desktop_ou="OU=Macs,OU=Desktops,OU=Computers,OU=DIVISION,OU=COMPANY,OU=FOREST,DC=COMPANY,DC=COM"	# Distinguished name of container for the Mac desktops

# Advanced options
alldomains="disable"			# 'enable' or 'disable' automatic multi-domain authentication
localhome="enable"			# 'enable' or 'disable' force home directory to local drive
protocol="smb"				# 'afp' or 'smb' change how home is mounted from server
mobile="enable"			# 'enable' or 'disable' mobile account support for offline logon
mobileconfirm="enable"		# 'enable' or 'disable' warn the user that a mobile acct will be created
useuncpath="disable"			# 'enable' or 'disable' use AD SMBHome attribute to determine the home dir
user_shell="/bin/bash"		# e.g., /bin/bash or "none"
preferred="-nopreferred"	# Use the specified server for all Directory lookups and authentication
							# (e.g. "-nopreferred" or "-preferred ad.server.edu")
admingroups=""				# These comma-separated AD groups may administer the machine (e.g. "" or "APPLE\mac admins")
packetsign="allow"			# allow | disable | require
packetencrypt="allow"			# allow | disable | require
passinterval="14"			# number of days
namespace="domain"			# forest | domain


### End of configuration

echo "********* Running $FullScriptName Version $Version *********"

# If the machine is already bound to AD, then there's no purpose going any further. 
if [ "${check4AD}" = "Active Directory" ]; then
	echo "This machine is already bound to Active Directory.\nThis script will now exit. "; exit 1
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

# Enter AD admin account information
printf "\e[1m$netIDprompt"
read udn
printf "\e[1m$netPasswordprompt"
stty -echo
read password
stty echo
echo ""         # force a carriage return to be output

# Enter AD computer ID
# If you need to enter a message for your support team with regards to your naming convention, here's a good place to do it.
echo "For computer ID, set it as HG-NNNNNNN-XXX where NNNNNNN 
is the inventory decal number and XXX is determined by the type of Mac and the 
OS (see descriptions below.) For example, a Mac desktop running 10.4.x would be 
HG-NNNNNNN-DM4, and a Mac laptop running 10.6.x would be HG-NNNNNNN-LM6. 
  
Type  

D - Desktop
L - Laptop

Platform   

M - Apple Macintosh

Operating System (OS)

4 - 10.4
5 - 10.5
6 - 10.6"
echo ""
printf "\e[1m$netMachineprompt"
read computerid
echo "You entered $udn as the AD admin account name you're using to bind this machine. Is this correct?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) echo "OK, the script will continue."; break;;
        	No ) echo "To avoid errors, the script will need to be restarted. Exiting the script."; exit 0;;
    	esac
done

echo "You entered $computerid as the AD computer name. Is this correct?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) echo "OK, the script will continue."; break;;
        	No ) echo "To avoid errors, the script will need to be restarted. Exiting the script."; exit 0;;
    	esac
done

# Activate the AD plugin
defaults write /Library/Preferences/DirectoryService/DirectoryService "Active Directory" "Active"
plutil -convert xml1 /Library/Preferences/DirectoryService/DirectoryService.plist

# Binding to the correct Active Directory OU
echo "Is the Mac a laptop?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) dsconfigad -f -a $computerid -domain $domain -u $udn -p "$password" -ou "$laptop_ou"; echo "Adding to OU=Macs,OU=Laptops,OU=Computers,OU=DIVISION,OU=COMPANY,OU=FOREST,DC=COMPANY,DC=COM."; break;;
        	No ) dsconfigad -f -a $computerid -domain $domain -u $udn -p "$password" -ou "$desktop_ou"; echo "Adding to OU=Macs,OU=Desktops,OU=Computers,OU=DIVISION,OU=COMPANY,OU=FOREST,DC=COMPANY,DC=COM."; break;;
    	esac
done

# Configure advanced AD plugin options
if [ "$admingroups" = "" ]; then
	dsconfigad -nogroups
else
	dsconfigad -groups "$admingroups"
fi

dsconfigad -alldomains $alldomains -localhome $localhome -protocol $protocol \
	-mobile $mobile -mobileconfirm $mobileconfirm -useuncpath $useuncpath \
	-shell $user_shell $preferred -packetsign $packetsign -packetencrypt $packetencrypt \
	-passinterval $passinterval -namespace $namespace

# Restart DirectoryService (necessary to reload AD plugin activation settings)
echo "Restarting Directory Services (necessary to reload Active Directory plugin settings.)"
killall DirectoryService
sleep 10
# Add the AD node to the search path
#if [ "$alldomains" = "enable" ]; then
#	csp="/Active Directory/All Domains"
#else
#	csp="/Active Directory/$domain"
#fi
echo "Adding the AD node to the search path in Directory Utility."
#dscl /Search -create / SearchPolicy CSPSearchPath
#dscl /Search -append / CSPSearchPath /Active\ Directory/$domain
#dscl /Search -create / SearchPolicy dsAttrTypeStandard:CSPSearchPath
#dscl /Search/Contacts -append / CSPSearchPath "$csp"
#dscl /Search/Contacts -create / SearchPolicy dsAttrTypeStandard:CSPSearchPath
#killall DirectoryService

# This works in a pinch if the above code does not

defaults write /Library/Preferences/DirectoryService/SearchNodeConfig "Search Node Custom Path Array" -array-add "/Active Directory/$domain"
defaults write /Library/Preferences/DirectoryService/SearchNodeConfig "Search Policy" -int 3
plutil -convert xml1 /Library/Preferences/DirectoryService/SearchNodeConfig.plist
killall DirectoryService
sleep 20


#Exiting the script
echo "Finished binding Mac to AD"
exit 0
