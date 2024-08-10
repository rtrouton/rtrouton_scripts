#!/bin/bash

# This script enables the VPN module for Cisco Secure Connect as a post-installation action.

vpn_setting_file="/opt/cisco/secureclient/vpn/profile/VPNDisable_ServiceProfile.xml"

# Detect the current setting for the VPN module being enabled or disabled.
#
# If disabled, the following value should be set in the XML file:
#
# <ServiceDisable>true</ServiceDisable>

vpn_setting_status=$(/usr/bin/xmllint --xpath "//*[local-name()='ServiceDisable']/text()" "${vpn_setting_file}")

# If the VPN module is disabled, enable it.

if [[ "${vpn_setting_status}" = "true" ]]; then
	sed -i '' -e "s/<ServiceDisable>true<\/ServiceDisable>/<ServiceDisable>false<\/ServiceDisable>/g" "${vpn_setting_file}"
fi
