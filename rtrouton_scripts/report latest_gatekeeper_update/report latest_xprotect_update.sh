#!/bin/bash

XProtectCheck(){

osvers_major=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 6 ]]; then

   # This section of the function will display a message that XProtect is not 
   # available for the relevant version of Mac OS X. This will apply to Macs
   # running Mac OS X 10.5.8 and earlier.

  result="XProtect not available for `/usr/bin/sw_vers -productVersion`"

elif [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 6 ]] && [[ ${osvers_minor} -lt 9 ]]; then

   # This section of the function will check the last-modified time of XProtect's 
   # XProtect.meta.plist file and report the date when the file was last modified
   # in a human-readable date  format. This will apply to Macs running Mac OS X 10.6.x
   # through OS X 10.8.5.

  last_xprotect_update_epoch_time=`/bin/date -jf "%s" $(/usr/bin/stat -s /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/XProtect.meta.plist | tr ' ' '\n' | awk -F= '/st_mtime/{print $NF}') +%s`
  last_xprotect_update_human_readable_time=`/bin/date -r "$last_xprotect_update_epoch_time" '+%m-%d-%Y %H:%M:%S'`
  result="$last_xprotect_update_human_readable_time"
  
elif [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 9 ]]; then

   # This section of the function will check the installer package receipts for 
   # XProtect update installer packages for the relevant version of Mac OS X and 
   # display the installation date of the most recent update in a human-readable 
   # date format. This will apply to Macs running OS X 10.9.0 and later.

  last_xprotect_update_epoch_time=$(printf "%s\n" `for i in $(pkgutil --pkgs=".*XProtect.*"); do pkgutil --pkg-info $i | awk '/install-time/ {print $2}'; done` | sort -n | tail -1)
  last_xprotect_update_human_readable_time=`/bin/date -r "$last_xprotect_update_epoch_time" '+%m-%d-%Y %H:%M:%S'`
  result="$last_xprotect_update_human_readable_time"
  
fi

}

XProtectCheck

echo "$result"