#!/bin/bash

# This script is designed as a Casper Extension attribute to identify specific local user accounts
# which are older than a certain number of days. The use case is to help locate local accounts which
# were meant to be disposable after a certain amount of time.

# Set the username of the account that you want to check for.

UserAccount="username_goes_here"

# Setting the number of days for the ExpirationDate value in the script.
# For example, setting DaysBeforeExpiration to 14 means that the 
# ExpirationDate value further below in the script will output a date 
# which is 14 days before the current date.

DaysBeforeExpiration="14"

if [[ `/usr/bin/dscl . list /Users UniqueID | awk '$2 > 500 && $2 < 1000 { print $1 }' | grep "$UserAccount"` = "" ]]; then
  result="$UserAccount account not present"
fi

if [[ `/usr/bin/dscl . list /Users UniqueID | awk '$2 > 500 && $2 < 1000 { print $1 }' | grep "$UserAccount"` != "" ]]; then
  
  # Getting location of the specified account's home folder
  
  UserHome=`/usr/bin/dscl . read /Users/$UserAccount NFSHomeDirectory | awk '{ print $2 }'`
  
  # Checking the account's home folder for its creation date
  
  UserHomeCreationDate=`mdls -raw -name kMDItemFSCreationDate $UserHome | awk '{ print $1 }' | sed 's/\-//g'`
  
  ExpirationDate=`date -j -v-"$DaysBeforeExpiration"d +"%Y-%m-%d" | sed 's/\-//g'`

  # If the account's home folder is older than the number of days
  # set in the DaysBeforeExpiration value, the script will return
  # "Yes". If the account's home folder is not older, the script 
  # will return "No".
  #
  # In the event that the script is unable to determine the home folder
  # age, the script will return the following:
  #
  # "Username_goes_here account present but unable to determine age. Please check."
  

  if [[ -z "${UserHomeCreationDate}" ]]; then
    result="$UserAccount account present but unable to determine age. Please check."
  fi
  
  if [[ ! -z "${UserHomeCreationDate}" ]]; then
    if [[ "${UserHomeCreationDate}" -lt "${ExpirationDate}" ]]; then
       result="Yes"
      else
       result="No"
    fi
  fi    
fi

echo "<result>$result</result>"