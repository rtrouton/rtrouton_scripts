This script checks 10.11 and later Macs to see if System Integrity Protection is disabled.

If the Mac is running 10.10.x or earlier:

The script reports "System Integrity Protection Not Available For" and then reports the relevant version of OS X.

If the Mac is running 10.11.x or later:

If System Integrity Protection is disabled, script returns "System Integrity Protection status: Disabled". 
If System Integrity Protection is enabled, script returns "System Integrity Protection status: Active".
If SIP has custom configurations, script returns output similar to that shown below:

System Integrity Protection status: Active
Kext Signing: disabled
Filesystem Protections: disabled
NVRAM Protections: disabled
Debugging Restrictions: disabled
DTrace Restrictions: disabled

There is an counterpart Casper Extension Attribute available from the link below:

https://github.com/rtrouton/rtrouton_scripts/tree/master/rtrouton_scripts/Casper_Extension_Attributes/check_system_integrity_protection_status
