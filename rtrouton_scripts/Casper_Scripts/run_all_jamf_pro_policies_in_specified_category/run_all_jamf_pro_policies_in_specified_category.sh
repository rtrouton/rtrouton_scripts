#!/bin/bash

# Set username of the API user. 
# Script uses Parameter 4 to get the appropriate username from Jamf Pro

apiUsername="$4"

# Set password of the API user.
# Script uses Parameter 5 to get the  appropriate password from Jamf Pro.

apiPassword="$5"

# Set the policy category which contains the Jamf Pro
# policies that need to be run. Script uses Parameter 6
# to get the appropriate category from Jamf Pro.

PolicyCategory="$6"


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
  # of the jamf binary
  
  CheckBinary

  # If the jamf binary isn't found, stop the script
  # and exit with an error status.

  if [[ "$jamf_binary" == "" ]]; then
     /bin/echo "`date +%Y-%m-%d\ %H:%M:%S`  Jamf Pro agent not found. Exiting."
     exit 1
  fi

  # Identify the URL of the Jamf Pro server using the
  # 'jamf checkJSSConnection' command
  
  JamfProURLCheck=$("$jamf_binary" checkJSSConnection | awk '/Checking/ {print $4}')
  JamfProURL=$(echo ${JamfProURLCheck///...})
  JamfProPolicyURL="${JamfProURL}/JSSResource/policies/category/${PolicyCategory}"

  # Save current IFS state

   OLDIFS=$IFS

  # Change IFS to
  # create newline

   IFS=$'\n'
  
   casper_policy_ids=`/usr/bin/curl -ksf -u "${apiUsername}:${apiPassword}" -H "Accept: application/xml" "${JamfProPolicyURL}" | xpath "policies/policy/id" | sed 's/\<id>//g' | tr '</id>' '\n' | sed '/^s*$/d'`
  
  # read all policy IDs into an array

  policies=($(/bin/echo "$casper_policy_ids"))
 
  # restore IFS to previous state

  IFS=$OLDIFS
  
  # Get length of the array

  tLen=${#policies[@]}
  
  # Run all matching Jamf Pro policies in the order received from the Jamf Pro server
  
  for (( i=0; i<${tLen}; i++ ));
  do
     /bin/echo "`date +%Y-%m-%d\ %H:%M:%S`  Installing policy "${policies[$i]}" on this Mac."
     "$jamf_binary" policy -id "${policies[$i]}"
  done
