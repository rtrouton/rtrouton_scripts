#!/bin/bash

# Jamf Pro Extension Attribute to determine which tool should be updating an installed
# copy of Windows App.
# 
# If the app was installed using the Mac App Store with a person's Apple Account, the EA 
# will return the following result:
#
# MAS
#
# If the app was licensed using the Volume Purchase Program and installed by an MDM, 
# the EA will return the following result:
#
# VPP
#
# If the app was not installed via either the Mac App Store or VPP, the EA 
# will return the following result:
#
# MAU
#
# Note: "MAU" stands for Microsoft AutoUpdate, Microsoft's tool for updating
# Microsoft apps on macOS.
#
# In all other cases, the EA will return the following result:
#
# NA

result="NA"
app_name="Windows App.app"
app_install_path="/Applications/$app_name"


if [[ -d "${app_install_path}" ]]; then
    app_install_source=$(/usr/bin/mdls -name kMDItemAppStoreReceiptType "${app_install_path}" | awk '{print $3}' | tr -d '"')
    if [[ "$app_install_source" = "ProductionVPP" ]]; then
         result="VPP"
    elif [[ "$app_install_source" = "Production" ]]; then
            result="MAS"
    else
        result="MAU"
    fi
fi

echo "<result>$result</result>"
exit 0