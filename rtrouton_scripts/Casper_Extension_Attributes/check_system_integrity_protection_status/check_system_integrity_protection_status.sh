#!/bin/bash

osvers_major=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | /usr/bin/awk -F. '{print $2}')

# Checks to see if the OS on the Mac is 10.x.x. If it is not, the 
# following message is displayed without quotes:
#
# "Unknown Version Of Mac OS X"

if [[ ${osvers_major} -ne 10 ]]; then
    /bin/echo "<result>Unknown Version of Mac OS X</result>"
fi

# Checks to see if the OS on the Mac is 10.11.x or higher.
# If it is not, the following message is displayed without quotes:
#
# "System Integrity Protection Not Available For" followed by the version of OS X.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -lt 11 ]]; then
    /bin/echo "<result>System Integrity Protection Not Available For $(/usr/bin/sw_vers -productVersion)</result>"
fi

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 11 ]]; then
 
# Checks System Integrity Protection status on Macs
# running 10.11.x or higher

    SIP_status=$(/usr/bin/csrutil status | /usr/bin/awk '/status/ {print $5}' | /usr/bin/sed 's/\.$//')

    # Check if SIP is disabled AND has an entry in nvram which indicates SIP is clearly not enabled
    if [[ "$SIP_status" = "disabled" ]] && [[ "$(/usr/sbin/nvram -p | /usr/bin/grep "csr-active-config")" ]]; then
        result="Disabled"
    # Check if SIP is disabled AND has NO entry in nvram which indicates SIP has been reset to enabled
    # But needs to be restarted before change takes effect
    elif [[ "$SIP_status" = "disabled" ]] && [[ -z "$(/usr/sbin/nvram -p | /usr/bin/grep "csr-active-config")" ]]; then
        result="Set To Enable After Restart"
    elif [[ "$SIP_status" = "enabled" ]]; then
        SIP_status="Active"
       
        # If SIP is enabled, run 'csrutil status' a second time
        # and export the output to a text file with a randomly
        # generated name.
       
        sip_output="/tmp/$(/usr/bin/uuidgen).txt"
        /usr/bin/csrutil status > "$sip_output"
      
        # Check the exported text file to see any custom SIP configuration
        # options have been enabled. If any custom SIP configurations are
        # active, display the configuration status.
      
        sip_kernel_extension_allowed=$(/bin/cat "$sip_output" | /usr/bin/grep -io "Kext Signing: disabled")
        if [[ "${sip_kernel_extension_allowed}" != "" ]]; then
            sip_kernel=$(/usr/bin/printf "\n$sip_kernel_extension_allowed")
        fi
        sip_filesystem_allowed=$(/bin/cat "$sip_output" | /usr/bin/grep -io "Filesystem Protections: disabled")
        if [[ "${sip_filesystem_allowed}" != "" ]]; then
            sip_filesystem=$(/usr/bin/printf "\n$sip_filesystem_allowed")
        fi
        sip_nvram_allowed=$(/bin/cat "$sip_output" | /usr/bin/grep -io "NVRAM Protections: disabled")
        if [[ "${sip_nvram_allowed}" != "" ]]; then
            sip_nvram=$(/usr/bin/printf "\n$sip_nvram_allowed")
        fi
        sip_debug_allowed=$(/bin/cat "$sip_output" | /usr/bin/grep -io "Debugging Restrictions: disabled")
        if [[ "${sip_debug_allowed}" != "" ]]; then
            sip_debug=$(/usr/bin/printf "\n$sip_debug_allowed")
        fi
        sip_dtrace_allowed=$(/bin/cat "$sip_output" | /usr/bin/grep -io "DTrace Restrictions: disabled")
        if [[ "${sip_dtrace_allowed}" != "" ]]; then
            sip_dtrace=$(usr/bin/printf "\n$sip_dtrace_allowed")
        fi
        if [[ -e "$sip_output" ]]; then
            /bin/rm -f "$sip_output"
        fi
        result="$SIP_status$sip_kernel$sip_filesystem$sip_nvram$sip_debug$sip_dtrace"
  fi
   /bin/echo "<result>$result</result>"
fi
