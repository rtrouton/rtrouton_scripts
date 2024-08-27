#!/bin/bash

# This Jamf Pro Extension Attribute checks for the Microsoft AutoUpdate
# app and identifies if Microsoft AutoUpdate is installed.

# Once the existence of the Microsoft AutoUpdate app
# is verified, the EA will return the following result:
#
# 0 = Microsoft AutoUpdate is not installed
# 1 = Microsoft AutoUpdate is installed

if [[ -x "/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app" ]]; then
    echo "<result>1</result>"
else
    echo "<result>0</result>"
fi

exit 0
