#!/bin/sh

# Script to check if the CasperCheck LaunchDaemon and script 
# are installed. If both the script and LaunchDaemon are available
# at the defined location, script returns "Yes". If either or both 
# are missing, the script returns "No"

CasperCheckLaunchDaemon="/Library/LaunchDaemons/com.company.caspercheck.plist"
CasperCheckScript="/Library/Scripts/caspercheck.sh"

if [[ -f "$CasperCheckLaunchDaemon" ]] && [[ -f "$CasperCheckScript" ]]; then
    result="Yes"
else
    result="No"
fi

echo "<result>$result</result>"
