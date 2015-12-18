This Casper Extension Attribute checks 10.11 and later Macs to see if System Integrity Protection is disabled.

If the Mac is running 10.10.x or earlier:

The script reports "System Integrity Protection Not Available For" and then reports the relevant version of OS X.

If the Mac is running 10.11.x or later:

If System Integrity Protection is disabled, script returns "Disabled". 
If System Integrity Protection is enabled, script returns "Active".
If SIP has custom configurations, script returns output similar to that shown below:

Active
Kext Signing: disabled
Filesystem Protections: disabled
NVRAM Protections: disabled
Debugging Restrictions: disabled
DTrace Restrictions: disabled

See "Casper_Extension_Attribute_Setup.png" for a screenshot of how the Extension Attribute should be configured.
