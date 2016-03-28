#!/bin/bash

GatekeeperCheck(){

osvers_major=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')
osvers_dot_version=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $3}')

if [[ ${osvers_major} -eq 10 && ${osvers_minor} -lt 7 ]] || [[ ${osvers_major} -eq 10 && ${osvers_minor} -eq 7 && ${osvers_dot_version} -lt 5 ]]; then

   # This section of the function will display a message that Gatekeeper is not 
   # available for the relevant version of Mac OS X. This will apply to Macs running
   # Mac OS X 10.7.4 and earlier.

  result="Gatekeeper not available for `/usr/bin/sw_vers -productVersion`"

elif [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 7 ]] && [[ ${osvers_dot_version} -eq 5 ]]; then

   # This section of the function will display a message that Gatekeeper's update 
   # status is not available for the relevant version of Mac OS X. This will apply
   # only to Mac OS X 10.7.5.

  result="Gatekeeper update status not available for `/usr/bin/sw_vers -productVersion`."

elif [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 8 ]]; then

   # This section of the function will check the package receipts for Gatekeeper 
   # update installer packages and display the installation date of the most recent
   # update in a human-readable date format. This will apply to Macs running
   # OS X 10.8.0 and later.

  last_gatekeeper_update_epoch_time=$(printf "%s\n" `for i in $(pkgutil --pkgs=".*Gatekeeper.*"); do pkgutil --pkg-info $i | awk '/install-time/ {print $2}'; done` | sort -n | tail -1)
  last_gatekeeper_update_human_readable_time=`/bin/date -r "$last_gatekeeper_update_epoch_time" '+%m-%d-%Y %H:%M:%S'`
  result="$last_gatekeeper_update_human_readable_time"

fi

}

GatekeeperCheck

echo "<result>$result</result>" 