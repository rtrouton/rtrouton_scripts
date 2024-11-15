These scripts are designed to clear failed MDM commands from specified Jamf Pro computer or mobile device groups. Clearing failed MDM commands allows those MDM commands or profiles to be re-pushed automatically.

`clear_failed_Jamf_Pro_mdm_commands_from_computer_group.sh`

This script is designed to use API client authentication, where the associated API role has the 
following permissions assigned:

* Flush MDM Commands
* Read Smart Computer Groups
* Read Static Computer Groups

`clear_failed_Jamf_Pro_mdm_commands_from_mobile_device_group.sh`

This script is designed to use API client authentication, where the associated API role has the 
following permissions assigned:

* Flush MDM Commands
* Read Smart Mobile Device Groups
* Read Static Mobile Device Groups
