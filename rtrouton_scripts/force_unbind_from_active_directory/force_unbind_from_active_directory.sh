#!/bin/sh

# Script to force AD unbinding
#
# Using bogus user since dsconfigad
# wants a specified user account
 
dsconfigad -force -remove -u nousernamehere -p nopasswordhere
