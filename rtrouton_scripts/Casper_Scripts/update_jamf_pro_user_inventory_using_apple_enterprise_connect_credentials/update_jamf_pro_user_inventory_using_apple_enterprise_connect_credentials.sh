#!/bin/bash

#
# This script is designed to do the following:
#
# 1. Identify if Apple Enterprise Connect is installed on a particular Mac
# 2. If EC is installed, identify the username of the Active Directory account logged into Apple's Enterprise Connect.
# 3. Upload the username information to a Jamf Pro server and update the 'User and Location' section
#    of the computer's inventory listing.
#

# Identify the username of the logged-in user
logged_in_user=`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`

# Identify location of the logged-in user's home directory
user_home_location=`/usr/bin/dscl . -read /Users/"${logged_in_user}" NFSHomeDirectory 2>/dev/null | /usr/bin/sed 's/^[^\/]*//g'`

CheckBinary (){

# Identify location of jamf binary.

jamf_binary=`/usr/bin/which jamf`

 if [[ "$jamf_binary" == "" ]] && [[ -x "/usr/sbin/jamf" ]] && [[ ! -x "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/sbin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ ! -x "/usr/sbin/jamf" ]] && [[ -x "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ -x "/usr/sbin/jamf" ]] && [[ -x "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 fi
}

# Read logged-in user's login keychain for the username
# used to log into Enterprise Connect

if [[ -d "/Applications/Enterprise Connect.app" ]]; then
    /usr/bin/security find-generic-password -l "Enterprise Connect" "${user_home_location}"/Library/Keychains/login.keychain > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        ec_user=$(/usr/bin/security find-generic-password -l "Enterprise Connect" "${user_home_location}"/Library/Keychains/login.keychain | awk -F "=" '/acct/ {print $2}' | tr -d "\"")
        if [[ ! -z "${ec_user}" ]]; then
            CheckBinary
            # Update computer's inventory listing in Jamf Pro with logged-in user information
            $jamf_binary recon -endUsername $ec_user
        fi
    fi
fi