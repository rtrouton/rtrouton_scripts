#!/bin/bash

osvers_major=$(sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(sw_vers -productVersion | awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ ${osvers_major} -ne 10 ]]; then
  /bin/echo "Unknown Version of Mac OS X"
fi

# Checks to see if the OS on the Mac is 10.11.x or higher.
# If it is not, the following message is displayed without quotes:
#
# "System Integrity Protection Not Available For" followed by the version of OS X.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 11 ]]; then
  /bin/echo "System Integrity Protection Not Available For `sw_vers -productVersion`"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 11 ]]; then
 
# Checks System Integrity Protection status on Macs
# running 10.11.x or higher

  SIP_status=`/usr/bin/csrutil status | awk '/status/ {print $5}' | sed 's/\.$//'`

  if [ $SIP_status = "disabled" ]; then
      result=Disabled
  elif [ $SIP_status = "enabled" ]; then
         SIP_status="Active"
       
       # If SIP is enabled, run 'csrutil status' a second time
       # and export the output to a text file with a randomly
       # generated name.
       
       sip_output="/tmp/`/usr/bin/uuidgen`.txt"
      /usr/bin/csrutil status > "$sip_output"
      
      # Check the exported text file to see any custom SIP configuration
      # options have been enabled. If any custom SIP configurations are
      # active, display the configuration status.
      
      sip_kernel_extension_allowed=`cat "$sip_output" | grep -io "Kext Signing: disabled"`
        if [[ ${sip_kernel_extension_allowed} != "" ]]; then
            sip_kernel=`/usr/bin/printf "\n$sip_kernel_extension_allowed"`
        fi
      sip_filesystem_allowed=`cat "$sip_output" | grep -io "Filesystem Protections: disabled"`
        if [[ ${sip_filesystem_allowed} != "" ]]; then
            sip_filesystem=`/usr/bin/printf "\n$sip_filesystem_allowed"`
        fi
      sip_nvram_allowed=`cat "$sip_output" | grep -io "NVRAM Protections: disabled"`
        if [[ ${sip_nvram_allowed} != "" ]]; then
            sip_nvram=`/usr/bin/printf "\n$sip_nvram_allowed"`
        fi
      sip_debug_allowed=`cat "$sip_output" | grep -io "Debugging Restrictions: disabled"`
        if [[ ${sip_debug_allowed} != "" ]]; then
            sip_debug=`/usr/bin/printf "\n$sip_debug_allowed"`
        fi
      sip_dtrace_allowed=`cat "$sip_output" | grep -io "DTrace Restrictions: disabled"`
        if [[ ${sip_dtrace_allowed} != "" ]]; then
            sip_dtrace=`/usr/bin/printf "\n$sip_dtrace_allowed"`
        fi
        if [[ -e "$sip_output" ]]; then
            /bin/rm "$sip_output"
        fi
        result="$SIP_status$sip_kernel$sip_filesystem$sip_nvram$sip_debug$sip_dtrace"
  fi
   /bin/echo "System Integrity Protection status: ""$result"
fi