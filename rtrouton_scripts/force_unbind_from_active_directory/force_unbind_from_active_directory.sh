#!/bin/sh
# Script to force AD unbinding
#
# Using bogus user since dsconfigad
# wants a specified user account

# Determine OS version
osvers=$(sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers} -lt 7 ]]; then
  dsconfigad -f -r -u nousernamehere -p nopasswordhere
fi

if [[ ${osvers} -ge 7 ]]; then
 dsconfigad -force -remove -u nousernamehere -p nopasswordhere
fi
