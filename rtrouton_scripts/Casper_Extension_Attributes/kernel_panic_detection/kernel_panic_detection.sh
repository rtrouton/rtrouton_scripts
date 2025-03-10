#!/bin/bash

# Detects kernel panics which occurred in the last seven days.
#
# Original idea and script from here:
# https://www.jamf.com/jamf-nation/discussions/23976/kernal-panic-reporting#responseChild145035
#
# This Jamf Pro Extension Attribute is designed to 
# check the contents of /Library/Logs/DiagnosticReports
# and report on how many log files with the file suffix
# of ".panic" were created in the previous seven days.

PanicLogCount=$(/usr/bin/find /Library/Logs/DiagnosticReports -not -path '*/\.*' -Btime -7 -name *.panic | grep . -c)

echo "<result>$PanicLogCount</result>"

exit 0