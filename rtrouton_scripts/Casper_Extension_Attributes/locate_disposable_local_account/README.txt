This Casper Extension Attribute is designed to identify specific local user accounts which are older than a certain number of days.

If account is not found, script returns "username_goes_here account not present"
If account is found and the account's home folder is older than the set number of days, script returns "Yes"
If account is found and the account's home folder is not older than the set number of days, script returns "No"
If account is found but age can't be determined, script returns "username_goes_here account present but unable to determine age. Please check."

See "Casper_Extension_Attribute_Setup.png" for a screenshot of how the Extension Attribute should be configured.
