#!/bin/bash

# This script runs a manual policy trigger to
# allow the policy or policies associated with that
# trigger to be executed.

trigger_name="$4"

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

# Run the CheckBinary function to identify the location
# of the jamf binary for the jamf_binary variable.

CheckBinary

$jamf_binary policy -trigger "$trigger_name"