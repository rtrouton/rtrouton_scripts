#!/bin/bash

# This script displays a message that lets the user know that 
# a browser installation policy has finished. It is set 
# to the lowest priority to ensure that it runs last after all 
# other scripts and policy actions.


browser_plugin_name="$4"

jamf displayMessage -message "The $browser_plugin_name plug-in has now been installed on your Mac. You will need to quit and relaunch your browser for the new plug-in to work properly."

exit 0

