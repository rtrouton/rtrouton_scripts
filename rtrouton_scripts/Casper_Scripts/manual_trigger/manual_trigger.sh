#!/bin/bash

# This script runs a manual policy event trigger to
# allow the policy or policies associated with that
# trigger to be executed.
#
# Script uses a manual trigger name (set as Parameter 4
# in the script's parameter list in Jamf Pro) to specify 
# which policy or policies should be run.

eventTrigger="$4"

exitCode=0

RunPolicyWithManualEventTrigger (){

# This function runs a manual policy event trigger to
# allow the policy or policies associated with that
# trigger to be executed.

if [[ -n "$eventTrigger" ]]; then
    /usr/local/jamf/bin/jamf policy -event "$eventTrigger"
else
    echo "No event trigger specified"
    exitCode=1
fi

}

RunPolicyWithManualEventTrigger

exit "$exitCode"