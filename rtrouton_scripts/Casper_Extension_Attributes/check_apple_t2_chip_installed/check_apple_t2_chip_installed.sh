#!/bin/bash

# Extension attribute checks to see if Apple's T2 chip is installed on a Mac. 
#
# If Apple's T2 chip is installed:
#
# The following command will return "T2" as output
#
# system_profiler SPiBridgeDataType | awk '/Apple T2 Security Chip/ {print $4}'
#
# If Apple's T2 chip is not installed:
#
# Nothing will be returned as output.
#
# If Apple's T2 chip software is installed, the following message is displayed:
#
# 1
#
# Otherwise, the following result is returned:
#
# 0

T2_CHIP_CHECK=$(system_profiler SPiBridgeDataType | awk '/Apple T2 Security Chip/ {print $4}')

if [[ "$T2_CHIP_CHECK" = "T2" ]]; then
	echo "<result>1</result>"
else
	echo "<result>0</result>"
fi

exit 0
