#!/bin/bash

#
# Script to force AD unbinding
#

# Save current IFS state

OLDIFS=$IFS

IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"

# restore IFS to previous state

IFS=$OLDIFS

# Unbinding from Active Directory on 10.6.x and earlier

# Use dsconfigad to force AD unbinding. Using a bogus user and password
# since dsconfigad wants a specified user account.

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ) ]]; then
  /bin/echo "Unbinding from Active Directory on 10.6.x and earlier."
  /usr/sbin/dsconfigad -f -r -u nousernamehere -p nopasswordhere
else
  # Check for an Active Directory configuration profile installed by DeployStudio

  ds_ad_profile=`/usr/bin/profiles -L | awk '/com.deploystudio.adbindingtask/{print $NF}'`

  if [[ ${ds_ad_profile} != "" ]]; then
  	 /bin/echo "DeployStudio Active Directory configuration profile found:" "$ds_ad_profile"
	 /usr/bin/profiles -R -p "$ds_ad_profile"
  	 /bin/echo "Removing configuration profile to unbind from Active Directory."
  else
	 /bin/echo "DeployStudio AD profile not available."
  fi
  
  # If a configuration profile is not found, use dsconfigad to force AD unbinding.
  # Using a bogus user and password since dsconfigad wants a specified user account.
  
  if [[ ${ds_ad_profile} = "" ]]; then
   /bin/echo "Unbinding from Active Directory on 10.7.x and later."
   /usr/sbin/dsconfigad -force -remove -u nousernamehere -p nopasswordhere
  fi
fi

exit 0