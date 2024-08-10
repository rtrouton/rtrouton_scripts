These scripts detects the current setting for the VPN module for Cisco Secure Connect being enabled or disabled, then takes the actions defined in the script to enable or disable the VPN module:

* `Cisco_Secure_Client_postinstallation_enable_VPN_module.sh`: Enables the VPN module.
* `Cisco_Secure_Client_postinstallation_disable_VPN_module.sh`: Disables the VPN module.

Note: The script should be run with root privileges in order to make the changes to the relevant file:

`/opt/cisco/secureclient/vpn/profile/VPNDisable_ServiceProfile.xml`