#!/bin/bash

# This script disables the VPN module for Cisco Secure Connect as a post-installation action.

vpn_setting_file="/opt/cisco/secureclient/vpn/profile/VPNDisable_ServiceProfile.xml"

# Detect the current setting for the VPN module being enabled or disabled.
#
# If enabled, the following value should be set in the XML file:
#
# <ServiceDisable>false</ServiceDisable>

vpn_setting_status=$(/usr/bin/xmllint --xpath "//*[local-name()='ServiceDisable']/text()" "${vpn_setting_file}")

# If the VPN module is enabled, disable it.

if [[ "${vpn_setting_status}" = "false" ]]; then
	sed -i '' -e "s/<ServiceDisable>false<\/ServiceDisable>/<ServiceDisable>true<\/ServiceDisable>/g" "${vpn_setting_file}"
fi
