#!/bin/bash

osvers_major=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $1}')
osvers_minor=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $2}')
osvers_dot_version=$(/usr/bin/sw_vers -productVersion | awk -F. '{print $3}')

IRKHashCheck(){

# This function checks for the SHA-1 hash of a FileVault 2 institutional recovery key's public 
# key in hexadecimal notation.
# 
# If the Mac is not encrypted, the script sets the following string for the "result" value:
# 
# "Not Available - Encryption Not Enabled" (no quotes)
#
# If the Mac is encrypted but is not using an institutional recovery key, the script sets the 
# following string for the "result" value:
#
# "Not Available - Valid IRK Not Found" (no quotes)
#
# If the Mac is encrypted and an institutional recovery key is in use as a valid recovery key on 
# the Mac's boot volume, the script sets the SHA-1 hash of the institutional recovery key's public 
# key in hexadecimal notation for the "result" value.

	   if [[ `fdesetup status | grep "Off"` = "" ]]; then
	      FDE="on"
	      if [[ "$FDE"="on" ]]; then
	          if  [[ `fdesetup hasinstitutionalrecoverykey` = "true" ]]; then
        	      result=`fdesetup hasinstitutionalrecoverykey -device /`
	          else
        	      result="Not Available - Valid IRK Not Found"
	          fi
	      fi
	   elif [[ "$FDE" = "" ]]; then
           result="Not Available - Encryption Not Enabled"
	   fi
}

# Check to see if the OS version of the Mac includes a version of fdesetup which can output 
# the SHA-1 hash of the institutional recovery key's public key in hexadecimal notation. If the 
# OS check passes, run the IRKHashCheck function.

if [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -ge 12 ]]; then
    IRKHashCheck
elif [[ ${osvers_major} -eq 10 ]] && [[ ${osvers_minor} -eq 11 ]] && [[ ${osvers_dot_version} -ge 2 ]]; then 
    IRKHashCheck
else

# If the OS check did not pass, the script sets the following string for the "result" value:
#
# "Not Available - Unable To Export IRK Public Key Hash On", followed by the OS version. (no quotes)

    result="Not Available - Unable To Export IRK Public Key Hash On `/usr/bin/sw_vers -productVersion`"
fi

echo "<result>$result</result>"