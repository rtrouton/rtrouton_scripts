#!/bin/bash

# This script performs the following actions:
# 
# Fix the ByHost files for the logged-in user
# Flush caches from ~/Library/Caches/, ~/.jpi_cache/, and the Microsoft Office font cache for the logged-in user
# Flush caches from /Library/Caches/ and /System/Library/Caches/, except for any com.apple.LaunchServices caches
#

CheckBinary (){

# Identify location of jamf binary.

jamf_binary=`/usr/bin/which jamf`

 if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/sbin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 fi
}

# Run the CheckBinary function to identify the location
# of the jamf binary for the jamf_binary variable.

CheckBinary

# Fixes the ByHost files for the current boot drive

$jamf_binary fixByHostFiles -target /

# Flush caches in the logged-in user's home directory

$jamf_binary flushCaches -flushUsers

# Flush OS system caches

$jamf_binary flushCaches -flushSystem