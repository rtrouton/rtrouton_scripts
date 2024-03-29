#!/bin/bash

# Accept EULA so there is no prompt

if [[ -e "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" ]]; then
  "/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild" -license accept
fi

# Just in case the xcodebuild command above fails to accept the EULA, set the license acceptance info 
# in /Library/Preferences/com.apple.dt.Xcode.plist. For more details on this, see Tim Sutton's post: 
# http://macops.ca/deploying-xcode-the-trick-with-accepting-license-agreements/

if [[ -e "/Applications/Xcode.app/Contents/Resources/LicenseInfo.plist" ]]; then

   xcode_version_number=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/"Info CFBundleShortVersionString`
   xcode_build_number=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/Resources/"LicenseInfo licenseID`
   xcode_license_type=`/usr/bin/defaults read "/Applications/Xcode.app/Contents/Resources/"LicenseInfo licenseType`
   
   if [[ "${xcode_license_type}" == "GM" ]]; then
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDEXcodeVersionForAgreedToGMLicense "$xcode_version_number"
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDELastGMLicenseAgreedTo "$xcode_build_number"
    else
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDEXcodeVersionForAgreedToBetaLicense "$xcode_version_number"
       /usr/bin/defaults write "/Library/Preferences/"com.apple.dt.Xcode IDELastBetaLicenseAgreedTo "$xcode_build_number"
   fi       
   
fi


# Install Mobile Device Package so there is no prompt

if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg" ]]; then
  /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/MobileDevice.pkg" -target /
fi

if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg" ]]; then
  /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/MobileDeviceDevelopment.pkg" -target /
fi

# Install Xcode System Resources Package, available in Xcode 8 and later

if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg" ]]; then
  /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/XcodeSystemResources.pkg" -target /
fi

# Install Xcode CoreTypes Package, available in Xcode 14 and later

if [[ -e "/Applications/Xcode.app/Contents/Resources/Packages/CoreTypes.pkg" ]]; then
  /usr/sbin/installer -dumplog -verbose -pkg "/Applications/Xcode.app/Contents/Resources/Packages/CoreTypes.pkg" -target /
fi

exit 0
