#!/bin/sh
​
# Script to check if the CasperCheck LaunchDaemon and script 
# are installed. If both the script and LaunchDaemon are available
# at the defined location, script returns "Yes". If either or both 
# are missing, the script returns "No"
# If both are present, check that the LaunchDaemon is loaded.
​
CasperCheckLaunchDaemon="/Library/LaunchDaemons/com.company.caspercheck.plist"
CasperCheckScript="/Library/Scripts/caspercheck.sh"
​
if [[ -f "$CasperCheckLaunchDaemon" ]] && [[ -f "$CasperCheckScript" ]]; then
    CasperCheckLoaded=$(/bin/launchctl list | grep com.company.caspercheck)
        
        #if string is not empty
        if [ -n "${CasperCheckLoaded}" ]; then
        result="Yes"
    else
    result="Not loaded"
    fi
else
    result="No"
fi
​
echo "<result>$result</result>"
