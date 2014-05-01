#!/bin/bash

# This script displays a message that lets the user know that 
# an application installation policy has finished. It is set 
# to the lowest priority to ensure that it runs last after all 
# other scripts and policy actions.


application_name="$4"

jamf displayMessage -message "$application_name has now been installed on your Mac. Please restart your Mac before using $application_name"

exit 0
