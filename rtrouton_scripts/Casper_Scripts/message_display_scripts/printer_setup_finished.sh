#!/bin/bash

# This script displays a message that lets the user know that 
# a printer setup policy has finished. It is set to the lowest
# priority to ensure that it runs last after all other scripts
# and policy actions.

printer_name="$4"

/usr/sbin/jamf displayMessage -message "The $printer_name printer has now been set up on your Mac."

exit 0
