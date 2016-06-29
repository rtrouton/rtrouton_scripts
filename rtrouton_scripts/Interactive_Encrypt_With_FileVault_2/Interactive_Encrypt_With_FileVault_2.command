#!/bin/sh

# This script initializes FileVault encryption on the boot drive
# and enables a single user account


# General parameters

Version=1.0
FullScriptName=`basename "$0"`
ShowVersion="$FullScriptName $Version"

# Error checking
DEVICE_COUNT=`diskutil cs list | grep -E "^CoreStorage logical volume groups" | awk '{print $5}' | sed -e's/(//'`



EGREP_STRING=""
if [ "$DEVICE_COUNT" != "1" ]; then
  EGREP_STRING="^\| *"
fi

check4FV2encryption=`diskutil cs list | grep -E "$EGREP_STRING\Has Encrypted Extents" | sed -e's/\|//' | awk '{print $4}'`


# Domain-specific parameters

netIDprompt="Please enter the username of the  account being enabled: "
netPasswordprompt="Please enter the password for the $udn account: "

# Host-specific parameters
diskID=`diskutil info / | awk '/Device Identifier/{print $NF}'`


# Standard parameters


### End of configuration

echo "********* Running $FullScriptName Version $Version *********"

# If the machine is already encrypted, then there's no purpose going any further. 
if [ "${check4FV2encryption}" = "Yes" ]; then
	echo "This machine is already encrypted or in the process of encrypting.\nThis script will now exit. "; exit 1
fi

if [ ! -f /usr/local/bin/csfde ]; then
        echo "The csdfe utility is not installed in /usr/local/bin.\nPlease install csfde to that location.\nThis script will now exit"; exit 1
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

# Enter account information
printf "\e[1m$netIDprompt"
read udn
printf "\e[1m$netPasswordprompt"
stty -echo
read password
stty echo
echo ""         # force a carriage return to be output

echo "You entered $udn as the account name that you want to enable.\nIs this correct?"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes) echo "OK, the script will continue."; break;;
        	No ) echo "To avoid errors, the script will need to be restarted.\nExiting the script."; exit 0;;
    	esac
done

# Encrypting the Mac with csfde

echo "Initializing FileVault 2 encryption"

# Script will run csfde to initialize FileVault 2 encryption
# of the boot volume. The previously entered user account
# will be enabled as the only user account allowed to log
# in at the FileVault 2 pre-boot login screen.

/usr/local/bin/csfde $diskID $udn $password 2>/tmp/csfde_stderr.out | tee /tmp/recovery.plist

echo ""         # force a carriage return to be output
echo ""         # force a carriage return to be output

check4recoverypassphrase=`/usr/libexec/PlistBuddy -c "Print :recovery_password" /tmp/recovery.plist 2>/dev/null || echo "recovery_password does not exist"`

if [ "${check4recoverypassphrase}" != "recovery_password does not exist" ]; then
   echo "Here is the recovery key for this machine.\nPlease make a record of it and copy\nthe recovery key information to a secure location:"
   echo ""         # force a carriage return to be output
   defaults read /tmp/recovery.plist recovery_password
fi

if [ "${check4recoverypassphrase}" = "recovery_password does not exist" ]; then
   if [ -f /Library/Keychains/FileVaultMaster.keychain ]; then
     echo "FileVault 2 is using your institution's managed recovery key"
   else
     echo "An error has occurred in the encryption process.\nPlease decrypt at the first opportunity."
   fi
fi


echo ""         # force a carriage return to be output
echo ""         # force a carriage return to be output

# Cleaning up

# Remove plist with recovery key
# from /tmp

rm -rf /tmp/recovery.plist

#Exiting the script

echo "Finished initializing encryption.\nPlease restart to begin encryption of the boot drive."
exit 0
