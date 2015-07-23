#!/bin/bash

# This script runs a manual policy trigger to
# allow the policy or policies associated with that
# trigger to be executed.


trigger_name="$4"

jamf policy -trigger "$trigger_name"

exit 0
