#!/bin/bash

CheckBinary (){
 
# Identify location of jamf binary.
#
# If the jamf binary is not found, this check will return a
# null value.

jamf_binary=`/usr/bin/which jamf`

 if [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ ! -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/sbin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ ! -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 elif [[ "$jamf_binary" == "" ]] && [[ -e "/usr/sbin/jamf" ]] && [[ -e "/usr/local/bin/jamf" ]]; then
    jamf_binary="/usr/local/bin/jamf"
 fi

}

UninstallCasper () {

  # Uninstalls the Casper agent 
 
  # Checking for the jamf binary
  CheckBinary
  
  # Remove all JAMF Software-related components
  $jamf_binary removeFramework
 

}

# Runs the UninstallCasper function,
# which will automatically detect the
# Casper agent's location on the filesystem
# then uninstall the Casper agent

UninstallCasper